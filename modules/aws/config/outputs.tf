# Outputs for AWS Config Module

output "config_recorder_id" {
  description = "The ID of the AWS Config recorder"
  value       = aws_config_configuration_recorder.config.id
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

# Config Rules Outputs
output "password_policy_rule_arn" {
  description = "The ARN of the IAM password policy Config rule"
  value       = var.enable_config_rules ? aws_config_config_rule.iam_password_policy[0].arn : null
}

output "ebs_encryption_rule_arn" {
  description = "The ARN of the EBS encryption Config rule"
  value       = var.enable_config_rules ? aws_config_config_rule.ebs_encryption[0].arn : null
}

output "config_rules_arns" {
  description = "Map of all Config rules ARNs"
  value = var.enable_config_rules ? {
    password_policy = aws_config_config_rule.iam_password_policy[0].arn
    ebs_encryption  = aws_config_config_rule.ebs_encryption[0].arn
  } : {}
}

output "config_notification_topic_arn" {
  description = "The ARN of the SNS topic used for AWS Config notifications"
  value       = aws_sns_topic.config_notifications.arn
}

output "compliance_report_rule_arn" {
  description = "The ARN of the CloudWatch event rule for compliance reports"
  value       = var.create_compliance_report ? aws_cloudwatch_event_rule.compliance_report[0].arn : null
}

# Config Processor Outputs
output "config_processor_lambda_arn" {
  description = "The ARN of the Lambda function for processing Config snapshots"
  value       = var.enable_config_processor ? aws_lambda_function.config_processor[0].arn : null
}

output "config_processor_role_arn" {
  description = "The ARN of the IAM role for the Config processor Lambda function"
  value       = var.enable_config_processor ? aws_iam_role.config_processor[0].arn : null
}
