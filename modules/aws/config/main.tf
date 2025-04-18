# AWS Config Module
# This module sets up AWS Config to enable continuous monitoring and assessment of AWS resource configurations

# Local variables
locals {
  customer_identifier = var.customer_name != "" ? var.customer_name : "AWS Account ${data.aws_caller_identity.current.account_id}"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}
# --- Core AWS Config Resources --- 
 
 # IAM Role for AWS Config Service
resource "aws_iam_role" "config_role" {
  name = var.config_iam_role_name
  tags = merge(var.tags, { Customer = local.customer_identifier })

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

 # AWS Config Configuration Recorder
# This resource enables AWS Config and defines what resources it records.
resource "aws_config_configuration_recorder" "config" {
  count    = (var.enable_encrypted_volumes_rule ||
              var.enable_iam_password_policy_rule ||
              var.enable_s3_public_access_rules ||
              var.enable_iam_root_key_rule ||
              var.enable_mfa_for_iam_console_rule ||
              var.enable_ec2_volume_inuse_rule ||
              var.enable_eip_attached_rule ||
              var.enable_rds_storage_encrypted_rule) ? 1 : 0

  name     = var.config_recorder_name
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = false
    resource_types = distinct(concat(
      var.enable_encrypted_volumes_rule ? ["AWS::EC2::Volume"] : [],
      var.enable_iam_password_policy_rule ? ["AWS::IAM::User"] : [],
      var.enable_s3_public_access_rules ? ["AWS::S3::Bucket"] : [],
      var.enable_iam_root_key_rule ? ["AWS::IAM::User"] : [], # User type already potentially included
      var.enable_mfa_for_iam_console_rule ? ["AWS::IAM::User"] : [], # User type already potentially included
      var.enable_ec2_volume_inuse_rule ? ["AWS::EC2::Volume"] : [], # Volume type already potentially included
      var.enable_eip_attached_rule ? ["AWS::EC2::EIP"] : [],
      var.enable_rds_storage_encrypted_rule ? ["AWS::RDS::DBInstance"] : []
    ))
  }

  recording_mode {
    recording_frequency = var.recording_frequency
  }
}

 # S3 Bucket for AWS Config
# Stores configuration snapshots and history files delivered by AWS Config.
resource "aws_s3_bucket" "config_bucket" {
  bucket_prefix = var.config_bucket_prefix
  tags          = merge(var.tags, { Customer = local.customer_identifier })
}

 # S3 Bucket Policy
# Grants AWS Config service permissions to write objects (delivery) and check bucket ACLs.
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

 # AWS Config Delivery Channel
# Specifies where AWS Config delivers configuration snapshots and history files (the S3 bucket).
resource "aws_config_delivery_channel" "config" {
  name           = var.config_recorder_name # Often named the same as the recorder
  s3_bucket_name = aws_s3_bucket.config_bucket.id
  s3_key_prefix  = var.s3_key_prefix

  snapshot_delivery_properties {
    delivery_frequency = var.snapshot_delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.config, aws_s3_bucket_policy.config]
}

 # AWS Config Recorder Status
# Controls whether the configuration recorder is currently recording.
resource "aws_config_configuration_recorder_status" "config" {
  name       = aws_config_configuration_recorder.config[0].name
  is_enabled = true
  depends_on = [aws_config_configuration_recorder.config, aws_config_delivery_channel.config]
}

# IAM Policy Attachment for AWS Config
resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# --- Optional AWS Managed Config Rules --- 

resource "aws_config_config_rule" "iam_password_policy" {
  count       = var.enable_iam_password_policy_rule ? 1 : 0
  name        = "iam-password-policy"
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

  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_config_rule" "encrypted_volumes" {
  count = var.enable_encrypted_volumes_rule ? 1 : 0
  name        = "encrypted-volumes"
  description = "Checks whether EBS volumes that are in an attached state are encrypted."

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_config_rule" "ebs_encryption" {
  count       = var.enable_ebs_encryption_rule ? 1 : 0
  name        = "ebs-encryption-enabled"
  description = "Checks whether EBS volumes are encrypted"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  scope {
    compliance_resource_types = ["AWS::EC2::Volume"]
  }

  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  count = var.enable_s3_public_access_rules ? 1 : 0
  name        = "s3-bucket-public-read-prohibited"
  description = "Checks that your S3 buckets do not allow public read access."

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_config_rule" "s3_bucket_public_write_prohibited" {
  count = var.enable_s3_public_access_rules ? 1 : 0
  name        = "s3-bucket-public-write-prohibited"
  description = "Checks that your S3 buckets do not allow public write access."

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }

  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_config_rule" "iam_root_access_key_check" {
  count = var.enable_iam_root_key_rule ? 1 : 0
  name        = "iam-root-access-key-check"
  description = "Checks whether the root account access key exists."

  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }

  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_config_rule" "mfa_enabled_for_iam_console_access" {
  count = var.enable_mfa_for_iam_console_rule ? 1 : 0
  name        = "mfa-enabled-for-iam-console-access"
  description = "Checks whether MFA is enabled for all IAM users with a console password."

  source {
    owner             = "AWS"
    source_identifier = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"
  }

  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_config_rule" "ec2_volume_inuse_check" {
  count = var.enable_ec2_volume_inuse_rule ? 1 : 0
  name        = "ec2-volume-inuse-check"
  description = "Checks whether EBS volumes are attached to EC2 instances."

  source {
    owner             = "AWS"
    source_identifier = "EC2_VOLUME_INUSE_CHECK"
  }

  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_config_rule" "eip_attached" {
  count = var.enable_eip_attached_rule ? 1 : 0
  name        = "eip-attached"
  description = "Checks whether Elastic IP addresses are attached to EC2 instances."

  source {
    owner             = "AWS"
    source_identifier = "EIP_ATTACHED"
  }

  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_config_rule" "rds_storage_encrypted" {
  count = var.enable_rds_storage_encrypted_rule ? 1 : 0
  name        = "rds-storage-encrypted"
  description = "Checks whether storage encryption is enabled for your RDS DB instances."

  source {
    owner             = "AWS"
    source_identifier = "RDS_STORAGE_ENCRYPTED"
  }

  depends_on = [aws_config_delivery_channel.config]
}

# --- Optional S3 Bucket Lifecycle Configuration ---
 
# Manages the lifecycle of objects within the Config S3 bucket.
# Can be used for transitioning old data to cheaper storage (Glacier) or expiring it.
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

# --- Optional Compliance Reporter Lambda --- 
 
 # The Lambda function is pre-packaged with all dependencies in the repository
 # This eliminates the need for local Python/pip installation
 
 # 2. IAM Role for Lambda
data "aws_iam_policy_document" "reporter_lambda_assume_role" {
  count = var.enable_compliance_reporter ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "reporter_lambda_policy" {
  count = var.enable_compliance_reporter ? 1 : 0

  # Permissions required by the Lambda function:
  # - Write logs to CloudWatch
  # - Read compliance data from AWS Config service
  # - Get caller identity (for Account ID)
  # - Write the PDF report to the Config S3 bucket
  # - Retrieve resource tags from various AWS services
  # - Get account name information
  statement { # Basic CloudWatch Logging
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"] # Allow creating logs
    effect    = "Allow"
  }
  statement { # Config read access for compliance and rules
    actions = [
      "config:DescribeComplianceByConfigRule",
      "config:GetComplianceDetailsByConfigRule",
      "config:GetResourceConfigHistory",
      "config:DescribeConfigRules",
      "config:ListDiscoveredResources"
    ]
    resources = ["*"] # Config read actions often require * 
    effect    = "Allow"
  }
  statement { # STS access
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement { # S3 write access to the config bucket
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.config_bucket.arn}/${var.reporter_output_s3_prefix}*" # Restrict to the report prefix
    ]
    effect    = "Allow"
  }
  statement { # EC2 resource tag access
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeAddresses",
      "ec2:DescribeTags"
    ]
    resources = ["*"] # EC2 describe actions require *
    effect    = "Allow"
  }
  statement { # S3 bucket tag access
    actions = [
      "s3:GetBucketTagging"
    ]
    resources = ["*"] # Allow checking tags on any bucket
    effect    = "Allow"
  }
  statement { # RDS resource tag access
    actions = [
      "rds:DescribeDBInstances",
      "rds:ListTagsForResource"
    ]
    resources = ["*"] # RDS describe actions require *
    effect    = "Allow"
  }
  statement { # IAM user access
    actions = [
      "iam:GetUser",
      "iam:ListUserTags",
      "iam:ListUsers",
      "iam:ListAccountAliases"
    ]
    resources = ["*"] # Allow checking any IAM user
    effect    = "Allow"
  }
  statement { # Organizations account info access
    actions = [
      "organizations:DescribeAccount"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

# Creates the IAM Role using the assume role policy document.
resource "aws_iam_role" "reporter_lambda_role" {
  count = var.enable_compliance_reporter ? 1 : 0

  name               = "${var.config_recorder_name}-reporter-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.reporter_lambda_assume_role[count.index].json
  tags               = merge(var.tags, { Customer = local.customer_identifier })
}

# Attaches the inline policy (defined in the policy document) to the Lambda role.
resource "aws_iam_role_policy" "reporter_lambda_policy" {
  count = var.enable_compliance_reporter ? 1 : 0

  name   = "${var.config_recorder_name}-reporter-lambda-policy"
  role   = aws_iam_role.reporter_lambda_role[count.index].id
  policy = data.aws_iam_policy_document.reporter_lambda_policy[count.index].json
}

# 3. Lambda Function
resource "aws_lambda_function" "compliance_reporter" {
  count = var.enable_compliance_reporter ? 1 : 0

  function_name = "${var.config_recorder_name}-compliance-reporter"
  description   = "Generates compliance reports from AWS Config rule evaluations"
  role          = aws_iam_role.reporter_lambda_role[0].arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = var.reporter_lambda_timeout
  memory_size   = var.reporter_lambda_memory_size

  filename         = "${path.module}/lambda_compliance_reporter/lambda_package.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_compliance_reporter/lambda_package.zip")

  environment {
    variables = merge({
      CONFIG_REPORT_BUCKET         = aws_s3_bucket.config_bucket.id,
      REPORTER_OUTPUT_S3_PREFIX    = var.reporter_output_s3_prefix,
      CUSTOMER_IDENTIFIER          = local.customer_identifier
    })
  }

  tags = merge(var.tags, { Name = "${var.config_recorder_name}-compliance-reporter", Customer = local.customer_identifier })
}

# 4. CloudWatch Event Schedule
# Creates a scheduled event rule (using a cron expression) to trigger the Lambda function.
resource "aws_cloudwatch_event_rule" "reporter_schedule" {
  count = var.enable_compliance_reporter ? 1 : 0

  name                = "${var.config_recorder_name}-reporter-schedule"
  description         = "Triggers the AWS Config compliance reporter Lambda function."
  schedule_expression = var.reporter_schedule_expression
  tags                = merge(var.tags, { Customer = local.customer_identifier })
}

# Creates a target for the CloudWatch Event Rule, specifying the Lambda function to invoke.
resource "aws_cloudwatch_event_target" "reporter_lambda_target" {
  count = var.enable_compliance_reporter ? 1 : 0

  rule      = aws_cloudwatch_event_rule.reporter_schedule[count.index].name
  target_id = "${var.config_recorder_name}-reporter-lambda-target"
  arn       = aws_lambda_function.compliance_reporter[count.index].arn
}

# 5. Lambda Permission for CloudWatch Events
# Grants CloudWatch Events service permission to invoke the Lambda function.
resource "aws_lambda_permission" "allow_cloudwatch" {
  count = var.enable_compliance_reporter ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.compliance_reporter[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.reporter_schedule[count.index].arn
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2.0" # For archive_file data source
    }
  }
}
