terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0.0"
      configuration_aliases = [aws.dr]
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

# KMS Key for primary region
resource "aws_kms_key" "backup" {
  count                   = var.create_kms_key ? 1 : 0
  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_enable_rotation

  tags = merge(
    var.tags,
    {
      Name = var.vault_name_prefix != "" ? "${var.vault_name_prefix}-backup-key" : "backup-key"
      Type = "backup-encryption"
    }
  )
}

resource "aws_kms_alias" "backup" {
  count         = var.create_kms_key ? 1 : 0
  name          = var.vault_name_prefix != "" ? "alias/${var.vault_name_prefix}-backup" : "alias/backup"
  target_key_id = aws_kms_key.backup[0].key_id
}

# KMS Key for DR region
resource "aws_kms_key" "dr_backup" {
  count                   = var.enable_dr && var.create_dr_kms_key ? 1 : 0
  provider                = aws.dr
  description             = var.dr_kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_enable_rotation

  tags = merge(
    var.tags,
    var.dr_tags,
    {
      Name = var.dr_vault_name_prefix != "" ? "${var.dr_vault_name_prefix}-backup-key" : "dr-backup-key"
      Type = "dr-backup-encryption"
    }
  )
}

resource "aws_kms_alias" "dr_backup" {
  count         = var.enable_dr && var.create_dr_kms_key ? 1 : 0
  provider      = aws.dr
  name          = var.dr_vault_name_prefix != "" ? "alias/${var.dr_vault_name_prefix}-backup" : "alias/dr-backup"
  target_key_id = aws_kms_key.dr_backup[0].key_id
}

locals {
  # Determine which KMS key ARN to use (null means use AWS-managed key)
  kms_key_arn    = var.create_kms_key ? aws_kms_key.backup[0].arn : var.kms_key_arn
  dr_kms_key_arn = var.enable_dr ? (var.create_dr_kms_key ? aws_kms_key.dr_backup[0].arn : var.dr_kms_key_arn) : null

  vault_configs = {
    hourly = {
      enabled       = var.enable_hourly_vault
      name          = var.vault_name_prefix != "" ? "${var.vault_name_prefix}-hourly" : "hourly"
      min_retention = var.hourly_min_retention_days
      enable_dr     = var.enable_hourly_dr_vault
    }
    daily = {
      enabled       = var.enable_daily_vault
      name          = var.vault_name_prefix != "" ? "${var.vault_name_prefix}-daily" : "daily"
      min_retention = var.daily_min_retention_days
      enable_dr     = var.enable_daily_dr_vault
    }
    weekly = {
      enabled       = var.enable_weekly_vault
      name          = var.vault_name_prefix != "" ? "${var.vault_name_prefix}-weekly" : "weekly"
      min_retention = var.weekly_min_retention_days
      enable_dr     = var.enable_weekly_dr_vault
    }
    monthly = {
      enabled       = var.enable_monthly_vault
      name          = var.vault_name_prefix != "" ? "${var.vault_name_prefix}-monthly" : "monthly"
      min_retention = var.monthly_min_retention_days
      enable_dr     = var.enable_monthly_dr_vault
    }
    yearly = {
      enabled       = var.enable_yearly_vault
      name          = var.vault_name_prefix != "" ? "${var.vault_name_prefix}-yearly" : "yearly"
      min_retention = var.yearly_min_retention_days
      enable_dr     = var.enable_yearly_dr_vault
    }
  }

  # Filter to only enabled vaults
  enabled_vaults = { for k, v in local.vault_configs : k => v if v.enabled }

  # Filter to vaults that should have DR
  dr_enabled_vaults = { for k, v in local.enabled_vaults : k => v if var.enable_dr && v.enable_dr }

  # Validation: Check for DR vaults without corresponding primary vaults
  dr_without_primary = {
    hourly  = var.enable_dr && var.enable_hourly_dr_vault && !var.enable_hourly_vault
    daily   = var.enable_dr && var.enable_daily_dr_vault && !var.enable_daily_vault
    weekly  = var.enable_dr && var.enable_weekly_dr_vault && !var.enable_weekly_vault
    monthly = var.enable_dr && var.enable_monthly_dr_vault && !var.enable_monthly_vault
    yearly  = var.enable_dr && var.enable_yearly_dr_vault && !var.enable_yearly_vault
  }

  # Create error messages for validation
  dr_validation_errors = compact([
    local.dr_without_primary.hourly ? "Cannot enable hourly DR vault without primary hourly vault. Set enable_hourly_vault = true or enable_hourly_dr_vault = false." : "",
    local.dr_without_primary.daily ? "Cannot enable daily DR vault without primary daily vault. Set enable_daily_vault = true or enable_daily_dr_vault = false." : "",
    local.dr_without_primary.weekly ? "Cannot enable weekly DR vault without primary weekly vault. Set enable_weekly_vault = true or enable_weekly_dr_vault = false." : "",
    local.dr_without_primary.monthly ? "Cannot enable monthly DR vault without primary monthly vault. Set enable_monthly_vault = true or enable_monthly_dr_vault = false." : "",
    local.dr_without_primary.yearly ? "Cannot enable yearly DR vault without primary yearly vault. Set enable_yearly_vault = true or enable_yearly_dr_vault = false." : ""
  ])
}

# Validation check - Terraform 1.0-compatible. Fails apply with a clear message if misconfigured.
resource "null_resource" "dr_vault_validation" {
  count = length(local.dr_validation_errors) > 0 ? 1 : 0

  provisioner "local-exec" {
    when    = create
    command = <<EOT
echo "${join("\n", local.dr_validation_errors)}" 1>&2
exit 1
EOT
  }
}

# Single custom vault (original functionality)
resource "aws_backup_vault" "this" {
  count         = var.create_single_vault ? 1 : 0
  name          = var.name
  kms_key_arn   = local.kms_key_arn # null will use AWS-managed key
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = var.name })
}

resource "aws_backup_vault_lock_configuration" "this" {
  count             = var.create_single_vault && var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.this[0].name

  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.vault_lock_min_retention_days
}

# Scheduled vaults (hourly, daily, weekly, monthly, yearly)
resource "aws_backup_vault" "scheduled" {
  for_each = local.enabled_vaults

  name          = each.value.name
  kms_key_arn   = local.kms_key_arn # null will use AWS-managed key
  force_destroy = var.force_destroy
  tags = merge(
    var.tags,
    {
      Name     = each.value.name,
      Schedule = each.key
    }
  )
}

resource "aws_backup_vault_lock_configuration" "scheduled" {
  for_each = var.enable_vault_lock ? local.enabled_vaults : {}

  backup_vault_name = aws_backup_vault.scheduled[each.key].name

  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = each.value.min_retention
}

# DR vaults
resource "aws_backup_vault" "dr" {
  for_each = local.dr_enabled_vaults
  provider = aws.dr

  name          = var.dr_vault_name_prefix != "" ? "${var.dr_vault_name_prefix}-${each.key}" : "dr-${each.key}"
  kms_key_arn   = local.dr_kms_key_arn # null will use AWS-managed key
  force_destroy = var.force_destroy
  tags = merge(
    var.tags,
    var.dr_tags,
    {
      Name     = var.dr_vault_name_prefix != "" ? "${var.dr_vault_name_prefix}-${each.key}" : "dr-${each.key}",
      Schedule = each.key,
      Type     = "DR"
    }
  )
}

resource "aws_backup_vault_lock_configuration" "dr" {
  for_each = var.enable_vault_lock ? local.dr_enabled_vaults : {}
  provider = aws.dr

  backup_vault_name = aws_backup_vault.dr[each.key].name

  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = each.value.min_retention
}

# Single DR vault (for custom vault)
resource "aws_backup_vault" "dr_single" {
  count    = var.create_single_vault && var.enable_dr ? 1 : 0
  provider = aws.dr

  name          = var.dr_vault_name != "" ? var.dr_vault_name : "dr-${var.name}"
  kms_key_arn   = local.dr_kms_key_arn # null will use AWS-managed key
  force_destroy = var.force_destroy
  tags = merge(
    var.tags,
    var.dr_tags,
    {
      Name = var.dr_vault_name != "" ? var.dr_vault_name : "dr-${var.name}",
      Type = "DR"
    }
  )
}

resource "aws_backup_vault_lock_configuration" "dr_single" {
  count    = var.create_single_vault && var.enable_dr && var.enable_vault_lock ? 1 : 0
  provider = aws.dr

  backup_vault_name = aws_backup_vault.dr_single[0].name

  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.vault_lock_min_retention_days
}