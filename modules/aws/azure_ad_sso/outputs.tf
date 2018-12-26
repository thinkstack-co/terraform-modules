##################################
# AWS iam policy - role reading policy
##################################

output "policy_id" {
    value = "${aws_iam_policy.role_reading_policy.id}"
}

output "policy_arn" {
    value = "${aws_iam_policy.role_reading_policy.arn}"
}

output "policy_name" {
    value = "${aws_iam_policy.role_reading_policy.name}"
}

##################################
# AWS iam user - role reading user
##################################

output "arn" {
  value = "${aws_iam_user.role_reading_user.arn}"
}

output "unique_id" {
  value = "${aws_iam_user.role_reading_user.unique_id}"
}

##################################
# AWS iam saml provider - saml identify provider
##################################

output "identify_provider_arn" {
  value = "${aws_iam_saml_provider.this.arn}"
}
