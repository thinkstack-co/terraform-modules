output "arn" {
  value       = aws_launch_template.this.arn
  description = "Amazon Resource Name (ARN) of the launch template."
}

output "id" {
  value       = aws_launch_template.this.id
  description = "ID of the launch template."
}

output "latest_version" {
  value       = aws_launch_template.this.latest_version
  description = "The latest version of the launch template."
}
