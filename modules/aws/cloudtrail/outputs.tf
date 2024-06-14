# Output for KMS key
output "cloudtrail_kms_key" {
  description = "The Amazon Resource Name (ARN) of the KMS key"
  value       = aws_kms_key.cloudtrail.arn
}

# Output for CloudWatch Log Group
output "cloudtrail_log_group" {
  description = "The Amazon Resource Name (ARN) of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.cloudtrail.arn
}

# Output for IAM policy
output "cloudtrail_iam_policy" {
  description = "The Amazon Resource Name (ARN) of the IAM policy"
  value       = aws_iam_policy.cloudtrail.arn
}

# Output for IAM role
output "cloudtrail_iam_role" {
  description = "The Amazon Resource Name (ARN) of the IAM role"
  value       = aws_iam_role.cloudtrail.arn
}

# Output for CloudTrail
output "cloudtrail" {
  description = "The Amazon Resource Name (ARN) of the CloudTrail"
  value       = aws_cloudtrail.cloudtrail.arn
}

# Output for S3 bucket
output "cloudtrail_s3_bucket" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.cloudtrail.id
}

# Output for S3 bucket public block
output "cloudtrail_s3_bucket_public_block" {
  description = "The ID of the S3 bucket public access block"
  value       = aws_s3_bucket_public_access_block.cloudtrail.id
}

output "cloudtrail_policy_json" {
  description = "The JSON content of the IAM policy document for CloudTrail."
  value       = data.aws_iam_policy_document.cloudtrail.json
}

output "cloudtrail_assume_policy_json" {
  description = "The JSON content of the IAM policy document for CloudTrail Assume."
  value       = data.aws_iam_policy_document.cloudtrail_assume.json
}

output "key_policy_json" {
  description = "The JSON content of the IAM policy document for Key Policy."
  value       = data.aws_iam_policy_document.key_policy.json
}

output "cloudtrail_s3_bucket_policy" {
  description = "The JSON policy for the CloudTrail S3 bucket."
  value       = aws_s3_bucket_policy.cloudtrail.policy
}

