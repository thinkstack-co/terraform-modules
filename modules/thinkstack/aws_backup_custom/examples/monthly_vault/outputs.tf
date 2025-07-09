output "backup_vault_name" {
  description = "Name of the monthly backup vault"
  value       = module.backup_vaults.scheduled_vault_names["monthly"]
}

output "backup_vault_arn" {
  description = "ARN of the monthly backup vault"
  value       = module.backup_vaults.scheduled_vault_arns["monthly"]
}

output "dr_vault_name" {
  description = "Name of the monthly DR backup vault"
  value       = var.enable_dr ? module.backup_vaults.dr_vault_names["monthly"] : null
}

output "dr_vault_arn" {
  description = "ARN of the monthly DR backup vault"
  value       = var.enable_dr ? module.backup_vaults.dr_vault_arns["monthly"] : null
}

output "backup_plan_id" {
  description = "ID of the monthly backup plan"
  value       = module.monthly_backup_plan.individual_plan_ids["monthly"]
}

output "backup_plan_arn" {
  description = "ARN of the monthly backup plan"
  value       = module.monthly_backup_plan.individual_plan_arns["monthly"]
}

output "backup_selection_id" {
  description = "ID of the monthly backup selection"
  value       = module.monthly_backup_plan.individual_backup_selection_ids["monthly"]
}

output "iam_role_arn" {
  description = "ARN of the IAM role used for backups"
  value       = module.backup_iam_role.role_arn
}

output "example_resources" {
  description = "IDs of example resources created (if enabled)"
  value = {
    ec2_instance_id = var.create_example_resources ? aws_instance.example[0].id : null
    rds_instance_id = var.create_example_resources ? aws_db_instance.example[0].id : null
  }
}