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
# KMS Encryption Key
###########################

resource "aws_kms_key" "sqs" {
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
        "Sid"    = "Allow SQS to encrypt logs",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "sqs.amazonaws.com"
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
          "StringLike" = {
            "kms:EncryptionContext:aws:sqs:arn" : [
              "arn:aws:sqs:*:${data.aws_caller_identity.current.account_id}:queue/*"
            ]
          },
          "StringEquals" = {
            "aws:SourceArn" = "arn:aws:sqs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:queue/${var.name}"
          }
        }
      },
    ]
  })
}

resource "aws_kms_alias" "sqs" {
  name_prefix   = var.key_name_prefix
  target_key_id = aws_kms_key.sqs.key_id
}

###########################
# SQS Queue
###########################

resource "aws_sqs_queue" "queue" {
  delay_seconds                     = var.delay_seconds
  fifo_queue                        = var.fifo_queue
  kms_master_key_id                 = aws_kms_key.sqs.arn
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  message_retention_seconds         = var.message_retention_seconds
  name                              = var.name
  tags                              = var.tags
  visibility_timeout_seconds        = var.visibility_timeout_seconds
}
