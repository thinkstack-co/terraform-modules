output "arn" {
  description = "The Amazon Resource Name (ARN) of the target group"
  value       = aws_lb_target_group.this.arn
}

output "arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb_target_group.this.arn_suffix
}

output "name" {
  description = "The name of the target group"
  value       = aws_lb_target_group.this.name
}

output "id" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.this.id
}
