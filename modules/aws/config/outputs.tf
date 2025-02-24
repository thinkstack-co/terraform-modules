# Outputs for AWS Config Module

output "config_recorder_id" {
  description = "The ID of the AWS Config recorder"
  value       = aws_config_configuration_recorder.config.id
}

output "config_bucket_arn" {
  description = "The ARN of the S3 bucket used for AWS Config recordings"
  value       = aws_s3_bucket.config.arn
}

output "config_iam_role_arn" {
  description = "The ARN of the IAM role used for AWS Config"
  value       = aws_iam_role.config_role.arn
}

output "config_bucket_id" {
  description = "The ID of the S3 bucket used for AWS Config recordings"
  value       = aws_s3_bucket.config.id
}

# Config Rules Outputs
output "password_policy_rule_arn" {
  description = "The ARN of the IAM password policy Config rule"
  value       = aws_config_config_rule.iam_password_policy.arn
}

output "ebs_encryption_rule_arn" {
  description = "The ARN of the EBS encryption Config rule"
  value       = aws_config_config_rule.ebs_encryption.arn
}

output "config_rules_arns" {
  description = "Map of all Config rules ARNs"
  value = {
    password_policy = aws_config_config_rule.iam_password_policy.arn
    ebs_encryption = aws_config_config_rule.ebs_encryption.arn
    ec2_monitoring = aws_config_config_rule.ec2_detailed_monitoring.arn
    s3_public_access = aws_config_config_rule.s3_public_access.arn
    root_mfa = aws_config_config_rule.root_mfa.arn
    iam_user_mfa = aws_config_config_rule.iam_user_mfa.arn
  }
}
