output "backup_vault_id" {
  description = "The ID of the backup vault"
  value       = aws_backup_vault.this.id
}

output "backup_plan_id" {
  description = "The ID of the backup plan"
  value       = aws_backup_plan.this.id
}

output "backup_role_arn" {
  description = "The ARN of the IAM role used for backup"
  value       = aws_iam_role.backup_role.arn
}

output "backup_role_name" {
  description = "The name of the IAM role used for AWS Backup"
  value       = aws_iam_role.backup_role.name
}
