# AWS Cost Report Module - main.tf
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
}


# S3 bucket for cost reports
# This bucket stores the generated PDF cost reports. The bucket name is generated from the prefix to ensure uniqueness.
resource "aws_s3_bucket" "cost_report" {
  bucket_prefix = var.s3_key_prefix
  tags          = merge(var.tags, { Customer = local.customer_identifier })
}

# S3 Block Public Access
# This resource ensures that all forms of public access to the cost report bucket are blocked, preventing accidental or intentional exposure.
resource "aws_s3_bucket_public_access_block" "cost_report_block" {
  bucket                  = aws_s3_bucket.cost_report.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration
# This manages the lifecycle of objects (PDF reports) in the bucket, allowing for automatic expiration and Glacier transitions.
resource "aws_s3_bucket_lifecycle_configuration" "cost_report_lifecycle" {
  count  = var.enable_s3_lifecycle_rules ? 1 : 0
  bucket = aws_s3_bucket.cost_report.id

  rule {
    id     = "cost-reports-lifecycle"
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
      id     = "cost-reports-glacier-expiration"
      status = "Enabled"
      filter {}
      expiration {
        days = var.glacier_retention_days
      }
    }
  }
}

# IAM Role for Lambda
# This IAM role allows the Lambda function to assume execution permissions.
resource "aws_iam_role" "cost_reporter" {
  name = "cost-reporter-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
  tags = merge(var.tags, { Customer = local.customer_identifier })
}

# IAM Policy for Lambda
# This inline policy grants the Lambda function permissions to access Cost Explorer, write to S3, and log to CloudWatch.
resource "aws_iam_role_policy" "cost_reporter_policy" {
  name = "cost-reporter-lambda-policy"
  role = aws_iam_role.cost_reporter.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostAndUsageWithResources"
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
          "${aws_s3_bucket.cost_report.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}


# Lambda Function
# This Lambda function generates the cost report PDF and uploads it to the S3 bucket.
resource "aws_lambda_function" "cost_reporter" {
  function_name = "aws-cost-reporter"
  role          = aws_iam_role.cost_reporter.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename         = "${path.module}/cost_reporter/lambda_package.zip"
  source_code_hash = filebase64sha256("${path.module}/cost_reporter/lambda_package.zip")
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size
  environment {
    variables = {
      REPORT_BUCKET        = aws_s3_bucket.cost_report.id
      REPORT_TAG_KEY       = var.report_tag_key
      SCHEDULE_EXPRESSION  = var.schedule_expression
      CUSTOMER_IDENTIFIER  = local.customer_identifier
    }
  }
  tags = merge(var.tags, { Customer = local.customer_identifier })
}

# CloudWatch Event Rule (Schedule)
# This rule triggers the Lambda function on a schedule (e.g., monthly).
resource "aws_cloudwatch_event_rule" "cost_report_schedule" {
  name                = "aws-cost-report-schedule"
  description         = "Triggers the AWS cost report Lambda function."
  schedule_expression = var.schedule_expression
  tags                = merge(var.tags, { Customer = local.customer_identifier })
}

# CloudWatch Event Target
# CloudWatch Event Target
# This target connects the scheduled CloudWatch event to the Lambda function.
resource "aws_cloudwatch_event_target" "cost_report_lambda_target" {
  rule      = aws_cloudwatch_event_rule.cost_report_schedule.name
  target_id = "aws-cost-report-lambda-target"
  arn       = aws_lambda_function.cost_reporter.arn
}

# Lambda Permission for CloudWatch Events
# This resource grants CloudWatch Events permission to invoke the Lambda function.
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_reporter.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cost_report_schedule.arn
}


# S3 Bucket Data Source
# This data source fetches information about the cost report bucket (not strictly necessary unless you need bucket metadata elsewhere).
data "aws_s3_bucket" "cost_report" {
  bucket = aws_s3_bucket.cost_report.id
}

# (Optional) Output the latest uploaded PDF (key pattern matching)
# S3 Bucket Objects Data Source
# This data source lists all cost report PDFs in the bucket with the specified prefix.
data "aws_s3_bucket_objects" "report_pdfs" {
  bucket = aws_s3_bucket.cost_report.id
  prefix = "cost-report-"
}

# S3 Object Resource (Latest PDF)
# This resource references the latest uploaded PDF report in the bucket, for use in outputs or downstream automation.
resource "aws_s3_object" "cost_report_pdf" {
  bucket = aws_s3_bucket.cost_report.id
  key    = length(data.aws_s3_bucket_objects.report_pdfs.keys) > 0 ? data.aws_s3_bucket_objects.report_pdfs.keys[0] : null
}
