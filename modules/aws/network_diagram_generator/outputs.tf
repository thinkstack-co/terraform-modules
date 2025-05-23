output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.diagram.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.diagram.function_name
}

output "diagram_s3_bucket" {
  description = "S3 bucket where diagrams are stored"
  value       = aws_s3_bucket.diagram.bucket
}

output "event_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.scheduled.arn
}

output "event_rule_name" {
  description = "Name of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.scheduled.name
}

output "log_group_name" {
  description = "CloudWatch log group name for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "latest_diagram_s3_key" {
  description = "S3 key for the latest network diagram"
  value       = "network-diagrams/latest/network_diagram.png"
}
