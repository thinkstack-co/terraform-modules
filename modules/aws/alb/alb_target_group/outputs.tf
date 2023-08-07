output "target_group_arn" {
  description = "The ARN of the Target Group"
  value       = aws_lb_target_group.this.arn
}

output "target_group_attachment_arn" {
  description = "The ARN of the Target Group to which the attachment is associated"
  value       = aws_lb_target_group_attachment.this.target_group_arn
}
