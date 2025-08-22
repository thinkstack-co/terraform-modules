output "s3_bucket_notification_id" {
  value = try(aws_s3_bucket_notification.this[0].id, null)
}

output "lambda_permission_statement_id" {
  value = var.lambda_permission_statement_id
}