# Outputs for the AWS Backup Vault module

###################################################
# Primary Vault Outputs
###################################################

output "vault_id" {
  description = "The ID of the primary backup vault"
  value       = aws_backup_vault.primary.id
}

output "vault_arn" {
  description = "The ARN of the primary backup vault"
  value       = aws_backup_vault.primary.arn
}

output "vault_name" {
  description = "The name of the primary backup vault"
  value       = aws_backup_vault.primary.name
}

output "vault_recovery_points" {
  description = "The number of recovery points that are stored in the primary backup vault"
  value       = aws_backup_vault.primary.recovery_points
}

###################################################
# DR Vault Outputs
###################################################

output "dr_vault_id" {
  description = "The ID of the DR backup vault"
  value       = var.enable_dr ? aws_backup_vault.dr[0].id : null
}

output "dr_vault_arn" {
  description = "The ARN of the DR backup vault"
  value       = var.enable_dr ? aws_backup_vault.dr[0].arn : null
}

output "dr_vault_name" {
  description = "The name of the DR backup vault"
  value       = var.enable_dr ? aws_backup_vault.dr[0].name : null
}

output "dr_vault_recovery_points" {
  description = "The number of recovery points that are stored in the DR backup vault"
  value       = var.enable_dr ? aws_backup_vault.dr[0].recovery_points : null
}

###################################################
# KMS Key Outputs
###################################################

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

###################################################
# Combined Outputs
###################################################

output "all_vault_arns" {
  description = "All vault ARNs created by this module"
  value = merge(
    { "primary" = aws_backup_vault.primary.arn },
    var.enable_dr ? { "dr" = aws_backup_vault.dr[0].arn } : {}
  )
}

output "effective_kms_key_arn" {
  description = "The KMS key ARN actually used for the primary vault (created or provided)"
  value       = var.create_kms_key ? aws_kms_key.backup[0].arn : var.kms_key_arn
}

output "effective_dr_kms_key_arn" {
  description = "The KMS key ARN actually used for the DR vault (created or provided)"
  value       = var.enable_dr ? (var.create_dr_kms_key ? aws_kms_key.dr_backup[0].arn : var.dr_kms_key_arn) : null
}
