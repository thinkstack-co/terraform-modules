# AWS Backup Status Reporter Module - main.tf
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  customer_identifier = var.customer_name != "" ? var.customer_name : "AWS Account ${data.aws_caller_identity.current.account_id}"
  
  # Build vault names from prefix or use explicit overrides
  hourly_vault_name  = var.hourly_vault_name != "" ? var.hourly_vault_name : "${var.vault_name_prefix}hourly"
  daily_vault_name   = var.daily_vault_name != "" ? var.daily_vault_name : "${var.vault_name_prefix}daily"
  weekly_vault_name  = var.weekly_vault_name != "" ? var.weekly_vault_name : "${var.vault_name_prefix}weekly"
  monthly_vault_name = var.monthly_vault_name != "" ? var.monthly_vault_name : "${var.vault_name_prefix}monthly"
  yearly_vault_name  = var.yearly_vault_name != "" ? var.yearly_vault_name : "${var.vault_name_prefix}yearly"
}

# S3 bucket for backup reports
# This bucket stores the generated PDF backup status reports
resource "aws_s3_bucket" "backup_report" {
  bucket_prefix = var.s3_bucket_prefix
  tags          = merge(var.tags, { 
    Customer = local.customer_identifier,
    Purpose  = "backup-status-reports"
  })
}

# S3 Block Public Access
# This resource ensures that all forms of public access to the backup report bucket are blocked
resource "aws_s3_bucket_public_access_block" "backup_report_block" {
  bucket                  = aws_s3_bucket.backup_report.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
# This manages the lifecycle of objects (PDF reports) in the bucket
resource "aws_s3_bucket_lifecycle_configuration" "backup_report_lifecycle" {
  count  = var.enable_s3_lifecycle_rules ? 1 : 0
  bucket = aws_s3_bucket.backup_report.id

  rule {
    id     = "backup-reports-lifecycle"
    status = "Enabled"

    filter {}

    expiration {
      days = var.report_retention_days
    }

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }
  }

  dynamic "rule" {
    for_each = var.enable_glacier_transition && var.glacier_retention_days > 0 ? [1] : []
    content {
      id     = "backup-reports-glacier-expiration"
      status = "Enabled"
      filter {}
      expiration {
        days = var.glacier_retention_days
      }
    }
  }
}

# IAM Role for Lambda
# This IAM role allows the Lambda function to assume execution permissions
resource "aws_iam_role" "backup_reporter" {
  name = var.lambda_function_name != "" ? "${var.lambda_function_name}-role" : "backup-status-reporter-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = merge(var.tags, { 
    Customer = local.customer_identifier,
    Purpose  = "backup-status-reporter"
  })
}

# IAM Policy for Lambda
# This inline policy grants the Lambda function permissions to access AWS Backup, write to S3, and log to CloudWatch
resource "aws_iam_role_policy" "backup_reporter_policy" {
  name = "backup-reporter-lambda-policy"
  role = aws_iam_role.backup_reporter.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "backup:ListBackupJobs",
          "backup:ListTags",
          "backup:DescribeBackupJob",
          "backup:ListBackupVaults",
          "backup:DescribeBackupVault"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = [
          "${aws_s3_bucket.backup_report.arn}/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = ["sts:GetCallerIdentity"],
        Resource = "*"
      }
    ]
  })
}

# Lambda Function
# This Lambda function generates the backup status report PDF and uploads it to the S3 bucket
resource "aws_lambda_function" "backup_reporter" {
  function_name    = var.lambda_function_name != "" ? var.lambda_function_name : "aws-backup-status-reporter"
  role             = aws_iam_role.backup_reporter.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  filename         = var.lambda_package_path != "" ? var.lambda_package_path : "${path.module}/../lambda_package.zip"
  source_code_hash = filebase64sha256(var.lambda_package_path != "" ? var.lambda_package_path : "${path.module}/../lambda_package.zip")
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  
  environment {
    variables = {
      REPORT_BUCKET         = aws_s3_bucket.backup_report.id
      CUSTOMER_IDENTIFIER   = local.customer_identifier
      VAULT_NAME_PREFIX     = var.vault_name_prefix
      REPORT_DAYS           = tostring(var.report_days)
      VAULT_SORT_ORDER      = var.vault_sort_order
      
      # Enable/disable specific vault reporting
      ENABLE_HOURLY_REPORT  = tostring(var.enable_hourly_report)
      ENABLE_DAILY_REPORT   = tostring(var.enable_daily_report)
      ENABLE_WEEKLY_REPORT  = tostring(var.enable_weekly_report)
      ENABLE_MONTHLY_REPORT = tostring(var.enable_monthly_report)
      ENABLE_YEARLY_REPORT  = tostring(var.enable_yearly_report)
      
      # Vault name overrides
      HOURLY_VAULT_NAME     = local.hourly_vault_name
      DAILY_VAULT_NAME      = local.daily_vault_name
      WEEKLY_VAULT_NAME     = local.weekly_vault_name
      MONTHLY_VAULT_NAME    = local.monthly_vault_name
      YEARLY_VAULT_NAME     = local.yearly_vault_name
    }
  }
  
  tags = merge(var.tags, { 
    Customer = local.customer_identifier,
    Purpose  = "backup-status-reporter"
  })
}

# CloudWatch Event Rule (Schedule)
# This rule triggers the Lambda function on a schedule (e.g., daily)
resource "aws_cloudwatch_event_rule" "backup_report_schedule" {
  name                = var.lambda_function_name != "" ? "${var.lambda_function_name}-schedule" : "aws-backup-report-schedule"
  description         = "Triggers the AWS backup status report Lambda function"
  schedule_expression = var.schedule_expression
  tags                = merge(var.tags, { 
    Customer = local.customer_identifier,
    Purpose  = "backup-status-reporter"
  })
}

# CloudWatch Event Target
# This target connects the scheduled CloudWatch event to the Lambda function
resource "aws_cloudwatch_event_target" "backup_report_lambda_target" {
  rule      = aws_cloudwatch_event_rule.backup_report_schedule.name
  target_id = "aws-backup-report-lambda-target"
  arn       = aws_lambda_function.backup_reporter.arn
}

# Lambda Permission for CloudWatch Events
# This resource grants CloudWatch Events permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup_reporter.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.backup_report_schedule.arn
}

# CloudWatch Log Group for Lambda
# This creates a log group with retention settings for Lambda logs
resource "aws_cloudwatch_log_group" "backup_reporter" {
  name              = "/aws/lambda/${aws_lambda_function.backup_reporter.function_name}"
  retention_in_days = var.log_retention_days
  
  tags = merge(var.tags, { 
    Customer = local.customer_identifier,
    Purpose  = "backup-status-reporter-logs"
  })
}