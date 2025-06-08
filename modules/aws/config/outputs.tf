# Outputs for AWS Config Module

output "config_recorder_id" {
  description = "The ID of the AWS Config recorder"
  value       = length(aws_config_configuration_recorder.config) > 0 ? aws_config_configuration_recorder.config[0].id : null
}

output "config_recorder_name" {
  description = "The name of the AWS Config Configuration Recorder"
  value       = length(aws_config_configuration_recorder.config) > 0 ? aws_config_configuration_recorder.config[0].name : null
}

output "config_bucket_arn" {
  description = "The ARN of the S3 bucket used for AWS Config recordings"
  value       = aws_s3_bucket.config_bucket.arn
}

output "config_iam_role_arn" {
  description = "The ARN of the IAM role used for AWS Config"
  value       = aws_iam_role.config_role.arn
}

output "config_bucket_id" {
  description = "The ID of the S3 bucket used for AWS Config recordings"
  value       = aws_s3_bucket.config_bucket.id
}

output "delivery_channel_id" {
  description = "The ID of the AWS Config delivery channel"
  value       = aws_config_delivery_channel.config.id
}

output "compliance_reporter_lambda_arn" {
  description = "The ARN of the compliance reporter Lambda function (only if enabled)"
  value       = var.enable_compliance_reporter ? aws_lambda_function.compliance_reporter[0].arn : null
}

output "compliance_reporter_lambda_role_arn" {
  description = "The ARN of the IAM role for the compliance reporter Lambda function (only if enabled)"
  value       = var.enable_compliance_reporter ? aws_iam_role.reporter_lambda_role[0].arn : null
}

# Config Rules Outputs
output "password_policy_rule_arn" {
  description = "The ARN of the IAM password policy Config rule"
  value       = var.enable_iam_password_policy_rule ? aws_config_config_rule.iam_password_policy[0].arn : null
}

output "ebs_encryption_rule_arn" {
  description = "The ARN of the EBS encryption Config rule"
  value       = var.enable_ebs_encryption_rule ? aws_config_config_rule.ebs_encryption[0].arn : null
}

output "iam_user_access_key_age_rule_arn" {
  description = "The ARN of the IAM user access key age Config rule"
  value       = var.enable_iam_user_access_key_age_rule ? aws_config_config_rule.iam_user_access_key_age[0].arn : null
}

output "config_rules_arns" {
  description = "Map of all Config rules ARNs"
  value = {
    ebs-encryption-enabled = var.enable_ebs_encryption_rule ? aws_config_config_rule.ebs_encryption[0].arn : null
    iam_password_policy = var.enable_iam_password_policy_rule ? aws_config_config_rule.iam_password_policy[0].arn : null
    s3_public_read_prohibited = var.enable_s3_public_access_rules ? aws_config_config_rule.s3_bucket_public_read_prohibited[0].arn : null
    s3_public_write_prohibited = var.enable_s3_public_access_rules ? aws_config_config_rule.s3_bucket_public_write_prohibited[0].arn : null
    iam_root_mfa = var.enable_iam_root_key_rule ? aws_config_config_rule.iam_root_access_key_check[0].arn : null
    iam_user_mfa = var.enable_mfa_for_iam_console_rule ? aws_config_config_rule.mfa_enabled_for_iam_console_access[0].arn : null
    ec2_volume_inuse = var.enable_ec2_volume_inuse_rule ? aws_config_config_rule.ec2_volume_inuse_check[0].arn : null
    eip_attached = var.enable_eip_attached_rule ? aws_config_config_rule.eip_attached[0].arn : null
    rds_storage_encrypted = var.enable_rds_storage_encrypted_rule ? aws_config_config_rule.rds_storage_encrypted[0].arn : null
<<<<<<< Updated upstream
    iam_user_access_key_age = var.enable_iam_user_access_key_age_rule ? aws_config_config_rule.iam_user_access_key_age[0].arn : null
=======
    access_keys_rotated = aws_config_config_rule.access_keys_rotated[0].arn
>>>>>>> Stashed changes
  }
}
