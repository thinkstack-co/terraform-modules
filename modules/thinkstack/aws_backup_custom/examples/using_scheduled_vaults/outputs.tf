output "backup_role_arn" {
  description = "ARN of the backup IAM role"
  value       = module.backup_iam_role.role_arn
}

output "primary_vault_arns" {
  description = "ARNs of primary backup vaults"
  value       = module.backup_vaults.scheduled_vault_arns
}

output "dr_vault_arns" {
  description = "ARNs of DR backup vaults"
  value       = module.backup_vaults.dr_vault_arns
}

output "backup_plan_ids" {
  description = "IDs of all backup plans"
  value = {
    hourly  = var.enable_hourly_vault ? module.hourly_backup_plan[0].id : null
    daily   = var.enable_daily_vault ? module.daily_backup_plan[0].id : null
    weekly  = var.enable_weekly_vault ? module.weekly_backup_plan[0].id : null
    monthly = var.enable_monthly_vault ? module.monthly_backup_plan[0].id : null
    yearly  = var.enable_yearly_vault ? module.yearly_backup_plan[0].id : null
  }
}

output "backup_selection_ids" {
  description = "IDs of all backup selections"
  value = {
    hourly  = var.enable_hourly_vault ? module.hourly_backup_selection[0].id : null
    daily   = var.enable_daily_vault ? module.daily_backup_selection[0].id : null
    weekly  = var.enable_weekly_vault ? module.weekly_backup_selection[0].id : null
    monthly = var.enable_monthly_vault ? module.monthly_backup_selection[0].id : null
    yearly  = var.enable_yearly_vault ? module.yearly_backup_selection[0].id : null
  }
}

output "kms_key_id" {
  description = "ID of the primary region KMS key"
  value       = aws_kms_key.backup.id
}

output "dr_kms_key_id" {
  description = "ID of the DR region KMS key"
  value       = var.enable_dr ? aws_kms_key.dr_backup[0].id : null
}