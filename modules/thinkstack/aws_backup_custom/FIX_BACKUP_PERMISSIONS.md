# Quick Fix for AWS Backup Permissions Issues

If you have already deployed the AWS Backup module and backups are not running, follow these steps to fix the IAM permissions.

## Option 1: Update the Module (Recommended)

Update your module call to enable resource discovery:

```hcl
# In your existing code, update the backup_iam_role module:
module "backup_iam_role" {
  source = "../../modules/aws_backup_iam_role"

  role_name                  = "${var.project_name}-backup-role"
  enable_tag_based_selection = true
  enable_resource_discovery  = true  # Add this line
  enable_s3_backup          = true   # Add this if backing up S3
  
  tags = var.tags
}
```

Then run:
```bash
terraform plan
terraform apply
```

## Option 2: Manual IAM Policy Addition

If you can't update the module immediately, add this policy to your existing backup role:

1. Find your backup role ARN from Terraform outputs or AWS Console
2. Create a new IAM policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "BackupResourceDiscovery",
            "Effect": "Allow",
            "Action": [
                "tag:GetResources",
                "tag:GetTagKeys",
                "tag:GetTagValues",
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:DescribeTags",
                "rds:DescribeDBInstances",
                "rds:DescribeDBClusters",
                "rds:ListTagsForResource",
                "elasticfilesystem:DescribeFileSystems",
                "dynamodb:ListTables",
                "dynamodb:DescribeTable",
                "dynamodb:ListTagsOfResource",
                "s3:ListAllMyBuckets",
                "s3:GetBucketTagging",
                "backup:ListBackupVaults",
                "backup:DescribeBackupVault"
            ],
            "Resource": "*"
        }
    ]
}
```

3. Attach this policy to your backup role using AWS CLI:

```bash
# First, create the policy
aws iam create-policy \
  --policy-name BackupResourceDiscoveryPolicy \
  --policy-document file://policy.json

# Then attach it to your role (replace YOUR_ROLE_NAME)
aws iam attach-role-policy \
  --role-name YOUR_ROLE_NAME \
  --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/BackupResourceDiscoveryPolicy
```

## Option 3: Terraform Quick Fix

Add this to your Terraform configuration as a temporary fix:

```hcl
# Get the existing role data
data "aws_iam_role" "existing_backup_role" {
  name = "YOUR-EXISTING-BACKUP-ROLE-NAME"  # Replace with your role name
}

# Add the missing policy
resource "aws_iam_role_policy" "backup_fix" {
  name = "backup-resource-discovery-fix"
  role = data.aws_iam_role.existing_backup_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BackupResourceDiscovery"
        Effect = "Allow"
        Action = [
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource",
          "elasticfilesystem:DescribeFileSystems",
          "dynamodb:ListTables",
          "dynamodb:DescribeTable",
          "dynamodb:ListTagsOfResource",
          "s3:ListAllMyBuckets",
          "s3:GetBucketTagging",
          "backup:ListBackupVaults",
          "backup:DescribeBackupVault"
        ]
        Resource = "*"
      }
    ]
  })
}
```

## Verification Steps

After applying the fix:

1. Check if the backup job starts within the next scheduled window
2. Monitor AWS Backup console for job status
3. Check CloudTrail for any permission errors

```bash
# Check backup jobs
aws backup list-backup-jobs --by-state RUNNING

# Check for recent backup job attempts
aws backup list-backup-jobs \
  --by-created-after $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --query 'BackupJobs[*].[BackupJobId,State,StatusMessage]' \
  --output table
```

## Common Issues After Fix

1. **Still no backups**: Verify your resources have the correct tags
2. **Partial backups**: Some resource types may need additional permissions
3. **S3 backups failing**: Ensure you set `enable_s3_backup = true`

## Need More Help?

Check the [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) guide for comprehensive debugging steps.