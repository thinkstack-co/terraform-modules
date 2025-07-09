output "backup_vault_name" {
  description = "Name of the weekly backup vault"
  value       = module.backup_vaults.scheduled_vault_names["weekly"]
}

output "backup_vault_arn" {
  description = "ARN of the weekly backup vault"
  value       = module.backup_vaults.scheduled_vault_arns["weekly"]
}

output "dr_vault_name" {
  description = "Name of the weekly DR backup vault"
  value       = var.enable_dr ? module.backup_vaults.dr_vault_names["weekly"] : null
}

output "dr_vault_arn" {
  description = "ARN of the weekly DR backup vault"
  value       = var.enable_dr ? module.backup_vaults.dr_vault_arns["weekly"] : null
}

output "backup_plan_id" {
  description = "ID of the weekly backup plan"
  value       = module.weekly_backup_plan.individual_plan_ids["weekly"]
}

output "backup_plan_arn" {
  description = "ARN of the weekly backup plan"
  value       = module.weekly_backup_plan.individual_plan_arns["weekly"]
}

output "backup_selection_id" {
  description = "ID of the weekly backup selection"
  value       = module.weekly_backup_plan.individual_backup_selection_ids["weekly"]
}

output "iam_role_arn" {
  description = "ARN of the IAM role used for backups"
  value       = module.backup_iam_role.role_arn
}

output "example_resources" {
  description = "IDs of example resources created (if enabled)"
  value = {
    ec2_instance_id    = var.create_example_resources ? aws_instance.example[0].id : null
    ebs_volume_id      = var.create_example_resources ? aws_ebs_volume.example[0].id : null
    efs_file_system_id = var.create_example_resources ? aws_efs_file_system.example[0].id : null
  }
}