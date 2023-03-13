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

########################################
# KMS Keys
########################################
####################
# DNSSEC Key
####################

resource "aws_kms_key" "dnssec" {
  customer_master_key_spec = var.customer_master_key_spec
  deletion_window_in_days  = var.deletion_window_in_days
  description              = var.description
  enable_key_rotation      = var.enable_key_rotation
  key_usage                = var.key_usage
  is_enabled               = var.is_enabled
  tags                     = var.tags
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow Route 53 DNSSEC Service",
        Effect = "Allow",
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        },
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:route53:::hostedzone/*"
          }
        }
      },
      {
        Sid    = "Allow Route 53 DNSSEC Service to CreateGrant",
        Effect = "Allow",
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Action   = "kms:CreateGrant",
        Resource = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
    ]
  })
}

resource "aws_kms_alias" "this" {
  name_prefix   = var.name_prefix
  target_key_id = aws_kms_key.dnssec.key_id
}

resource "aws_route53_key_signing_key" "this" {
  hosted_zone_id             = var.hosted_zone_id
  key_management_service_arn = aws_kms_key.dnssec.arn
  name                       = var.name
  status                     = var.status
}

resource "aws_route53_hosted_zone_dnssec" "this" {
  depends_on = [
    aws_route53_key_signing_key.this
  ]
  hosted_zone_id = aws_route53_key_signing_key.this.hosted_zone_id
  signing_status = var.signing_status
}
