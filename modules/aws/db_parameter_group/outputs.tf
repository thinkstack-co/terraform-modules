output "arn" {
  description = "The ARN of the db parameter group."
  value       = aws_db_parameter_group.group[*].arn
}

output "id" {
  description = "The db parameter group name."
  value       = aws_db_parameter_group.group[*].id
}
