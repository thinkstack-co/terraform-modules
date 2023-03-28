############################################################
# AWS Organization
############################################################

output "arn" {
  value = aws_organizations_organization.org.arn
}

output "id" {
  value = aws_organizations_organization.org.id
}
