# AWS Config Module
# This module sets up AWS Config to enable continuous monitoring and assessment of AWS resource configurations

# Local variables
locals {
  customer_identifier = var.customer_name != "" ? var.customer_name : "AWS Account ${data.aws_caller_identity.current.account_id}"
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

# SNS Topic for AWS Config Notifications
resource "aws_sns_topic" "config_notifications" {
  name = "${var.config_recorder_name}-notifications"
  tags = var.tags
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "config_notifications" {
  arn = aws_sns_topic.config_notifications.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowConfigPublish"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.config_notifications.arn
      },
      {
        Sid    = "AllowCloudWatchEventsPublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.config_notifications.arn
      }
    ]
  })
}

# SNS Topic Subscription for Email Notifications
resource "aws_sns_topic_subscription" "config_email_subscription" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.config_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# CloudWatch Event Rule for Monthly Compliance Report
resource "aws_cloudwatch_event_rule" "monthly_compliance_report" {
  count               = var.create_monthly_compliance_report ? 1 : 0
  name                = "${var.config_recorder_name}-monthly-compliance-report"
  description         = "Triggers on the first day of every month to generate a compliance report"
  schedule_expression = "cron(0 8 1 * ? *)" # 8:00 AM on the 1st day of every month
  tags                = var.tags
}

# CloudWatch Event Target for Monthly Compliance Report
resource "aws_cloudwatch_event_target" "monthly_compliance_report" {
  count     = var.create_monthly_compliance_report ? 1 : 0
  rule      = aws_cloudwatch_event_rule.monthly_compliance_report[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.config_notifications.arn
  
  input_transformer {
    input_paths = {
      time = "$.time"
    }
    input_template = <<EOF
{
  "Subject": "${local.customer_identifier} - AWS Config Monthly Compliance Report - $(time)",
  "Message": "This is an automated monthly report of AWS Config compliance status for ${local.customer_identifier}.\n\nPlease review the AWS Config dashboard for a list of non-compliant resources: https://console.aws.amazon.com/config/home"
}
EOF
  }
}

# AWS Config Delivery Channel
resource "aws_config_delivery_channel" "config" {
  name           = var.config_recorder_name
  s3_bucket_name = aws_s3_bucket.config_bucket.id
  s3_key_prefix  = var.s3_key_prefix
  sns_topic_arn  = var.sns_topic_arn != null ? var.sns_topic_arn : aws_sns_topic.config_notifications.arn

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
