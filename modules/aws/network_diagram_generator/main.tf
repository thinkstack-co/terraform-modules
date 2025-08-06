terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_s3_bucket" "diagram" {
  bucket = var.s3_bucket_name != null ? var.s3_bucket_name : "${var.name}-network-diagrams-${random_id.suffix.hex}"
  force_destroy = true
  count = var.s3_bucket_name == null ? 1 : 0
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_iam_role" "lambda" {
  name = "${var.name}-diagram-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.name}-diagram-lambda-policy"
  role = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "ec2:Describe*",
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = ["*"]
  }
  statement {
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "null_resource" "build_lambda_package" {
  triggers = {
    main_py_hash         = filemd5("${path.module}/lambda/main.py")
    requirements_hash    = filemd5("${path.module}/lambda/requirements.txt")
    dockerfile_hash      = filemd5("${path.module}/lambda/Dockerfile")
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/lambda && docker build --platform linux/amd64 -t network-diagram-lambda . && docker run --platform linux/amd64 --rm -v ${path.module}/lambda:/output network-diagram-lambda cp /build/lambda_package.zip /output/"
  }
}

resource "aws_lambda_function" "diagram" {
  depends_on = [null_resource.build_lambda_package]
  
  function_name = "${var.name}-network-diagram"
  role          = aws_iam_role.lambda.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.11"
  timeout       = 900
  memory_size   = 512
  filename      = "${path.module}/lambda/lambda_package.zip"
  source_code_hash = null_resource.build_lambda_package.triggers.main_py_hash
  
  environment {
    variables = {
      S3_BUCKET = var.s3_bucket_name != null ? var.s3_bucket_name : aws_s3_bucket.diagram[0].bucket
    }
  }
}

resource "aws_cloudwatch_event_rule" "weekly" {
  name                = "${var.name}-diagram-weekly"
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.weekly.name
  target_id = "diagram-lambda"
  arn       = aws_lambda_function.diagram.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.diagram.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.weekly.arn
}