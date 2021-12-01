##################################
# AWS iam policy - role reading policy
##################################

output "policy_id" {
  value = aws_iam_policy.role_reading_policy.id
}

output "policy_arn" {
  value = aws_iam_policy.role_reading_policy.arn
}

output "policy_name" {
  value = aws_iam_policy.role_reading_policy.name
}

##################################
# AWS iam user - role reading user
##################################

output "reading_user_arn" {
  value = aws_iam_user.role_reading_user.arn
}

output "reading_user_unique_id" {
  value = aws_iam_user.role_reading_user.unique_id
}

output "encrypted_secret" {
  value = aws_iam_access_key.read_user_key.encrypted_secret
}

output "read_user_id" {
  value = aws_iam_access_key.read_user_key.id
}

##################################
# AWS iam saml provider - saml identify provider
##################################

output "identity_provider_arn" {
  value = aws_iam_saml_provider.this.arn
}
