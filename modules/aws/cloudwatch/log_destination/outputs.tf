output "destination_arn" {
  description = "The ARN of the CloudWatch log destination; consumed by source-account subscription filters."
  value       = aws_cloudwatch_log_destination.this.arn
}

output "destination_name" {
  description = "The name of the CloudWatch log destination."
  value       = aws_cloudwatch_log_destination.this.name
}

output "role_arn" {
  description = "The ARN of the IAM role CloudWatch Logs assumes to deliver to the Firehose target."
  value       = aws_iam_role.firehose_role.arn
}
