terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

###########################
# Data Sources
###########################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

###########################
# KMS Encryption Key
###########################

resource "aws_kms_key" "key" {
  customer_master_key_spec = var.key_customer_master_key_spec
  description              = var.key_description
  deletion_window_in_days  = var.key_deletion_window_in_days
  enable_key_rotation      = var.key_enable_key_rotation
  key_usage                = var.key_usage
  is_enabled               = var.key_is_enabled
  tags                     = var.tags
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Sid"    = "Enable IAM User Permissions",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action"   = "kms:*",
        "Resource" = "*"
      },
      {
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "logs.${data.aws_region.current.name}.amazonaws.com"
        },
        "Action" = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" = "*",
        "Condition" = {
          "ArnEquals" = {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "alias" {
  name_prefix   = var.key_name_prefix
  target_key_id = aws_kms_key.key.key_id
}

###########################
# CloudWatch Log Group
###########################

resource "aws_cloudwatch_log_group" "log_group" {
  kms_key_id        = aws_kms_key.key.arn
  name_prefix       = var.cloudwatch_name_prefix
  retention_in_days = var.cloudwatch_retention_in_days
  tags              = var.tags
}

###########################
# IAM Policy
###########################
resource "aws_iam_policy" "policy" {
  description = var.iam_policy_description
  name_prefix = var.iam_policy_name_prefix
  path        = var.iam_policy_path
  tags        = var.tags
  #tfsec:ignore:aws-iam-no-policy-wildcards
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      Resource = [
        "${aws_cloudwatch_log_group.log_group.arn}:*"
      ]
    }]
  })
}

###########################
# IAM Role
###########################

resource "aws_iam_role" "role" {
  assume_role_policy    = var.iam_role_assume_role_policy
  description           = var.iam_role_description
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration
  name_prefix           = var.iam_role_name_prefix
  permissions_boundary  = var.iam_role_permissions_boundary
}

resource "aws_iam_role_policy_attachment" "role_attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}


###########################
# VPC Flow Log
###########################

resource "aws_flow_log" "vpc_flow" {
  iam_role_arn             = aws_iam_role.role.arn
  log_destination_type     = var.flow_log_destination_type
  log_destination          = aws_cloudwatch_log_group.log_group.arn
  max_aggregation_interval = var.flow_max_aggregation_interval
  tags                     = var.tags
  traffic_type             = var.flow_traffic_type
  vpc_id                   = var.flow_vpc_id
}