/*
output "lambda_function_arn" {
  description = "ARN of the Lambda function."
  value       = aws_lambda_function.diagram.arn
}

output "diagram_s3_bucket" {
  description = "S3 bucket where diagrams are stored."
  value       = var.s3_bucket_name != null ? var.s3_bucket_name : aws_s3_bucket.diagram[0].bucket
}

output "event_rule_arn" {
  description = "ARN of the EventBridge rule."
  value       = aws_cloudwatch_event_rule.weekly.arn
}
*/
