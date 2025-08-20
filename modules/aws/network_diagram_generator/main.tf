# AWS Network Diagram Generator - Terraform module
# Provisions: optional S3 bucket, IAM role/policy, Lambda function, EventBridge schedule, and invoke permission.
# Notes: The Lambda uses the Python `diagrams` library which requires Graphviz at runtime (typically via a Lambda layer).

terraform {
  required_version = ">= 1.0" # Terraform CLI version constraint
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0" # AWS provider version constraint
    }
  }
}

resource "aws_s3_bucket" "diagram" {
  bucket        = var.s3_bucket_name != null ? var.s3_bucket_name : "${var.name}-network-diagrams-${random_id.suffix.hex}" # Use provided bucket or create unique name with random suffix
  force_destroy = true                                                                                                     # Allow deletion of non-empty bucket (diagrams)
  count         = var.s3_bucket_name == null ? 1 : 0                                                                       # Create bucket only when one isn't provided
}

resource "random_id" "suffix" {
  byte_length = 4 # 8 hex chars suffix for uniqueness
}

resource "aws_iam_role" "lambda" {
  name               = "${var.name}-diagram-lambda-role"                    # Execution role name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json # Trust Lambda service principal
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"] # Allow Lambda to assume this role
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"] # Lambda service principal
    }
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.name}-diagram-lambda-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_policy.json # Inline policy JSON
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "ec2:Describe*", # Discover VPCs/Subnets/Instances
      "s3:PutObject",  # Upload generated diagram to S3
      "s3:GetObject",  # (Optional) Read from S3 if needed
      "s3:ListBucket"  # List target bucket
    ]
    resources = ["*"] # Read/list across region; restrict in production if desired
  }
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"] # CloudWatch Logs for Lambda
    resources = ["arn:aws:logs:*:*:*"]                                               # Any log group/stream in account
  }
}

resource "aws_lambda_function" "diagram" {
  function_name    = "${var.name}-network-diagram"                        # Lambda name
  role             = aws_iam_role.lambda.arn                              # Execution role ARN
  handler          = "main.lambda_handler"                                # Python module.function
  runtime          = "python3.11"                                         # Must match packaged Python version
  timeout          = 900                                                  # Up to 15 minutes; diagrams/Graphviz can take time
  memory_size      = 512                                                  # Increase if Graphviz needs more memory
  filename         = data.archive_file.lambda_package.output_path         # Zip from lambda/ directory
  source_code_hash = data.archive_file.lambda_package.output_base64sha256 # Force update on code changes
  environment {
    variables = {
      S3_BUCKET = var.s3_bucket_name != null ? var.s3_bucket_name : aws_s3_bucket.diagram[0].bucket # Bucket to upload diagram
    }
  }
}

data "archive_file" "lambda_package" {
  type        = "zip"                       # Build a zip from the lambda/ folder contents
  source_dir  = "${path.module}/lambda"     # Package all files in lambda/
  output_path = "${path.module}/lambda.zip" # Zip path written during apply
}

resource "aws_cloudwatch_event_rule" "weekly" {
  name                = "${var.name}-diagram-weekly"
  schedule_expression = var.schedule # Cron; default weekly Sunday 02:00 UTC
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.weekly.name # EventBridge rule to trigger the Lambda
  target_id = "diagram-lambda"                      # Target identifier
  arn       = aws_lambda_function.diagram.arn       # Lambda to invoke
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"                   # Allow Events to invoke Lambda
  function_name = aws_lambda_function.diagram.function_name # Target Lambda
  principal     = "events.amazonaws.com"                    # Events service principal
  source_arn    = aws_cloudwatch_event_rule.weekly.arn      # Specific rule allowed to invoke
}