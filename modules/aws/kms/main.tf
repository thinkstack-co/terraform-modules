terraform {
  required_version = ">= 0.12.0"
}

resource "aws_kms_key" "key" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  key_usage               = var.key_usage
  is_enabled              = var.is_enabled
  policy                  = var.policy
  tags                    = var.tags
}

resource "aws_kms_alias" "alias" {
  name          = var.name
  target_key_id = aws_kms_key.key.key_id
}
