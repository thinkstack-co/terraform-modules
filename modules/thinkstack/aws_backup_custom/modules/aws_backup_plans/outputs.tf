# Individual plan outputs
output "individual_plan_ids" {
  description = "Map of individual backup plan IDs by schedule type"
  value       = { for k, v in aws_backup_plan.individual : k => v.id }
}

output "individual_plan_arns" {
  description = "Map of individual backup plan ARNs by schedule type"
  value       = { for k, v in aws_backup_plan.individual : k => v.arn }
}

output "individual_plan_versions" {
  description = "Map of individual backup plan versions by schedule type"
  value       = { for k, v in aws_backup_plan.individual : k => v.version }
}

output "individual_plan_names" {
  description = "Map of individual backup plan names by schedule type"
  value       = { for k, v in aws_backup_plan.individual : k => v.name }
}

# Combined plan outputs
output "combined_plan_id" {
  description = "The id of the combined backup plan"
  value       = try(aws_backup_plan.combined[0].id, null)
}

output "combined_plan_arn" {
  description = "The ARN of the combined backup plan"
  value       = try(aws_backup_plan.combined[0].arn, null)
}

output "combined_plan_version" {
  description = "Version ID of the combined backup plan"
  value       = try(aws_backup_plan.combined[0].version, null)
}

output "combined_plan_name" {
  description = "The display name of the combined backup plan"
  value       = try(aws_backup_plan.combined[0].name, null)
}

# Custom plan outputs (for backward compatibility)
output "custom_plan_id" {
  description = "The id of the custom backup plan"
  value       = try(aws_backup_plan.custom[0].id, null)
}

output "custom_plan_arn" {
  description = "The ARN of the custom backup plan"
  value       = try(aws_backup_plan.custom[0].arn, null)
}

output "custom_plan_version" {
  description = "Version ID of the custom backup plan"
  value       = try(aws_backup_plan.custom[0].version, null)
}

output "custom_plan_name" {
  description = "The display name of the custom backup plan"
  value       = try(aws_backup_plan.custom[0].name, null)
}

# Aggregated outputs for convenience
output "all_plan_ids" {
  description = "All backup plan IDs created by this module"
  value = merge(
    { for k, v in aws_backup_plan.individual : k => v.id },
    try(aws_backup_plan.combined[0].id, null) != null ? { "combined" = aws_backup_plan.combined[0].id } : {},
    try(aws_backup_plan.custom[0].id, null) != null ? { "custom" = aws_backup_plan.custom[0].id } : {}
  )
}

output "all_plan_arns" {
  description = "All backup plan ARNs created by this module"
  value = merge(
    { for k, v in aws_backup_plan.individual : k => v.arn },
    try(aws_backup_plan.combined[0].arn, null) != null ? { "combined" = aws_backup_plan.combined[0].arn } : {},
    try(aws_backup_plan.custom[0].arn, null) != null ? { "custom" = aws_backup_plan.custom[0].arn } : {}
  )
}

output "enabled_schedules" {
  description = "List of enabled backup schedules"
  value       = keys(local.enabled_plans)
}

output "plan_configurations" {
  description = "Configuration details for all enabled plans"
  value       = local.enabled_plans
}

# Backup Selection outputs
output "backup_selection_role_arn" {
  description = "ARN of the IAM role used for backup selection"
  value       = try(aws_iam_role.backup_selection[0].arn, null)
}

output "backup_selection_role_name" {
  description = "Name of the IAM role used for backup selection"
  value       = try(aws_iam_role.backup_selection[0].name, null)
}

output "individual_backup_selection_ids" {
  description = "Map of individual backup selection IDs by schedule type"
  value       = { for k, v in aws_backup_selection.individual : k => v.id }
}

output "individual_backup_selection_names" {
  description = "Map of individual backup selection names by schedule type"
  value       = { for k, v in aws_backup_selection.individual : k => v.name }
}

output "combined_backup_selection_id" {
  description = "ID of the combined backup selection"
  value       = try(aws_backup_selection.combined[0].id, null)
}

output "combined_backup_selection_name" {
  description = "Name of the combined backup selection"
  value       = try(aws_backup_selection.combined[0].name, null)
}

output "custom_backup_selection_id" {
  description = "ID of the custom backup selection"
  value       = try(aws_backup_selection.custom[0].id, null)
}

output "custom_backup_selection_name" {
  description = "Name of the custom backup selection"
  value       = try(aws_backup_selection.custom[0].name, null)
}

output "all_backup_selection_ids" {
  description = "All backup selection IDs created by this module"
  value = merge(
    { for k, v in aws_backup_selection.individual : k => v.id },
    try(aws_backup_selection.combined[0].id, null) != null ? { "combined" = aws_backup_selection.combined[0].id } : {},
    try(aws_backup_selection.custom[0].id, null) != null ? { "custom" = aws_backup_selection.custom[0].id } : {}
  )
}

# Prefix information
output "plan_prefix" {
  description = "The prefix used for all plan names"
  value       = var.plan_prefix
}

output "plan_base_name" {
  description = "The base name used for all plans (includes prefix if set)"
  value       = local.plan_name_base
}

output "enabled_dr_copies" {
  description = "List of schedules with DR copy enabled"
  value       = [for k, v in local.enabled_plans : k if v.enable_dr_copy]
}