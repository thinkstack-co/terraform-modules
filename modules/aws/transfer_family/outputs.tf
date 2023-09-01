output "transfer_server_id" {
  description = "The ID of the Transfer Family server."
  value       = aws_transfer_server.transfer_server.id
}

output "transfer_server_arn" {
  description = "The ARN (Amazon Resource Name) of the Transfer Family server."
  value       = aws_transfer_server.transfer_server.arn
}

output "transfer_server_endpoint" {
  description = "The endpoint URL of the Transfer Family server."
  value       = aws_transfer_server.transfer_server.endpoint
}

output "transfer_server_host_key_fingerprint" {
  description = "The service-assigned ID of the Transfer Family server."
  value       = aws_transfer_server.transfer_server.host_key_fingerprint
}

output "transfer_server_logging_role" {
  description = "A role in AWS Identity and Access Management that allows the server to monitor user activity."
  value       = aws_transfer_server.transfer_server.logging_role
}

output "transfer_server_tags" {
  description = "The key-value pair that are assigned to the Transfer Family server."
  value       = aws_transfer_server.transfer_server.tags
}
