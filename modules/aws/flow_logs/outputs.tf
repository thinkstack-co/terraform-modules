output "arn" {
  description = "ARN of the cloudwatch log group used for flow logs"
  value       = aws_cloudwatch_log_group.log_group[*].id
}