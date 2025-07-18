# AWS Backup Status Reporter Module

This module creates a Lambda function that generates PDF reports of AWS Backup job statuses. The reports can cover 1-7 days of backup history and include detailed information about successful, failed, and running backup jobs.

## Features

- **Flexible Time Range**: Reports on backup jobs from the last 1-7 days (configurable)
- **Vault Selection**: Enable/disable reporting for specific vault types (hourly, daily, weekly, monthly, yearly)
- **Custom Vault Ordering**: Configure the order in which vaults appear in the report
- **Detailed Reporting**: 
  - Color-coded status indicators (green for success, red for failed, orange for running)
  - Resource identification with Name tags
  - Backup type classification
  - Detailed failed job reporting with error messages
- **Automated Delivery**: PDF generation and automatic S3 upload
- **S3 Lifecycle Management**: Automatic archival to Glacier and retention policies

## Usage Example

### Basic Usage

```hcl
module "backup_reporter" {
  source = "./path/to/backup_reporter/backup_report_infra"

  # S3 bucket configuration
  s3_bucket_prefix = "backup-reports-"
  customer_name    = "ACME Corporation"
  
  # Report configuration
  report_days      = 3  # Include last 3 days of backups
  vault_sort_order = "daily,weekly,monthly,hourly,yearly"  # Custom sort order
  
  # Vault configuration
  vault_name_prefix = "prod-"  # Will look for prod-hourly, prod-daily, etc.
  
  # Enable/disable specific vault reporting
  enable_hourly_report  = true
  enable_daily_report   = true
  enable_weekly_report  = true
  enable_monthly_report = true
  enable_yearly_report  = false  # Disable yearly reports
  
  # Lambda configuration
  lambda_function_name = "backup-status-reporter"
  lambda_timeout       = 300
  lambda_memory_size   = 512
  
  # Schedule (daily at 8 AM UTC)
  schedule_expression = "cron(0 8 * * ? *)"
  
  # S3 lifecycle rules
  enable_s3_lifecycle_rules = true
  report_retention_days     = 90   # Keep reports for 90 days
  enable_glacier_transition = true
  glacier_transition_days   = 30   # Move to Glacier after 30 days
  
  # CloudWatch logs retention
  log_retention_days = 7
  
  tags = {
    Environment = "production"
    Purpose     = "backup-reporting"
    ManagedBy   = "terraform"
  }
}
```

### Advanced Usage with Custom Vault Names

```hcl
module "backup_reporter" {
  source = "./path/to/backup_reporter/backup_report_infra"

  s3_bucket_prefix = "backup-reports-"
  customer_name    = "Enterprise Client"
  
  # Report last 7 days of backups
  report_days = 7
  
  # Custom vault sort order
  vault_sort_order = "hourly,daily,weekly,monthly,yearly"
  
  # Override specific vault names
  hourly_vault_name  = "critical-hourly-backups"
  daily_vault_name   = "standard-daily-backups"
  weekly_vault_name  = "archive-weekly-backups"
  monthly_vault_name = "compliance-monthly-backups"
  yearly_vault_name  = "longterm-yearly-backups"
  
  # Selective vault reporting
  enable_hourly_report  = true
  enable_daily_report   = true
  enable_weekly_report  = true
  enable_monthly_report = false  # Skip monthly
  enable_yearly_report  = false  # Skip yearly
  
  # Run multiple times per day
  schedule_expression = "cron(0 */6 * * ? *)"  # Every 6 hours
}
```

### Integration with AWS Backup Vault Module

```hcl
# Create backup vaults
module "backup_vaults" {
  source = "../aws_backup_vault"
  
  vault_name_prefix    = "prod"
  enable_hourly_vault  = true
  enable_daily_vault   = true
  enable_weekly_vault  = true
  enable_monthly_vault = true
  enable_yearly_vault  = true
}

# Create backup reporter
module "backup_reporter" {
  source = "./path/to/backup_reporter/backup_report_infra"
  
  s3_bucket_prefix    = "backup-reports-"
  customer_name       = "Production Environment"
  report_days         = 7  # Weekly overview
  
  # Use the same prefix as the vault module
  vault_name_prefix = module.backup_vaults.vault_name_prefix
  
  # Enable reporting for all vaults we created
  enable_hourly_report  = true
  enable_daily_report   = true
  enable_weekly_report  = true
  enable_monthly_report = true
  enable_yearly_report  = true
  
  # Custom sort order - prioritize daily and weekly
  vault_sort_order = "daily,weekly,hourly,monthly,yearly"
  
  depends_on = [module.backup_vaults]
}
```

## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| s3_bucket_prefix | Prefix for the S3 bucket to store PDF backup reports | `string` | `"backup-status-report-"` | no |
| customer_name | Customer name for tagging and report identification | `string` | `""` | no |
| report_days | Number of days to include in the backup report (1-7) | `number` | `1` | no |
| vault_sort_order | Comma-separated list of vault types in desired sort order | `string` | `"hourly,daily,weekly,monthly,yearly"` | no |
| vault_name_prefix | Prefix for vault names | `string` | `""` | no |
| enable_hourly_report | Enable reporting for hourly backup vault | `bool` | `true` | no |
| enable_daily_report | Enable reporting for daily backup vault | `bool` | `true` | no |
| enable_weekly_report | Enable reporting for weekly backup vault | `bool` | `true` | no |
| enable_monthly_report | Enable reporting for monthly backup vault | `bool` | `true` | no |
| enable_yearly_report | Enable reporting for yearly backup vault | `bool` | `true` | no |
| hourly_vault_name | Override the hourly vault name | `string` | `""` | no |
| daily_vault_name | Override the daily vault name | `string` | `""` | no |
| weekly_vault_name | Override the weekly vault name | `string` | `""` | no |
| monthly_vault_name | Override the monthly vault name | `string` | `""` | no |
| yearly_vault_name | Override the yearly vault name | `string` | `""` | no |
| lambda_function_name | Name for the Lambda function | `string` | `"aws-backup-status-reporter"` | no |
| lambda_memory_size | Memory size (MB) for the Lambda function | `number` | `512` | no |
| lambda_timeout | Timeout (seconds) for the Lambda function | `number` | `300` | no |
| schedule_expression | Cron expression for running the backup report Lambda | `string` | `"cron(0 8 * * ? *)"` | no |
| enable_s3_lifecycle_rules | Whether to enable S3 lifecycle rules | `bool` | `true` | no |
| report_retention_days | Days to retain backup report PDFs in S3 | `number` | `90` | no |
| enable_glacier_transition | Whether to transition PDFs to Glacier | `bool` | `true` | no |
| glacier_transition_days | Days before transitioning to Glacier | `number` | `30` | no |
| log_retention_days | Days to retain CloudWatch logs | `number` | `7` | no |
| tags | Map of tags to apply to all resources | `map(string)` | `{}` | no |

## Module Outputs

| Name | Description |
|------|-------------|
| lambda_function_name | Name of the Lambda function |
| lambda_function_arn | ARN of the Lambda function |
| report_bucket_name | Name of the S3 bucket for reports |
| report_bucket_arn | ARN of the S3 bucket for reports |
| lambda_role_arn | ARN of the Lambda execution role |
| cloudwatch_event_rule_name | Name of the CloudWatch Event rule |

## Report Contents

The PDF report includes:

1. **Header Information**
   - Customer identifier
   - AWS Account ID
   - Report time period (configurable 1-7 days)

2. **Summary Statistics**
   - Total backup jobs
   - Successful jobs count
   - Failed jobs count
   - Running/pending jobs count

3. **Detailed Backup Job Table** (sorted by vault_sort_order)
   - Resource Name (from Name tag)
   - Resource ID
   - Resource Type (EC2, RDS, EFS, etc.)
   - Backup Type (Hourly, Daily, Weekly, Monthly, Yearly)
   - Creation Time
   - Vault Name
   - Status (color-coded)

4. **Failed Jobs Details Section** (if any failures)
   - Detailed error messages
   - Resource information
   - Failure timestamps

## Report Output Location

Reports are saved to S3 with the following path structure:
```
s3://bucket-name/YYYY/MM/customer-backup-status-report-YYYY-MM-DD.pdf
```

Example:
```
s3://backup-reports-abc123/2024/01/acme-corporation-backup-status-report-2024-01-15.pdf
```

## Build Instructions

### Build with Docker (Recommended)

```bash
cd modules/backup_reporter
docker build -t backup-reporter-build .
docker run --rm -v $(pwd):/out backup-reporter-build cp /tmp/lambda_package.zip /out/lambda_package.zip
```

### Manual Build

```bash
cd modules/backup_reporter
pip install --target . -r requirements.txt
zip -r lambda_package.zip .
```

## IAM Permissions

The Lambda function is automatically granted the following permissions:

- **AWS Backup**: List and describe backup jobs, list tags
- **S3**: Write reports to the designated bucket
- **CloudWatch Logs**: Create and write to log streams
- **STS**: Get caller identity for account information

## Python Dependencies

- boto3 (AWS SDK)
- fpdf (PDF generation)

## Notes

- The module automatically creates a unique S3 bucket name using the provided prefix
- Failed backup jobs are highlighted in red and detailed in a separate section
- Resource names are retrieved from the "Name" tag when available
- The report generation runs on a schedule (default: daily at 8 AM UTC)
- S3 lifecycle policies help manage storage costs by transitioning old reports to Glacier
- The Lambda function requires Python 3.12 runtime