# Attributes of the FSx Windows file system and its KMS keys / audit log group,
# consumed by DNS records, security group rules, and monitoring.

output "id" {
  description = "The ID of the FSx Windows file system."
  value       = aws_fsx_windows_file_system.fsx.id
}

output "arn" {
  description = "The ARN of the FSx Windows file system."
  value       = aws_fsx_windows_file_system.fsx.arn
}

output "dns_name" {
  description = "The DNS name for the file system; consumed by client mount configuration and DNS records."
  value       = aws_fsx_windows_file_system.fsx.dns_name
}

output "fsx_kms_key_id" {
  description = "The ID of the KMS key encrypting the file system data at rest."
  value       = aws_kms_key.fsx.key_id
}

output "cloudwatch_kms_key_id" {
  description = "The ID of the KMS key encrypting the audit log group."
  value       = aws_kms_key.cloudwatch.key_id
}

output "audit_log_group_arn" {
  description = "The ARN of the CloudWatch audit log group. Null when enable_audit_logs is false."
  value       = try(aws_cloudwatch_log_group.log_group[0].arn, null)
}
