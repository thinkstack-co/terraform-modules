# AWS Backup Custom Module Troubleshooting Guide

## Common Issues and Solutions

### 1. Backups Not Running / No Backup Jobs Created

**Symptoms:**
- Backup plans and vaults are created successfully
- No backup jobs appear in AWS Backup console
- No errors in Terraform apply

**Common Causes and Solutions:**

#### A. IAM Role Missing Permissions

The backup selection IAM role needs additional permissions to discover and backup resources.

**Fix:** Add a policy for resource discovery:

```hcl
# Add this to your backup selection role
resource "aws_iam_role_policy" "backup_selection_permissions" {
  name = "${var.role_name}-backup-permissions"
  role = aws_iam_role.backup_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # EC2 permissions
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:DescribeTags",
          
          # RDS permissions
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBSnapshots",
          "rds:CreateDBSnapshot",
          "rds:CreateDBClusterSnapshot",
          "rds:AddTagsToResource",
          "rds:ListTagsForResource",
          
          # EFS permissions
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:CreateBackup",
          "elasticfilesystem:DescribeBackups",
          
          # DynamoDB permissions
          "dynamodb:DescribeTable",
          "dynamodb:CreateBackup",
          "dynamodb:ListBackups",
          "dynamodb:ListTables",
          
          # S3 permissions (if using S3 backups)
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucketVersions",
          
          # Tag permissions for selection
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues"
        ]
        Resource = "*"
      }
    ]
  })
}
```

#### B. No Resources Match Selection Criteria

**Check:** Ensure your resources have the correct tags.

```bash
# Check if resources have the required tags
aws ec2 describe-instances --filters "Name=tag:HourlyBackup,Values=true" --query 'Reservations[].Instances[].InstanceId'
```

**Fix:** Tag your resources correctly:

```hcl
resource "aws_instance" "example" {
  # ... instance configuration ...
  
  tags = {
    Name         = "MyServer"
    HourlyBackup = "true"  # Must match your server_selection_value
  }
}
```

#### C. Incorrect Tag Key/Value Configuration

**Check your backup plan configuration:**

```hcl
# In your backup plan module
server_selection_tag   = "HourlyBackup"  # The tag key
server_selection_value = "true"          # The tag value
```

**Common mistakes:**
- Case sensitivity: `HourlyBackup` ≠ `hourlybackup`
- Value mismatch: `"true"` ≠ `"True"` ≠ `true` (boolean)
- Spaces in values: `"true "` ≠ `"true"`

#### D. Backup Schedule Not Yet Triggered

**Note:** Cron expressions run in UTC time zone.

```hcl
# This runs at 3 AM UTC, not local time
hourly_schedule = "cron(0 * * * ? *)"  # Every hour at :00
```

**To test immediately:** Create a test plan with a near-future schedule:

```hcl
# Run 5 minutes from now (adjust the minute value)
test_schedule = "cron(30 15 * * ? *)"  # Runs at 15:30 UTC
```

### 2. Backup Jobs Failing

**Check CloudTrail logs for detailed error messages:**

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=StartBackupJob \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --query 'Events[?contains(CloudTrailEvent, `"errorCode"`)].CloudTrailEvent' \
  --output text | jq '.'
```

**Common failure reasons:**
- KMS key permissions (if using custom KMS keys)
- Backup vault access denied
- Resource in incompatible state (e.g., RDS instance being modified)

### 3. Debugging Steps

#### Step 1: Verify IAM Role Trust Relationship

```bash
# Get the role ARN from Terraform output
aws iam get-role --role-name your-backup-role-name --query 'Role.AssumeRolePolicyDocument'
```

Should show:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "backup.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
```

#### Step 2: Check Backup Plan Status

```bash
# List all backup plans
aws backup list-backup-plans --query 'BackupPlansList[*].[BackupPlanName,BackupPlanId]' --output table

# Get details of a specific plan
aws backup get-backup-plan --backup-plan-id YOUR_PLAN_ID
```

#### Step 3: Check Backup Selection

```bash
# List selections for a plan
aws backup list-backup-selections --backup-plan-id YOUR_PLAN_ID

# Get selection details
aws backup get-backup-selection --backup-plan-id YOUR_PLAN_ID --selection-id YOUR_SELECTION_ID
```

#### Step 4: Manually Trigger a Backup Job

```bash
# Start a backup job manually to test
aws backup start-backup-job \
  --backup-vault-name your-vault-name \
  --resource-arn arn:aws:ec2:region:account:instance/i-1234567890abcdef0 \
  --iam-role-arn arn:aws:iam::account:role/your-backup-role
```

### 4. Quick Fixes

#### Enable CloudWatch Logs for Better Debugging

Add this to your backup plan:

```hcl
# In main.tf of the root module
resource "aws_cloudwatch_log_group" "backup_logs" {
  name              = "/aws/backup/${var.project_name}"
  retention_in_days = 7
}

# Grant AWS Backup permission to write logs
resource "aws_iam_role_policy" "backup_cloudwatch" {
  name = "${var.project_name}-backup-cloudwatch"
  role = module.backup_iam_role.role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}
```

#### Test with a Simple Configuration

Create a minimal test to isolate issues:

```hcl
# test_backup.tf
resource "aws_backup_vault" "test" {
  name = "test-vault"
}

resource "aws_backup_plan" "test" {
  name = "test-plan"

  rule {
    rule_name         = "test-rule"
    target_vault_name = aws_backup_vault.test.name
    schedule          = "cron(0/30 * * * ? *)"  # Every 30 minutes

    lifecycle {
      delete_after = 1
    }
  }
}

resource "aws_backup_selection" "test" {
  iam_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/backup.amazonaws.com/AWSServiceRoleForBackup"
  name         = "test-selection"
  plan_id      = aws_backup_plan.test.id

  resources = [
    aws_instance.test.arn
  ]
}

resource "aws_instance" "test" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  
  tags = {
    Name = "backup-test-instance"
  }
}
```

### 5. AWS Backup Service Limitations

Be aware of these limitations:
- First backup job may take up to 1 hour after schedule time
- Some resources need specific states (e.g., RDS must be "available")
- Cross-region copies require both regions to support AWS Backup
- Tag-based selection has eventual consistency (may take a few minutes)

### 6. Contact Support

If issues persist after trying these solutions:
1. Check AWS Service Health Dashboard
2. Open an AWS Support case with:
   - Backup plan ID
   - Vault name
   - Resource ARNs
   - IAM role ARN
   - CloudTrail logs