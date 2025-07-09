output "role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role used for AWS Backup"
  value       = aws_iam_role.backup_role.arn
}

output "role_name" {
  description = "The name of the IAM role used for AWS Backup"
  value       = aws_iam_role.backup_role.name
}

output "role_id" {
  description = "The unique ID of the IAM role"
  value       = aws_iam_role.backup_role.id
}

output "tag_policy_arn" {
  description = "The ARN of the tag-based backup policy (if enabled)"
  value       = var.enable_tag_based_selection ? aws_iam_policy.tag_based_backup_policy[0].arn : null
}

output "has_s3_permissions" {
  description = "Whether the role has S3 backup permissions"
  value       = var.enable_s3_backup
}

output "has_resource_discovery" {
  description = "Whether the role has resource discovery permissions"
  value       = var.enable_resource_discovery
}