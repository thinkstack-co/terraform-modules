# AWS Backup Status Reporter Infrastructure

This Terraform module deploys the infrastructure for the AWS Backup Status Reporter Lambda function that generates daily PDF reports of backup job statuses.

## Features

- Creates an S3 bucket for storing backup status PDF reports
- Deploys a Lambda function that queries AWS Backup vaults and generates reports
- Sets up CloudWatch Events for scheduled execution (default: daily at 8 AM UTC)
- Configurable vault monitoring (enable/disable specific vault types)
- S3 lifecycle policies for report retention and archival
- CloudWatch Logs for Lambda function monitoring

## Prerequisites

1. **Build the Lambda package** first:
   ```bash
   cd ../
   docker build -t backup-reporter-build .
   docker run --rm -v $(pwd):/out backup-reporter-build cp /tmp/lambda_package.zip /out/lambda_package.zip
   ```

2. Ensure you have AWS Backup vaults created that follow the naming convention.

## Usage

### Basic Example

```hcl
module "backup_reporter" {
  source = "./backup_report_infra"
  
  customer_name     = "ACME Corp"
  vault_name_prefix = "prod-"  # Will monitor prod-hourly, prod-daily, etc.
  
  tags = {
    Environment = "production"
    Purpose     = "backup-monitoring"
  }
}
```

### Advanced Example with Vault Configuration

```hcl
module "backup_reporter" {
  source = "./backup_report_infra"
  
  customer_name     = "ACME Corp"
  vault_name_prefix = "prod-"
  
  # Disable specific vault reporting
  enable_hourly_report  = true
  enable_daily_report   = true
  enable_weekly_report  = true
  enable_monthly_report = true
  enable_yearly_report  = false  # Don't report on yearly backups
  
  # Override specific vault names
  daily_vault_name = "custom-daily-vault"
  
  # Custom S3 key prefix for organizing reports
  s3_key_prefix = "backup-reports/production"
  
  # Lambda configuration
  lambda_function_name = "acme-backup-reporter"
  lambda_memory_size   = 512
  lambda_timeout       = 300
  
  # Schedule - Run twice daily
  schedule_expression = "cron(0 8,20 * * ? *)"
  
  # S3 lifecycle
  enable_s3_lifecycle_rules = true
  report_retention_days     = 90
  glacier_transition_days   = 30
  
  # CloudWatch logs
  log_retention_days = 14
  
  tags = {
    Environment = "production"
    Customer    = "ACME"
  }
}
```

### Integration with Backup Vault Module

```hcl
# First, create your backup vaults
module "backup_vaults" {
  source = "../../aws_backup_vault"
  
  vault_name_prefix    = "prod"
  enable_hourly_vault  = true
  enable_daily_vault   = true
  enable_weekly_vault  = true
  enable_monthly_vault = true
  enable_yearly_vault  = true
}

# Then create the reporter
module "backup_reporter" {
  source = "./backup_report_infra"
  
  customer_name = "ACME Corp"
  
  # Use outputs from vault module
  vault_name_prefix  = "prod"
  hourly_vault_name  = module.backup_vaults.scheduled_vault_names["hourly"]
  daily_vault_name   = module.backup_vaults.scheduled_vault_names["daily"]
  weekly_vault_name  = module.backup_vaults.scheduled_vault_names["weekly"]
  monthly_vault_name = module.backup_vaults.scheduled_vault_names["monthly"]
  yearly_vault_name  = module.backup_vaults.scheduled_vault_names["yearly"]
}
```

## Testing the Lambda Function

After deployment, you can test the Lambda function manually:

```bash
# Get the function name from outputs
FUNCTION_NAME=$(terraform output -raw lambda_function_name)

# Invoke the function
aws lambda invoke \
  --function-name $FUNCTION_NAME \
  --payload '{}' \
  response.json

# Check the response
cat response.json

# View the generated report in S3
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
aws s3 ls s3://$BUCKET_NAME/ --recursive
```

## Report Location

Reports are stored in S3 with the following structure:
```
# Without prefix (default):
s3://bucket-name/YYYY/MM/customer-backup-status-report-YYYY-MM-DD.pdf

# With custom prefix:
s3://bucket-name/prefix/YYYY/MM/customer-backup-status-report-YYYY-MM-DD.pdf
```

For example:
```
# Default location:
s3://backup-status-report-12345/2024/01/acme-corp-backup-status-report-2024-01-15.pdf

# With prefix "backup-reports/production":
s3://backup-status-report-12345/backup-reports/production/2024/01/acme-corp-backup-status-report-2024-01-15.pdf
```

## Monitoring

### CloudWatch Logs

View Lambda execution logs:
```bash
LOG_GROUP=$(terraform output -raw cloudwatch_log_group_name)
aws logs tail $LOG_GROUP --follow
```

### Check Recent Invocations

```bash
FUNCTION_NAME=$(terraform output -raw lambda_function_name)
aws logs filter-log-events \
  --log-group-name /aws/lambda/$FUNCTION_NAME \
  --start-time $(date -u -d '1 hour ago' +%s)000 \
  --filter-pattern "ERROR"
```

## Outputs

| Name | Description |
|------|-------------|
| `s3_bucket_name` | Name of the S3 bucket storing reports |
| `s3_bucket_arn` | ARN of the S3 bucket |
| `lambda_function_name` | Name of the Lambda function |
| `lambda_function_arn` | ARN of the Lambda function |
| `cloudwatch_event_rule_name` | Name of the CloudWatch Event rule |
| `vaults_monitored` | List of vault names being monitored |
| `report_path_pattern` | S3 path pattern for reports |

## Variables

Key variables:

| Name | Description | Default |
|------|-------------|---------|
| `customer_name` | Customer identifier for reports | Uses AWS Account ID |
| `vault_name_prefix` | Prefix for vault names | "" |
| `s3_key_prefix` | Optional prefix for S3 object keys | "" |
| `enable_hourly_report` | Monitor hourly vault | true |
| `enable_daily_report` | Monitor daily vault | true |
| `enable_weekly_report` | Monitor weekly vault | true |
| `enable_monthly_report` | Monitor monthly vault | true |
| `enable_yearly_report` | Monitor yearly vault | true |
| `schedule_expression` | Cron schedule for reports | Daily at 8 AM UTC |
| `lambda_timeout` | Lambda timeout in seconds | 300 |
| `report_retention_days` | Days to retain reports | 90 |

See [variables.tf](./variables.tf) for all available configuration options.

## Troubleshooting

1. **Lambda timeout errors**: Increase `lambda_timeout` (max 900 seconds)
2. **Memory errors**: Increase `lambda_memory_size` (max 10240 MB)
3. **Missing vaults**: Check vault names match your configuration
4. **No backup jobs found**: Ensure backups ran in the last 24 hours
5. **Permission errors**: Verify the Lambda IAM role has access to backup vaults

## Cost Considerations

- Lambda invocations: ~$0.20 per million requests
- Lambda duration: ~$0.0000166667 per GB-second
- S3 storage: ~$0.023 per GB per month
- CloudWatch Logs: ~$0.50 per GB ingested

With daily execution and average report sizes, expect < $1/month per customer.