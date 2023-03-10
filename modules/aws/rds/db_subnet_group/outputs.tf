output "arn" {
  description = "The ARN of the db subnet group."
  value       = aws_db_subnet_group.group.arn
}

output "id" {
  description = "The db subnet group name."
  value       = aws_db_subnet_group.group.id
}
