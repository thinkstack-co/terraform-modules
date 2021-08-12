output "mfa_policy_id" {
    value = aws_iam_policy.mfa_enforcement.id
}

output "mfa_policy_arn" {
    value = aws_iam_policy.mfa_enforcement.arn
}

output "mfa_policy_description" {
    value = aws_iam_policy.mfa_enforcement.description
}

output "mfa_policy_name" {
    value = aws_iam_policy.mfa_enforcement.name
}

output "mfa_policy_path" {
    value = aws_iam_policy.mfa_enforcement.path
}

output "mfa_policy_policy" {
    value = aws_iam_policy.mfa_enforcement.policy
}
