output "id" {
  description = "The RDS cluster identifier; consumed by aws_rds_cluster_instance and monitoring."
  value       = aws_rds_cluster.cluster.id
}

output "arn" {
  description = "The ARN of the RDS cluster."
  value       = aws_rds_cluster.cluster.arn
}

output "endpoint" {
  description = "The writer (DNS) endpoint; consumed by application connection strings."
  value       = aws_rds_cluster.cluster.endpoint
}

output "reader_endpoint" {
  description = "The read-only reader endpoint for the cluster."
  value       = aws_rds_cluster.cluster.reader_endpoint
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the managed master credentials (username + password). Fetch for maintenance: aws secretsmanager get-secret-value --secret-id <arn>. Null unless manage_master_user_password is true."
  value       = try(aws_rds_cluster.cluster.master_user_secret[0].secret_arn, null)
}
