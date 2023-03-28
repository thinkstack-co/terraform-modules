############################################################
# AWS Organization Account
############################################################

output "arn" {
  value = aws_organizations_account.account.arn
}

output "id" {
  value = aws_organizations_account.account.id
}

output "tags_all" {
  value = aws_organizations_account.account.tags_all
}
