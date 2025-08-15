# Outputs for AWS Backup Status Reporter Module

# S3 Bucket
output "s3_bucket_name" {
  description = "The name of the S3 bucket storing backup status reports"
  value       = aws_s3_bucket.backup_report.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket storing backup status reports"
  value       = aws_s3_bucket.backup_report.arn
}

output "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  value       = aws_s3_bucket.backup_report.bucket_domain_name
}

# Lambda Function
output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.backup_reporter.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.backup_reporter.arn
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role used by Lambda"
  value       = aws_iam_role.backup_reporter.arn
}

# CloudWatch
output "cloudwatch_event_rule_name" {
  description = "The name of the CloudWatch Event rule"
  value       = aws_cloudwatch_event_rule.backup_report_schedule.name
}

output "cloudwatch_event_rule_arn" {
  description = "The ARN of the CloudWatch Event rule"
  value       = aws_cloudwatch_event_rule.backup_report_schedule.arn
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Lambda logs"
  value       = aws_cloudwatch_log_group.backup_reporter.name
}

# Customer Information
output "customer_identifier" {
  description = "The resolved customer identifier used for tagging and report naming"
  value       = local.customer_identifier
}

# Report Configuration
output "report_schedule" {
  description = "The schedule expression for report generation"
  value       = var.schedule_expression
}

output "vaults_monitored" {
  description = "List of vault names being monitored"
  value = compact([
    var.enable_hourly_report ? local.hourly_vault_name : "",
    var.enable_daily_report ? local.daily_vault_name : "",
    var.enable_weekly_report ? local.weekly_vault_name : "",
    var.enable_monthly_report ? local.monthly_vault_name : "",
    var.enable_yearly_report ? local.yearly_vault_name : ""
  ])
}

output "vault_reporting_status" {
  description = "Status of which vault types are enabled for reporting"
  value = {
    hourly  = var.enable_hourly_report
    daily   = var.enable_daily_report
    weekly  = var.enable_weekly_report
    monthly = var.enable_monthly_report
    yearly  = var.enable_yearly_report
  }
}

# Report Path
output "report_path_pattern" {
  description = "S3 path pattern where reports will be stored"
  value       = var.s3_key_prefix != "" ? "s3://${aws_s3_bucket.backup_report.id}/${var.s3_key_prefix}/YYYY/MM/${lower(replace(local.customer_identifier, " ", "-"))}-backup-status-report-YYYY-MM-DD.pdf" : "s3://${aws_s3_bucket.backup_report.id}/YYYY/MM/${lower(replace(local.customer_identifier, " ", "-"))}-backup-status-report-YYYY-MM-DD.pdf"
}

output "s3_key_prefix" {
  description = "The S3 key prefix configured for backup reports"
  value       = var.s3_key_prefix
}