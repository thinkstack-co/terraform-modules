output "mfa_policy_id" {
    value = aws_iam_policy.mfa_self_serve.id
}

output "mfa_policy_arn" {
    value = aws_iam_policy.mfa_self_serve.arn
}

output "mfa_policy_description" {
    value = aws_iam_policy.mfa_self_serve.description
}

output "mfa_policy_name" {
    value = aws_iam_policy.mfa_self_serve.name
}

output "mfa_policy_path" {
    value = aws_iam_policy.mfa_self_serve.path
}

output "mfa_policy_policy" {
    value = aws_iam_policy.mfa_self_serve.policy
}
