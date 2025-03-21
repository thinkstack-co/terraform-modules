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
  
  # Fixed schedule for the monthly summary email - always on the 1st of the month at 8:15 AM UTC
  monthly_summary_schedule = "cron(15 8 1 * ? *)"
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

# CloudWatch Event Rule for Compliance Report
resource "aws_cloudwatch_event_rule" "compliance_report" {
  count               = var.create_compliance_report ? 1 : 0
  name                = "${var.config_recorder_name}-${var.report_frequency}-compliance-report"
  description         = "Triggers to generate a ${var.report_frequency} compliance report"
  schedule_expression = local.report_schedule
  tags                = var.tags
}

# CloudWatch Event Target for Compliance Report
resource "aws_cloudwatch_event_target" "compliance_report" {
  count     = var.create_compliance_report ? 1 : 0
  rule      = aws_cloudwatch_event_rule.compliance_report[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.config_notifications.arn
  
  input_transformer {
    input_paths = {
      time = "$.time"
    }
    input_template = <<EOF
{
  "Subject": "${local.customer_identifier} - AWS Config ${title(var.report_frequency)} Compliance Report - $(time)",
  "Message": "This is an automated ${var.report_frequency} report of AWS Config compliance status for ${local.customer_identifier}.\n\nReports are stored in S3 bucket: ${aws_s3_bucket.config_bucket.id}/${local.s3_key_prefix_with_date}/\n\nPlease review the AWS Config dashboard for a list of non-compliant resources: https://console.aws.amazon.com/config/home"
}
EOF
  }
}

# CloudWatch Event Rule for Monthly Summary Email
resource "aws_cloudwatch_event_rule" "monthly_summary_email" {
  name                = "${var.config_recorder_name}-monthly-summary-email"
  description         = "Triggers on the 1st of each month to send a summary email with a link to the previous month's reports"
  schedule_expression = local.monthly_summary_schedule
  tags                = var.tags
}

# CloudWatch Event Target for Monthly Summary Email
resource "aws_cloudwatch_event_target" "monthly_summary_email" {
  rule      = aws_cloudwatch_event_rule.monthly_summary_email.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.config_notifications.arn
  
  input_transformer {
    input_paths = {
      time = "$.time"
    }
    input_template = <<EOF
{
  "Subject": "${local.customer_identifier} - AWS Config Monthly Summary - $(time)",
  "Message": "This is an automated monthly summary of AWS Config compliance reports for ${local.customer_identifier}.\n\nAll reports from the previous month (${local.previous_month_folder}) are available in the following S3 location:\n\nBucket: ${aws_s3_bucket.config_bucket.id}\nFolder: ${local.previous_month_path}/\n\nPlease review the AWS Config dashboard for a complete view of your compliance status: https://console.aws.amazon.com/config/home"
}
EOF
  }
}

# AWS Config Delivery Channel
resource "aws_config_delivery_channel" "config" {
  name           = var.config_recorder_name
  s3_bucket_name = aws_s3_bucket.config_bucket.id
  s3_key_prefix  = local.s3_key_prefix_with_date
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

# Lambda function for processing Config snapshots
# This is only created if enable_config_processor is set to true
resource "aws_lambda_function" "config_processor" {
  count         = var.enable_config_processor ? 1 : 0
  function_name = "${var.config_recorder_name}-config-processor"
  description   = "Processes AWS Config snapshots into readable formats"
  
  filename      = "${path.module}/files/config_processor.py.zip"
  source_code_hash = data.archive_file.config_processor[0].output_base64sha256
  
  runtime       = "python3.9"
  handler       = "config_processor.lambda_handler"
  timeout       = 300
  memory_size   = 512
  
  role          = aws_iam_role.config_processor[0].arn
  
  environment {
    variables = {
      GENERATE_SUMMARY = tostring(var.config_processor_generate_summary)
    }
  }
  
  tags = var.tags
}

# Archive file for Lambda function
data "archive_file" "config_processor" {
  count       = var.enable_config_processor ? 1 : 0
  type        = "zip"
  source_file = "${path.module}/files/config_processor.py"
  output_path = "${path.module}/files/config_processor.py.zip"
}

# IAM role for the Lambda function
resource "aws_iam_role" "config_processor" {
  count       = var.enable_config_processor ? 1 : 0
  name        = "${var.config_recorder_name}-config-processor-role"
  description = "Role for the AWS Config snapshot processor Lambda function"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.tags
}

# IAM policy for the Lambda function
resource "aws_iam_policy" "config_processor" {
  count       = var.enable_config_processor ? 1 : 0
  name        = "${var.config_recorder_name}-config-processor-policy"
  description = "Policy for the AWS Config snapshot processor Lambda function"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.config_bucket.arn,
          "${aws_s3_bucket.config_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "config_processor" {
  count      = var.enable_config_processor ? 1 : 0
  role       = aws_iam_role.config_processor[0].name
  policy_arn = aws_iam_policy.config_processor[0].arn
}

# S3 event notification to trigger Lambda
resource "aws_s3_bucket_notification" "config_processor" {
  count  = var.enable_config_processor ? 1 : 0
  bucket = aws_s3_bucket.config_bucket.id
  
  lambda_function {
    lambda_function_arn = aws_lambda_function.config_processor[0].arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_key_prefix
    filter_suffix       = ".json.json"
  }

  depends_on = [aws_lambda_permission.config_processor]
}

# Lambda permission for S3 to invoke the function
resource "aws_lambda_permission" "config_processor" {
  count         = var.enable_config_processor ? 1 : 0
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.config_processor[0].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.config_bucket.arn
}
