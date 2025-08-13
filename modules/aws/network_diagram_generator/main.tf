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
  bucket_prefix = var.s3_key_prefix
  force_destroy = true

  tags = var.tags
}

resource "aws_iam_role" "lambda" {
  name = "${var.name}-diagram-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = var.tags
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
  # EC2 discovery - specific permissions to match existing policy
  statement {
    sid = "EC2ReadAccess"
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeTags",
      "ec2:DescribeSubnets",
      "ec2:DescribeInstances",
      "ec2:DescribeAvailabilityZones"
    ]
    resources = ["*"]
  }

  # Load balancers - specific permissions to match existing policy
  statement {
    sid = "ELBReadAccess"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeListeners"
    ]
    resources = ["*"]
  }

  # WAF permissions - specific permissions to match existing policy
  statement {
    sid = "WAFReadAccess"
    effect = "Allow"
    actions = [
      "wafv2:ListWebACLs",
      "wafv2:ListResourcesForWebACL",
      "wafv2:GetWebACL",
      "waf:ListWebACLs",
      "waf:GetWebACL"
    ]
    resources = ["*"]
  }

  # S3 general read access - to match existing policy
  statement {
    sid = "S3ReadAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }

  # S3 access scoped to the diagram bucket
  statement {
    sid = "S3WriteAccessToDiagramBucket"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.diagram.arn}/*"]
  }

  # CloudWatch Logs
  statement {
    sid = "CloudWatchLogsAccess"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

## Always use a locally prebuilt Graphviz layer (self-contained)
resource "aws_lambda_layer_version" "graphviz" {
  layer_name          = "${var.name}-graphviz"
  filename            = "${path.module}/lambda/layer/prebuilt/graphviz-layer.zip"
  compatible_runtimes = ["python3.11"]
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
  # Hash the final ZIP so dependency changes also trigger a deploy
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_package.zip")

  # Attach the Graphviz layer (public ARN or locally built)
  layers = [aws_lambda_layer_version.graphviz.arn]
  
  environment {
    variables = {
      S3_BUCKET        = aws_s3_bucket.diagram.bucket
      PATH             = "/opt/bin:/usr/local/bin:/usr/bin:/bin"
      LD_LIBRARY_PATH  = "/opt/lib64:/opt/lib:/lib64:/usr/lib64"
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "weekly" {
  name                = "${var.name}-diagram-weekly"
  schedule_expression = var.schedule

  tags = var.tags
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