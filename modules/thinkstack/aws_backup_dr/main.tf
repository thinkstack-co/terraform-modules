terraform {
  required_version = ">= 0.12.0"
}

###############################################################
# KMS Encryption Key
###############################################################

resource "aws_kms_key" "key" {
    bypass_policy_lockout_safety_check = var.key_bypass_policy_lockout_safety_check
    customer_master_key_spec           = var.key_customer_master_key_spec
    description                        = var.key_description
    deletion_window_in_days            = var.key_deletion_window_in_days
    enable_key_rotation                = var.key_enable_key_rotation
    key_usage                          = var.key_usage
    is_enabled                         = var.key_is_enabled
    policy                             = var.key_policy
    tags                               = var.tags
}

resource "aws_kms_alias" "alias" {
  name          = var.key_name
  target_key_id = aws_kms_key.key.key_id
}

###############################################################
# Backup Vaults
###############################################################

### Disaster Recovery
resource "aws_backup_vault" "vault_disaster_recovery" {
  name        = var.vault_disaster_recovery_name
  kms_key_arn = aws_kms_key.key.arn
  tags        = var.tags
}