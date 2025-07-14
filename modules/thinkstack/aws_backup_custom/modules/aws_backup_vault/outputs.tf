# Single vault outputs
output "id" {
  description = "The name of the vault"
  value       = var.create_single_vault ? aws_backup_vault.this[0].id : null
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the vault"
  value       = var.create_single_vault ? aws_backup_vault.this[0].arn : null
}

output "recovery_points" {
  description = "The number of recovery points that are stored in the backup vault"
  value       = var.create_single_vault ? aws_backup_vault.this[0].recovery_points : null
}

output "name" {
  description = "The name of the vault"
  value       = var.create_single_vault ? aws_backup_vault.this[0].name : null
}

# Scheduled vaults outputs
output "scheduled_vault_ids" {
  description = "Map of scheduled vault names to their IDs"
  value       = { for k, v in aws_backup_vault.scheduled : k => v.id }
}

output "scheduled_vault_arns" {
  description = "Map of scheduled vault names to their ARNs"
  value       = { for k, v in aws_backup_vault.scheduled : k => v.arn }
}

output "scheduled_vault_names" {
  description = "Map of scheduled vault types to their names"
  value       = { for k, v in aws_backup_vault.scheduled : k => v.name }
}

# DR vault outputs
output "dr_vault_ids" {
  description = "Map of DR vault names to their IDs"
  value       = { for k, v in aws_backup_vault.dr : k => v.id }
}

output "dr_vault_arns" {
  description = "Map of DR vault names to their ARNs"
  value       = { for k, v in aws_backup_vault.dr : k => v.arn }
}

output "dr_vault_names" {
  description = "Map of DR vault types to their names"
  value       = { for k, v in aws_backup_vault.dr : k => v.name }
}

# Single DR vault outputs
output "dr_single_id" {
  description = "The ID of the single DR vault"
  value       = var.create_single_vault && var.enable_dr ? aws_backup_vault.dr_single[0].id : null
}

output "dr_single_arn" {
  description = "The ARN of the single DR vault"
  value       = var.create_single_vault && var.enable_dr ? aws_backup_vault.dr_single[0].arn : null
}

output "dr_single_name" {
  description = "The name of the single DR vault"
  value       = var.create_single_vault && var.enable_dr ? aws_backup_vault.dr_single[0].name : null
}

# Combined outputs for convenience
output "all_vault_arns" {
  description = "All vault ARNs created by this module"
  value = merge(
    var.create_single_vault ? { "single" = aws_backup_vault.this[0].arn } : {},
    { for k, v in aws_backup_vault.scheduled : k => v.arn },
    { for k, v in aws_backup_vault.dr : "dr-${k}" => v.arn },
    var.create_single_vault && var.enable_dr ? { "dr-single" = aws_backup_vault.dr_single[0].arn } : {}
  )
}

# KMS Key outputs
output "kms_key_id" {
  description = "The ID of the created KMS key"
  value       = var.create_kms_key ? aws_kms_key.backup[0].id : null
}

output "kms_key_arn" {
  description = "The ARN of the created KMS key"
  value       = var.create_kms_key ? aws_kms_key.backup[0].arn : null
}

output "kms_key_alias" {
  description = "The alias of the created KMS key"
  value       = var.create_kms_key ? aws_kms_alias.backup[0].name : null
}

output "dr_kms_key_id" {
  description = "The ID of the created DR KMS key"
  value       = var.enable_dr && var.create_dr_kms_key ? aws_kms_key.dr_backup[0].id : null
}

output "dr_kms_key_arn" {
  description = "The ARN of the created DR KMS key"
  value       = var.enable_dr && var.create_dr_kms_key ? aws_kms_key.dr_backup[0].arn : null
}

output "dr_kms_key_alias" {
  description = "The alias of the created DR KMS key"
  value       = var.enable_dr && var.create_dr_kms_key ? aws_kms_alias.dr_backup[0].name : null
}