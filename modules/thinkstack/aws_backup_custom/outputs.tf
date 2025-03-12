###############################################################
# KMS Key Outputs
###############################################################
output "kms_key_arn" {
  description = "The Amazon Resource Name (ARN) of the KMS key."
  value       = var.create_kms_key ? aws_kms_key.backup_key[0].arn : null
}

output "kms_key_id" {
  description = "The globally unique identifier for the KMS key."
  value       = var.create_kms_key ? aws_kms_key.backup_key[0].key_id : null
}

###############################################################
# IAM Role Outputs
###############################################################
output "backup_role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role used for AWS Backup."
  value       = aws_iam_role.backup_role.arn
}

output "backup_role_name" {
  description = "The name of the IAM role used for AWS Backup."
  value       = aws_iam_role.backup_role.name
}

###############################################################
# Backup Vault Outputs
###############################################################
output "backup_vault_arns" {
  description = "Map of backup vault names to their ARNs."
  value = merge(
    local.create_daily_vault ? { "daily" = aws_backup_vault.daily[0].arn } : {},
    local.create_hourly_vault ? { "hourly" = aws_backup_vault.hourly[0].arn } : {},
    local.create_weekly_vault ? { "weekly" = aws_backup_vault.weekly[0].arn } : {},
    local.create_monthly_vault ? { "monthly" = aws_backup_vault.monthly[0].arn } : {},
    local.create_yearly_vault ? { "yearly" = aws_backup_vault.yearly[0].arn } : {}
  )
}

output "backup_vault_ids" {
  description = "Map of backup vault names to their IDs."
  value = merge(
    local.create_daily_vault ? { "daily" = aws_backup_vault.daily[0].id } : {},
    local.create_hourly_vault ? { "hourly" = aws_backup_vault.hourly[0].id } : {},
    local.create_weekly_vault ? { "weekly" = aws_backup_vault.weekly[0].id } : {},
    local.create_monthly_vault ? { "monthly" = aws_backup_vault.monthly[0].id } : {},
    local.create_yearly_vault ? { "yearly" = aws_backup_vault.yearly[0].id } : {}
  )
}

###############################################################
# Backup Plan Outputs
###############################################################
output "hourly_backup_plan_id" {
  description = "The ID of the hourly backup plan."
  value       = var.create_hourly_plan ? aws_backup_plan.hourly_backup_plan[0].id : null
}

output "daily_backup_plan_id" {
  description = "The ID of the daily backup plan."
  value       = var.create_daily_plan ? aws_backup_plan.daily_backup_plan[0].id : null
}

output "weekly_backup_plan_id" {
  description = "The ID of the weekly backup plan."
  value       = var.create_weekly_plan ? aws_backup_plan.weekly_backup_plan[0].id : null
}

output "monthly_backup_plan_id" {
  description = "The ID of the monthly backup plan."
  value       = var.create_monthly_plan ? aws_backup_plan.monthly_backup_plan[0].id : null
}

output "yearly_backup_plan_id" {
  description = "The ID of the yearly backup plan."
  value       = var.create_yearly_plan ? aws_backup_plan.yearly_backup_plan[0].id : null
}

output "custom_backup_plan_ids" {
  description = "Map of custom backup plan names to their IDs."
  value       = { for k, v in aws_backup_plan.custom_backup_plans : k => v.id }
}

###############################################################
# Backup Selection Outputs
###############################################################
output "hourly_selection_id" {
  description = "The ID of the hourly backup selection."
  value       = var.create_hourly_plan ? aws_backup_selection.hourly_selection["hourly"].id : null
}

output "daily_selection_id" {
  description = "The ID of the daily backup selection."
  value       = var.create_daily_plan ? aws_backup_selection.daily_selection["daily"].id : null
}

output "weekly_selection_id" {
  description = "The ID of the weekly backup selection."
  value       = var.create_weekly_plan ? aws_backup_selection.weekly_selection["weekly"].id : null
}

output "monthly_selection_id" {
  description = "The ID of the monthly backup selection."
  value       = var.create_monthly_plan ? aws_backup_selection.monthly_selection["monthly"].id : null
}

output "yearly_selection_id" {
  description = "The ID of the yearly backup selection."
  value       = var.create_yearly_plan ? aws_backup_selection.yearly_selection["yearly"].id : null
}

output "custom_selection_ids" {
  description = "Map of custom backup selection names to their IDs."
  value       = { for k, v in aws_backup_selection.custom_selection : k => v.id }
}

###############################################################
# Backup Selection Combination Outputs
###############################################################
output "hourly_combinations_selection_ids" {
  description = "Map of hourly combination backup selection names to their IDs."
  value       = var.create_hourly_plan ? { for k, v in aws_backup_selection.hourly_selection : k => v.id } : {}
}

output "daily_combinations_selection_ids" {
  description = "Map of daily combination backup selection names to their IDs."
  value       = var.create_daily_plan ? { for k, v in aws_backup_selection.daily_selection : k => v.id } : {}
}

output "weekly_combinations_selection_ids" {
  description = "Map of weekly combination backup selection names to their IDs."
  value       = var.create_weekly_plan ? { for k, v in aws_backup_selection.weekly_selection : k => v.id } : {}
}

output "monthly_combinations_selection_ids" {
  description = "Map of monthly combination backup selection names to their IDs."
  value       = var.create_monthly_plan ? { for k, v in aws_backup_selection.monthly_selection : k => v.id } : {}
}

output "yearly_combinations_selection_ids" {
  description = "Map of yearly combination backup selection names to their IDs."
  value       = var.create_yearly_plan ? { for k, v in aws_backup_selection.yearly_selection : k => v.id } : {}
}

output "hourly_all_selection_ids" {
  description = "Map of hourly 'all' tag backup selection names to their IDs."
  value       = var.create_hourly_plan ? { for k, v in aws_backup_selection.hourly_selection_all : k => v.id } : {}
}

output "daily_all_selection_ids" {
  description = "Map of daily 'all' tag backup selection names to their IDs."
  value       = var.create_daily_plan ? { for k, v in aws_backup_selection.daily_selection_all : k => v.id } : {}
}

output "weekly_all_selection_ids" {
  description = "Map of weekly 'all' tag backup selection names to their IDs."
  value       = var.create_weekly_plan ? { for k, v in aws_backup_selection.weekly_selection_all : k => v.id } : {}
}

output "monthly_all_selection_ids" {
  description = "Map of monthly 'all' tag backup selection names to their IDs."
  value       = var.create_monthly_plan ? { for k, v in aws_backup_selection.monthly_selection_all : k => v.id } : {}
}

output "yearly_all_selection_ids" {
  description = "Map of yearly 'all' tag backup selection names to their IDs."
  value       = var.create_yearly_plan ? { for k, v in aws_backup_selection.yearly_selection_all : k => v.id } : {}
}

output "multi_plan_selection_ids" {
  description = "Map of multi-plan backup selection names to their IDs."
  value       = { for k, v in aws_backup_selection.multi_plan_selections : k => v.id }
}
