terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

###########################
# Data Sources
###########################

# Purpose: Account ID used in the KMS key policy's root principal below.
data "aws_caller_identity" "current" {}

###########################
# KMS Encryption Key
###########################

resource "aws_kms_key" "rds" {
  customer_master_key_spec = var.key_customer_master_key_spec
  description              = var.key_description
  deletion_window_in_days  = var.key_deletion_window_in_days
  enable_key_rotation      = var.key_enable_key_rotation
  key_usage                = var.key_usage
  is_enabled               = var.key_is_enabled
  tags                     = var.tags
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
        "Sid"    = "Allow RDS to encrypt logs",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "rds.amazonaws.com"
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
          "StringEquals" = {
            "kms:ViaService" = "rds.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "rds" {
  name_prefix   = var.key_name_prefix
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_rds_cluster" "cluster" {
  apply_immediately                   = var.apply_immediately
  availability_zones                  = var.availability_zones
  backup_retention_period             = var.backup_retention_period
  cluster_identifier                  = var.cluster_identifier
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  database_name                       = var.database_name
  deletion_protection                 = var.deletion_protection
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  db_subnet_group_name                = var.db_subnet_group_name
  db_cluster_parameter_group_name     = var.db_cluster_parameter_group_name
  engine                              = var.engine
  engine_mode                         = var.engine_mode
  engine_version                      = var.engine_version
  iam_roles                           = var.iam_roles
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  kms_key_id                          = aws_kms_key.rds.arn
  manage_master_user_password         = var.manage_master_user_password
  master_password                     = var.manage_master_user_password ? null : var.master_password
  master_user_secret_kms_key_id       = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null
  master_username                     = var.master_username
  port                                = var.port
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  skip_final_snapshot                 = var.skip_final_snapshot
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  vpc_security_group_ids              = var.vpc_security_group_ids

  # Fail early if neither a static password nor RDS-managed password is configured.
  lifecycle {
    precondition {
      condition     = var.manage_master_user_password || var.master_password != null
      error_message = "Set master_password, or enable manage_master_user_password to have RDS manage it in Secrets Manager."
    }
  }
}
