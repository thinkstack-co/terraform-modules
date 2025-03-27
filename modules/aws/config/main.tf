# AWS Config Module
# This module sets up AWS Config to enable continuous monitoring and assessment of AWS resource configurations

# Local variables
locals {
  customer_identifier = var.customer_name != "" ? var.customer_name : "AWS Account ${data.aws_caller_identity.current.account_id}"
  
  # Generate the appropriate S3 key prefix based on report frequency
  monthly_folder = formatdate("YYYY-MM", timestamp())
  s3_key_prefix_with_date = "${var.s3_key_prefix}/${local.monthly_folder}"
  
  # For the monthly summary email, calculate the previous month's folder
  previous_month_timestamp = timeadd(timestamp(), "-744h") # Approximately 31 days back
  previous_month_folder = formatdate("YYYY-MM", local.previous_month_timestamp)
  previous_month_path = "${var.s3_key_prefix}/${local.previous_month_folder}"
  
  # Generate the appropriate schedule expression based on report frequency
  report_schedule = var.report_delivery_schedule != "cron(0 8 1 * ? *)" ? var.report_delivery_schedule : (
    var.report_frequency == "daily" ? "cron(0 8 * * ? *)" :  # Daily at 8:00 AM
    var.report_frequency == "weekly" ? "cron(0 8 ? * MON *)" :  # Weekly on Monday at 8:00 AM
    "cron(0 8 1 * ? *)"  # Monthly on the 1st at 8:00 AM (default)
  )
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# AWS Config Recorder
resource "aws_config_configuration_recorder" "config" {
  name     = var.config_recorder_name
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }

  recording_mode {
    recording_frequency = var.recording_frequency
  }
}

# S3 Bucket for AWS Config
resource "aws_s3_bucket" "config_bucket" {
  bucket_prefix = var.config_bucket_prefix
  tags          = var.tags
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "config" {
  bucket = aws_s3_bucket.config_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# S3 Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "config_lifecycle" {
  count  = var.enable_s3_lifecycle_rules ? 1 : 0
  bucket = aws_s3_bucket.config_bucket.id

  rule {
    id     = "config-reports-lifecycle"
    status = "Enabled"
    
    filter {
      prefix = var.s3_key_prefix
    }

    dynamic "transition" {
      for_each = var.enable_glacier_transition && var.glacier_transition_days > 0 ? [1] : []
      content {
        days          = var.glacier_transition_days
        storage_class = "GLACIER"
      }
    }

    dynamic "expiration" {
      for_each = var.report_retention_days > 0 ? [1] : []
      content {
        days = var.report_retention_days
      }
    }
    
    dynamic "noncurrent_version_expiration" {
      for_each = var.report_retention_days > 0 ? [1] : []
      content {
        noncurrent_days = var.report_retention_days
      }
    }
    
    dynamic "noncurrent_version_transition" {
      for_each = var.enable_glacier_transition && var.glacier_transition_days > 0 ? [1] : []
      content {
        noncurrent_days = var.glacier_transition_days
        storage_class   = "GLACIER"
      }
    }
  }

  # If Glacier transition is enabled and we have a separate Glacier retention period
  dynamic "rule" {
    for_each = var.enable_glacier_transition && var.glacier_retention_days > 0 ? [1] : []
    content {
      id     = "config-reports-glacier-expiration"
      status = "Enabled"
      
      filter {
        and {
          prefix = var.s3_key_prefix
          tags = {
            "storage-class" = "GLACIER"
          }
        }
      }
      
      expiration {
        days = var.glacier_retention_days
      }
    }
  }
}

# AWS Config Delivery Channel
resource "aws_config_delivery_channel" "config" {
  name           = var.config_recorder_name
  s3_bucket_name = aws_s3_bucket.config_bucket.id
  s3_key_prefix  = local.s3_key_prefix_with_date

  snapshot_delivery_properties {
    delivery_frequency = var.snapshot_delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.config, aws_s3_bucket_policy.config]
}

# AWS Config Recorder Status
resource "aws_config_configuration_recorder_status" "config" {
  name       = aws_config_configuration_recorder.config.name
  is_enabled = true
  depends_on = [aws_config_configuration_recorder.config, aws_config_delivery_channel.config]
}

# IAM Role for AWS Config
resource "aws_iam_role" "config_role" {
  name = var.config_iam_role_name
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy Attachment for AWS Config
resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# AWS Config Rules
# Only create rules if enabled
resource "aws_config_config_rule" "iam_password_policy" {
  count       = var.enable_config_rules ? 1 : 0
  name        = "${var.config_recorder_name}-iam-password-policy"
  description = "Ensures the account password policy for IAM users meets the specified requirements"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  input_parameters = jsonencode({
    RequireUppercaseCharacters = "true"
    RequireLowercaseCharacters = "true"
    RequireSymbols             = "true"
    RequireNumbers             = "true"
    MinimumPasswordLength      = tostring(var.password_min_length)
    PasswordReusePrevention    = tostring(var.password_reuse_prevention)
    MaxPasswordAge             = tostring(var.password_max_age)
  })

  depends_on = [aws_config_configuration_recorder.config, aws_config_delivery_channel.config]
}

# EBS Encryption Rule
resource "aws_config_config_rule" "ebs_encryption" {
  count       = var.enable_config_rules ? 1 : 0
  name        = "${var.config_recorder_name}-ebs-encryption-enabled"
  description = "Checks whether EBS volumes are encrypted"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  scope {
    compliance_resource_types = ["AWS::EC2::Volume"]
  }

  depends_on = [aws_config_configuration_recorder.config, aws_config_delivery_channel.config]
}
