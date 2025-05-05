output "transfer_server_id" {
  description = "The ID of the Transfer Server."
  value       = aws_transfer_server.transfer_server.id
}

output "transfer_server_arn" {
  description = "The ARN of the Transfer Server."
  value       = aws_transfer_server.transfer_server.arn
}

output "transfer_server_endpoint" {
  description = "The endpoint of the Transfer Server."
  value       = aws_transfer_server.transfer_server.endpoint
}

output "transfer_server_identity_provider_type" {
  description = "The mode of authentication enabled for this service."
  value       = aws_transfer_server.transfer_server.identity_provider_type
}

output "transfer_server_logging_role" {
  description = "The Amazon Resource Name (ARN) of the IAM role that allows the service to write your users’ activity to your Amazon CloudWatch logs for monitoring and auditing purposes."
  value       = aws_transfer_server.transfer_server.logging_role
}

output "transfer_server_security_policy_name" {
  description = "The name of the security policy that is attached to the server."
  value       = aws_transfer_server.transfer_server.security_policy_name
}

output "transfer_server_tags" {
  description = "The tags of the Transfer Server."
  value       = aws_transfer_server.transfer_server.tags
}

output "transfer_server_workflow_details" {
  description = "The workflow details of the Transfer Server."
  value       = aws_transfer_server.transfer_server.workflow_details
}
