# Outputs for the aws_backup_gold module

###################################################
# Backup Plan Outputs
###################################################

output "plan_id" {
  description = "ID of the Gold backup plan"
  value       = aws_backup_plan.gold.id
}

output "plan_arn" {
  description = "ARN of the Gold backup plan"
  value       = aws_backup_plan.gold.arn
}

output "plan_name" {
  description = "Name of the Gold backup plan"
  value       = aws_backup_plan.gold.name
}

output "plan_version" {
  description = "Version of the Gold backup plan"
  value       = aws_backup_plan.gold.version
}

###################################################
# Backup Selection Outputs
###################################################

output "selection_id" {
  description = "ID of the tag-based backup selection for the Gold plan"
  value       = aws_backup_selection.gold_tag_selection.id
}

output "selection_name" {
  description = "Name of the backup selection"
  value       = aws_backup_selection.gold_tag_selection.name
}

###################################################
# Enabled Rules Summary
###################################################

output "enabled_rules" {
  description = "Summary of enabled backup rules"
  value = {
    hourly  = var.enable_hourly_rule
    daily   = var.enable_daily_rule
    weekly  = var.enable_weekly_rule
    monthly = var.enable_monthly_rule
    yearly  = var.enable_yearly_rule
  }
}

output "dr_copy_enabled" {
  description = "Summary of DR copy settings per rule"
  value = {
    hourly  = var.hourly_copy_to_dr
    daily   = var.daily_copy_to_dr
    weekly  = var.weekly_copy_to_dr
    monthly = var.monthly_copy_to_dr
    yearly  = var.yearly_copy_to_dr
  }
}
