# AWS Backup IAM Role Module for Gold Backup Plan
# Creates the IAM role and policies required for AWS Backup operations

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

# IAM role that AWS Backup uses to authenticate when backing up resources
resource "aws_iam_role" "backup_role" {
  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = ["backup.amazonaws.com"]
        }
      }
    ]
  })
  tags = var.tags
}

# Attach the AWS managed backup policy
resource "aws_iam_role_policy_attachment" "backup_policy_attach" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# Attach the AWS managed restore policy
resource "aws_iam_role_policy_attachment" "restore_policy_attach" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Optional: S3 backup policy (for S3 bucket backups)
resource "aws_iam_role_policy_attachment" "s3_backup_policy_attach" {
  count      = var.enable_s3_backup ? 1 : 0
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
}

# Optional: S3 restore policy (for S3 bucket restores)
resource "aws_iam_role_policy_attachment" "s3_restore_policy_attach" {
  count      = var.enable_s3_backup ? 1 : 0
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
}

# Policy for tag-based resource selection (required for tag-based backup selections)
resource "aws_iam_policy" "tag_based_backup_policy" {
  count       = var.enable_tag_based_selection ? 1 : 0
  name        = "${var.role_name}-TagBasedBackupPolicy"
  description = "Policy to allow AWS Backup to select resources based on tags"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the tag-based selection policy
resource "aws_iam_role_policy_attachment" "tag_policy_attach" {
  count      = var.enable_tag_based_selection ? 1 : 0
  role       = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.tag_based_backup_policy[0].arn
}

# Attach any additional user-specified policies
resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each   = toset(var.additional_policy_arns)
  role       = aws_iam_role.backup_role.name
  policy_arn = each.value
}

# Policy for resource discovery and backup operations
resource "aws_iam_role_policy" "backup_resource_access" {
  count = var.enable_resource_discovery ? 1 : 0
  name  = "${var.role_name}-resource-access"
  role  = aws_iam_role.backup_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BackupResourceDiscovery"
        Effect = "Allow"
        Action = [
          # EC2 permissions
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeImages",
          "ec2:DescribeTags",
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:CreateImage",

          # RDS permissions
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:DescribeDBSnapshots",
          "rds:DescribeDBClusterSnapshots",
          "rds:ListTagsForResource",
          "rds:CreateDBSnapshot",
          "rds:CreateDBClusterSnapshot",
          "rds:AddTagsToResource",

          # EFS permissions
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeBackups",
          "elasticfilesystem:CreateBackup",
          "elasticfilesystem:TagResource",

          # DynamoDB permissions
          "dynamodb:ListTables",
          "dynamodb:DescribeTable",
          "dynamodb:ListTagsOfResource",
          "dynamodb:CreateBackup",
          "dynamodb:DescribeBackup",
          "dynamodb:ListBackups",

          # S3 permissions (if S3 backup is enabled)
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetBucketTagging",
          "s3:GetBucketAcl",

          # FSx permissions
          "fsx:DescribeFileSystems",
          "fsx:DescribeBackups",
          "fsx:CreateBackup",
          "fsx:TagResource",

          # Storage Gateway permissions
          "storagegateway:ListVolumes",
          "storagegateway:DescribeCachediSCSIVolumes",
          "storagegateway:DescribeStorediSCSIVolumes",

          # Backup permissions
          "backup:DescribeBackupVault",
          "backup:ListBackupVaults",
          "backup:ListBackupPlans",
          "backup:ListBackupSelections",
          "backup:GetBackupPlan",
          "backup:GetBackupSelection",
          "backup:ListRecoveryPointsByBackupVault",
          "backup:StartBackupJob",
          "backup:DescribeBackupJob"
        ]
        Resource = "*"
      }
    ]
  })
}
