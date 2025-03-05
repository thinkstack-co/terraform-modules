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
  value       = { for k, v in aws_backup_vault.backup_vault : k => v.arn }
}

output "backup_vault_ids" {
  description = "Map of backup vault names to their IDs."
  value       = { for k, v in aws_backup_vault.backup_vault : k => v.id }
}

###############################################################
# Backup Plan Outputs
###############################################################
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
output "daily_selection_id" {
  description = "The ID of the daily backup selection."
  value       = var.create_daily_plan ? aws_backup_selection.daily_selection[0].id : null
}

output "weekly_selection_id" {
  description = "The ID of the weekly backup selection."
  value       = var.create_weekly_plan ? aws_backup_selection.weekly_selection[0].id : null
}

output "monthly_selection_id" {
  description = "The ID of the monthly backup selection."
  value       = var.create_monthly_plan ? aws_backup_selection.monthly_selection[0].id : null
}

output "yearly_selection_id" {
  description = "The ID of the yearly backup selection."
  value       = var.create_yearly_plan ? aws_backup_selection.yearly_selection[0].id : null
}

output "custom_selection_ids" {
  description = "Map of custom backup selection names to their IDs."
  value       = { for k, v in aws_backup_selection.custom_selections : k => v.id }
}
