# Outputs for AWS Cost Report Module

output "customer_identifier" {
  description = "The resolved customer identifier used for tagging and Lambda environment."
  value       = local.customer_identifier
}

output "lambda_function_arn" {
  description = "The ARN of the cost report Lambda function."
  value       = aws_lambda_function.cost_reporter.arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for cost reports."
  value       = aws_s3_bucket.cost_report.id
}