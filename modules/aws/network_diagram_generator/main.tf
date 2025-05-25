terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

resource "aws_s3_bucket" "diagram" {
  bucket        = "${var.s3_bucket_prefix}-${random_id.suffix.hex}"
  force_destroy = true # Consider changing for production
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_iam_role" "lambda" {
  name               = "${var.name}-diagram-lambda-role"
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
  name   = "${var.name}-diagram-lambda-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid = "EC2ReadAccess"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeInstances",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
  statement {
    sid = "ELBReadAccess"
    actions = [
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeTags"
    ]
    resources = ["*"]
  }
  statement {
    sid = "WAFReadAccess"
    actions = [
      "wafv2:ListWebACLs",
      "wafv2:ListResourcesForWebACL",
      "wafv2:GetWebACL",
      "waf:ListWebACLs",
      "waf:GetWebACL"
    ]
    resources = ["*"]
  }
  statement {
    sid = "S3ReadAccess"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"] # Be cautious with wildcard S3 read access
  }
  statement {
    sid       = "S3WriteAccessToDiagramBucket"
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.diagram.id}/*"]
  }
  statement {
    sid       = "CloudWatchLogsAccess"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_region" "current" {}

locals {
  public_graphviz_layers = {
    "us-east-1"      = "arn:aws:lambda:us-east-1:764866452798:layer:graphviz:12"
    "us-east-2"      = "arn:aws:lambda:us-east-2:764866452798:layer:graphviz:12"
    "us-west-1"      = "arn:aws:lambda:us-west-1:764866452798:layer:graphviz:12"
    "us-west-2"      = "arn:aws:lambda:us-west-2:764866452798:layer:graphviz:12"
    "af-south-1"     = "arn:aws:lambda:af-south-1:764866452798:layer:graphviz:12"
    "ap-east-1"      = "arn:aws:lambda:ap-east-1:764866452798:layer:graphviz:12"
    "ap-south-1"     = "arn:aws:lambda:ap-south-1:764866452798:layer:graphviz:12"
    "ap-northeast-2" = "arn:aws:lambda:ap-northeast-2:764866452798:layer:graphviz:12"
    "ap-southeast-1" = "arn:aws:lambda:ap-southeast-1:764866452798:layer:graphviz:12"
    "ap-southeast-2" = "arn:aws:lambda:ap-southeast-2:764866452798:layer:graphviz:12"
    "ap-northeast-1" = "arn:aws:lambda:ap-northeast-1:764866452798:layer:graphviz:12"
    "ca-central-1"   = "arn:aws:lambda:ca-central-1:764866452798:layer:graphviz:12"
    "eu-central-1"   = "arn:aws:lambda:eu-central-1:764866452798:layer:graphviz:12"
    "eu-west-1"      = "arn:aws:lambda:eu-west-1:764866452798:layer:graphviz:12"
    "eu-west-2"      = "arn:aws:lambda:eu-west-2:764866452798:layer:graphviz:12"
    "eu-south-1"     = "arn:aws:lambda:eu-south-1:764866452798:layer:graphviz:12"
    "eu-west-3"      = "arn:aws:lambda:eu-west-3:764866452798:layer:graphviz:12"
    "eu-north-1"     = "arn:aws:lambda:eu-north-1:764866452798:layer:graphviz:12"
    "me-south-1"     = "arn:aws:lambda:me-south-1:764866452798:layer:graphviz:12"
    "sa-east-1"      = "arn:aws:lambda:sa-east-1:764866452798:layer:graphviz:12"
  }
  current_region             = data.aws_region.current.name
  use_public_graphviz_layer  = contains(keys(local.public_graphviz_layers), local.current_region)
  public_graphviz_layer_arn  = local.use_public_graphviz_layer ? local.public_graphviz_layers[local.current_region] : null
  graphviz_layer_arn_final   = local.use_public_graphviz_layer ? local.public_graphviz_layer_arn : aws_lambda_layer_version.graphviz_local[0].arn
}

resource "aws_lambda_layer_version" "graphviz_local" {
  count = local.use_public_graphviz_layer ? 0 : 1

  filename            = "${path.module}/lambda/layer/graphviz_layer.zip"
  layer_name          = "${var.name}-graphviz-layer-local"
  compatible_runtimes = ["python3.11"]
  source_code_hash    = filebase64sha256("${path.module}/lambda/layer/graphviz_layer.zip")
}

resource "aws_lambda_function" "diagram" {
  function_name = "${var.name}-network-diagram"
  role          = aws_iam_role.lambda.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.11"
  timeout       = 300 # 5 minutes, adjust as needed
  memory_size   = 512 # Adjust as needed

  filename         = "${path.module}/lambda/function.zip" # Assumes function.zip is pre-built
  source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")

  layers = [
    local.graphviz_layer_arn_final
  ]
  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.diagram.bucket
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.diagram.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "scheduled" {
  name                = "${var.name}-diagram-schedule"
  description         = "Trigger network diagram generation"
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.scheduled.name
  target_id = "diagram-lambda"
  arn       = aws_lambda_function.diagram.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.diagram.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled.arn
}