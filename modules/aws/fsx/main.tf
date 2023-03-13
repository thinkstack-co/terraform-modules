terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

###########################
# Data Sources
###########################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

########################################
# KMS Keys
########################################
####################
# FSX Key
####################
resource "aws_kms_key" "fsx" {
  description             = var.fsx_key_description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  key_usage               = var.key_usage
  is_enabled              = var.is_enabled
  tags                    = var.tags
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Sid"    = "Enable IAM User Permissions",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action"   = "kms:*",
        "Resource" = "*"
      },
      {
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "fsx.${data.aws_region.current.name}.amazonaws.com"
        },
        "Action" = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:DescribeKey"
        ],
        "Resource" = "*",
      }
    ]
  })
}

resource "aws_kms_alias" "fsx_alias" {
  name          = var.fsx_key_name
  target_key_id = aws_kms_key.cloudwatch.key_id
}

####################
# Cloudwatch Key
####################
resource "aws_kms_key" "cloudwatch" {
  description             = var.fsx_cloudwatch_key_description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  key_usage               = var.key_usage
  is_enabled              = var.is_enabled
  tags                    = var.tags
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Sid"    = "Enable IAM User Permissions",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action"   = "kms:*",
        "Resource" = "*"
      },
      {
        "Sid"    = "Grant access to CMK manager",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonFSxManager"
        },
        "Action" = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        "Resource" = "*"
      },
      {
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "logs.${data.aws_region.current.name}.amazonaws.com"
        },
        "Action" = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" = "*",
        "Condition" = {
          "ArnEquals" = {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "cloudwatch_alias" {
  name          = var.fsx_key_name
  target_key_id = aws_kms_key.cloudwatch.key_id
}


########################################
# FSx Instance
########################################

resource "aws_fsx_windows_file_system" "fsx" {
  kms_key_id                        = aws_kms_key.fsx.arn
  storage_capacity                  = var.storage_capacity
  subnet_ids                        = var.subnet_ids
  throughput_capacity               = var.throughput_capacity
  backup_id                         = var.backup_id
  aliases                           = var.aliases
  automatic_backup_retention_days   = var.automatic_backup_retention_days
  copy_tags_to_backups              = var.copy_tags_to_backups
  daily_automatic_backup_start_time = var.daily_automatic_backup_start_time
  security_group_ids                = var.security_group_ids
  skip_final_backup                 = var.skip_final_backup
  tags                              = var.tags
  weekly_maintenance_start_time     = var.weekly_maintenance_start_time
  deployment_type                   = var.deployment_type
  preferred_subnet_id               = var.preferred_subnet_id
  audit_log_configuration {
    audit_log_destination             = aws_cloudwatch_log_group.log_group[0].arn
    file_access_audit_log_level       = var.file_access_audit_log_level
    file_share_access_audit_log_level = var.file_access_audit_log_level
  }
  storage_type = var.storage_type
  # Active Directory Settings
  self_managed_active_directory {
    dns_ips                                = var.dns_ips
    domain_name                            = var.domain_name
    password                               = var.password #should be stored in TF cloud workspace
    username                               = var.username #should be stored in TF cloud workspace
    file_system_administrators_group       = var.file_system_administrators_group
    organizational_unit_distinguished_name = var.organizational_unit_distinguished_name
  }
}

###########################
# CloudWatch Log Group
###########################

resource "aws_cloudwatch_log_group" "log_group" {
  count             = (var.enable_audit_logs == true ? 1 : 0)
  kms_key_id        = aws_kms_key.cloudwatch.arn
  name_prefix       = var.cloudwatch_name_prefix
  retention_in_days = var.cloudwatch_retention_in_days
  tags              = var.tags
}
