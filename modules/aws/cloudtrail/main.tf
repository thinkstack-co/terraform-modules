terraform {
  required_version = ">= 1.0.0"

  # This block specifies the providers and their versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

# Get the caller identity and current region details
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create local references to policy documents
locals {
  cloudtrail_policy_json        = data.aws_iam_policy_document.cloudtrail.json
  cloudtrail_assume_policy_json = data.aws_iam_policy_document.cloudtrail_assume.json
  key_policy_json               = data.aws_iam_policy_document.key_policy.json
  s3_bucket_policy_json         = data.aws_iam_policy_document.s3_bucket_policy.json
}

# Creating a KMS key for encryption 
resource "aws_kms_key" "cloudtrail" {
  description              = var.key_description
  enable_key_rotation      = var.key_enable_key_rotation
  customer_master_key_spec = var.key_customer_master_key_spec
  deletion_window_in_days  = var.key_deletion_window_in_days
  policy                   = local.key_policy_json
  key_usage                = var.key_usage
  is_enabled               = var.key_is_enabled
  tags                     = var.key_tags
}

# Creating an alias for the KMS key
resource "aws_kms_alias" "cloudtrail" {
  name_prefix   = var.key_alias_name_prefix
  target_key_id = aws_kms_key.cloudtrail.key_id
}

# Create CloudWatch Log Group to store CloudTrail logs
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = var.log_group_name
  kms_key_id        = aws_kms_key.cloudtrail.arn      # KMS key ARN for encrypting log data
  retention_in_days = var.log_group_retention_in_days # Log retention period
}

# IAM Policy to allow CloudTrail to write logs
resource "aws_iam_policy" "cloudtrail" {
  description = var.iam_policy_description
  name        = var.iam_policy_name
  path        = var.iam_policy_path
  policy      = local.cloudtrail_policy_json
}

# IAM role for CloudTrail with the above policy attached
resource "aws_iam_role" "cloudtrail" {
  assume_role_policy    = local.cloudtrail_assume_policy_json
  description           = var.iam_role_description
  max_session_duration  = var.iam_role_max_session_duration
  name                  = var.iam_role_name
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = var.iam_role_force_detach_policies
}

resource "aws_iam_role_policy_attachment" "cloudtrail" {
  role       = aws_iam_role.cloudtrail.name
  policy_arn = aws_iam_policy.cloudtrail.arn
}

# CloudTrail resource which logs API activity in the AWS account
resource "aws_cloudtrail" "cloudtrail" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  s3_key_prefix                 = var.cloudtrail_s3_key_prefix
  include_global_service_events = var.cloudtrail_include_global_service_events
  is_multi_region_trail         = var.cloudtrail_is_multi_region_trail
  enable_log_file_validation    = var.cloudtrail_enable_log_file_validation
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail.arn
  kms_key_id                    = var.encrypt_logs ? aws_kms_key.cloudtrail.arn : null
}



# S3 bucket to store CloudTrail logs
resource "aws_s3_bucket" "cloudtrail" {
  bucket_prefix = var.s3_bucket_prefix
  force_destroy = var.s3_force_destroy

  versioning {
    enabled    = var.versioning_enabled
    mfa_delete = var.mfa_delete_enabled # Enables MFA Delete
  }

  lifecycle_rule {
    id      = "log"
    enabled = var.lifecycle_rule_enabled

    transition {
      days          = var.transition_days_standard_ia
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.transition_days_glacier
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      days          = var.noncurrent_version_transition_days_standard_ia
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = var.noncurrent_version_transition_days_glacier
      storage_class = "GLACIER"
    }

    expiration {
      days = var.expiration_days
    }

    noncurrent_version_expiration {
      days = var.noncurrent_version_expiration_days
    }
  }
}

# Enforcing secure transport on the bucket policy
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = local.s3_bucket_policy_json
}

# Blocking public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
