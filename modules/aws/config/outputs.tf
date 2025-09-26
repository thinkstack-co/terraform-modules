# Outputs for AWS Config Module

# Core AWS Config Service Outputs
# These outputs provide information about the main AWS Config service components

output "config_recorder_id" {
  description = "The ID of the AWS Config recorder"
  # Returns the ID of the configuration recorder if it exists, null otherwise
  # Used to reference the recorder in other resources or modules
  value       = length(aws_config_configuration_recorder.config) > 0 ? aws_config_configuration_recorder.config[0].id : null
}

output "config_recorder_name" {
  description = "The name of the AWS Config Configuration Recorder"
  # Returns the name of the configuration recorder for identification purposes
  # Useful for debugging and cross-referencing with AWS Console
  value       = length(aws_config_configuration_recorder.config) > 0 ? aws_config_configuration_recorder.config[0].name : null
}

output "config_bucket_arn" {
  description = "The ARN of the S3 bucket used for AWS Config recordings"
  # Returns the ARN of the S3 bucket where Config stores configuration snapshots and history files
  # Used for setting up bucket policies, cross-account access, or lifecycle rules
  value       = aws_s3_bucket.config_bucket.arn
}

output "config_iam_role_arn" {
  description = "The ARN of the IAM role used for AWS Config"
  # Returns the ARN of the service-linked role that AWS Config uses to access AWS resources
  # Used for troubleshooting permissions or setting up cross-account access
  value       = aws_iam_role.config_role.arn
}

output "config_bucket_id" {
  description = "The ID of the S3 bucket used for AWS Config recordings"
  # Returns the bucket name/ID for direct S3 operations or bucket policy references
  # Useful when you need to reference the bucket in other Terraform resources
  value       = aws_s3_bucket.config_bucket.id
}

output "delivery_channel_id" {
  description = "The ID of the AWS Config delivery channel"
  # Returns the ID of the delivery channel that defines where Config sends data
  # Used for managing delivery channel settings or troubleshooting delivery issues
  value       = aws_config_delivery_channel.config.id
}

# Compliance Reporter Lambda Function Outputs
# These outputs provide information about the optional compliance reporting Lambda function

output "compliance_reporter_lambda_arn" {
  description = "The ARN of the compliance reporter Lambda function (only if enabled)"
  # Returns the ARN of the Lambda function that generates compliance reports
  # Only available when enable_compliance_reporter is true, null otherwise
  # Used for invoking the function or setting up triggers
  value       = var.enable_compliance_reporter ? aws_lambda_function.compliance_reporter[0].arn : null
}

output "compliance_reporter_lambda_role_arn" {
  description = "The ARN of the IAM role for the compliance reporter Lambda function (only if enabled)"
  # Returns the ARN of the IAM role used by the compliance reporter Lambda
  # Only available when enable_compliance_reporter is true, null otherwise
  # Used for troubleshooting permissions or adding additional policies
  value       = var.enable_compliance_reporter ? aws_iam_role.reporter_lambda_role[0].arn : null
}

# AWS Config Rules Outputs
# These outputs provide ARNs for individual Config rules and a consolidated map
# Config rules evaluate AWS resources for compliance with configuration best practices

output "password_policy_rule_arn" {
  description = "The ARN of the IAM password policy Config rule"
  # Returns the ARN of the Config rule that checks IAM password policy compliance
  # Only available when enable_iam_password_policy_rule is true, null otherwise
  # Used for referencing the rule in remediation actions or compliance reports
  value       = var.enable_iam_password_policy_rule ? aws_config_config_rule.iam_password_policy[0].arn : null
}

output "ebs_encryption_rule_arn" {
  description = "The ARN of the EBS encryption Config rule"
  # Returns the ARN of the Config rule that checks if EBS volumes are encrypted
  # Only available when enable_ebs_encryption_rule is true, null otherwise
  # Used for compliance monitoring and automated remediation workflows
  value       = var.enable_ebs_encryption_rule ? aws_config_config_rule.ebs_encryption[0].arn : null
}

output "iam_user_access_key_age_rule_arn" {
  description = "The ARN of the IAM user access key age Config rule"
  # Returns the ARN of the Config rule that checks for old IAM access keys (>90 days)
  # Only available when enable_iam_user_access_key_age_rule is true, null otherwise
  # Used for security compliance and access key rotation enforcement
  value       = var.enable_iam_user_access_key_age_rule ? aws_config_config_rule.access_keys_rotated[0].arn : null
}

output "config_rules_arns" {
  description = "Map of all Config rules ARNs"
  # Returns a comprehensive map of all enabled Config rules with their ARNs
  # Used by the compliance reporter Lambda function to generate reports
  # Each rule is conditionally included based on its corresponding enable variable
  # Key format matches the rule names used in compliance reporting
  value = {
    # Storage and encryption compliance rules
    ebs-encryption-enabled     = var.enable_ebs_encryption_rule ? aws_config_config_rule.ebs_encryption[0].arn : null
    rds_storage_encrypted      = var.enable_rds_storage_encrypted_rule ? aws_config_config_rule.rds_storage_encrypted[0].arn : null,
    
    # IAM security and access management rules
    iam_password_policy        = var.enable_iam_password_policy_rule ? aws_config_config_rule.iam_password_policy[0].arn : null
    iam_user_mfa               = var.enable_mfa_for_iam_console_rule ? aws_config_config_rule.mfa_enabled_for_iam_console_access[0].arn : null
    iam-user-access-key-age    = var.enable_iam_user_access_key_age_rule ? aws_config_config_rule.access_keys_rotated[0].arn : null
    
    # S3 security rules
    s3_public_read_prohibited  = var.enable_s3_public_access_rules ? aws_config_config_rule.s3_bucket_public_read_prohibited[0].arn : null
    s3_public_write_prohibited = var.enable_s3_public_access_rules ? aws_config_config_rule.s3_bucket_public_write_prohibited[0].arn : null
    
    # EC2 resource utilization rules
    ec2_volume_inuse           = var.enable_ec2_volume_inuse_rule ? aws_config_config_rule.ec2_volume_inuse_check[0].arn : null
    eip_attached               = var.enable_eip_attached_rule ? aws_config_config_rule.eip_attached[0].arn : null
  }
}
