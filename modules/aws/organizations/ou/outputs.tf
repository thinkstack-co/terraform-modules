output "accounts" {
  description = "The list of accounts in the Organizational Unit."
  value       = aws_organizations_organizational_unit.this.accounts
}

output "arn" {
  description = "The ARN of the Organizational Unit."
  value       = aws_organizations_organizational_unit.this.arn
}

output "id" {
  description = "The ID of the Organizational Unit."
  value       = aws_organizations_organizational_unit.this.id
}
