##########################
# S3 Bucket Outputs
##########################

output "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.bucket.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.bucket.arn
}

##########################
# S3 Bucket Configurations
##########################

output "s3_bucket_public_access_block" {
  description = "Public access block settings for the S3 bucket"
  value       = aws_s3_bucket_public_access_block.public_access_block
  depends_on  = [aws_s3_bucket_public_access_block.public_access_block]
}

output "s3_bucket_versioning" {
  description = "Versioning settings for the S3 bucket"
  value       = aws_s3_bucket_versioning.versioning
  depends_on  = [aws_s3_bucket_versioning.versioning]
}

output "s3_bucket_accelerate_configuration" {
  description = "Acceleration settings for the S3 bucket"
  value       = aws_s3_bucket_accelerate_configuration.acceleration
  depends_on  = [aws_s3_bucket_accelerate_configuration.acceleration]
}

output "s3_bucket_intelligent_tiering_configuration" {
  description = "Intelligent tiering configuration for the S3 bucket"
  value       = aws_s3_bucket_intelligent_tiering_configuration.intelligent_tiering
  depends_on  = [aws_s3_bucket_intelligent_tiering_configuration.intelligent_tiering]
}

output "s3_bucket_lifecycle_configuration" {
  description = "Lifecycle configuration for the S3 bucket"
  value       = aws_s3_bucket_lifecycle_configuration.lifecycle
  depends_on  = [aws_s3_bucket_lifecycle_configuration.lifecycle]
}

output "s3_bucket_server_side_encryption_configuration" {
  description = "Server side encryption configuration for the S3 bucket"
  value       = aws_s3_bucket_server_side_encryption_configuration.sse
}

output "s3_bucket_replication_configuration" {
  description = "Replication configuration for the S3 bucket"
  value       = aws_s3_bucket_replication_configuration.replication_configuration
  depends_on  = [aws_s3_bucket_replication_configuration.replication_configuration]
}

##########################
# IAM Outputs
##########################

output "iam_source_replication_role_arn" {
  description = "ARN of the IAM role for source bucket replication"
  value       = var.enable_replication ? aws_iam_role.source_replication_role[0].arn : null
}

output "iam_destination_replication_role_arn" {
  description = "ARN of the IAM role for destination bucket replication"
  value       = var.enable_replication ? aws_iam_role.destination_replication_role[0].arn : null
}

##########################
# Destination S3 Bucket Outputs
##########################

output "destination_bucket_id" {
  description = "The ID of the destination S3 bucket (if created)"
  value       = var.create_destination_bucket ? aws_s3_bucket.destination_bucket[0].id : null
  depends_on  = [aws_s3_bucket.destination_bucket]
}

output "destination_bucket_arn" {
  description = "The ARN of the destination S3 bucket (if created)"
  value       = var.create_destination_bucket ? aws_s3_bucket.destination_bucket[0].arn : null
  depends_on  = [aws_s3_bucket.destination_bucket]
}

output "destination_bucket_versioning" {
  description = "Versioning settings for the destination S3 bucket (if created)"
  value       = aws_s3_bucket_versioning.destination_bucket_versioning
  depends_on  = [aws_s3_bucket_versioning.destination_bucket_versioning]
}

############
# SSE
############

output "kms_key_arn" {
  description = "The ARN of the created KMS key"
  value       = var.create_kms_key ? aws_kms_key.s3_encryption_key[0].arn : null
  depends_on  = [aws_kms_key.s3_encryption_key]
}

##########################
# JSON Outputs
##########################

output "source_replication_policy_document" {
  description = "IAM policy document for source bucket replication permissions"
  value       = var.enable_replication ? data.aws_iam_policy_document.source_replication_policy[0].json : null
}

output "destination_replication_policy_document" {
  description = "IAM policy document for destination bucket replication permissions"
  value       = var.enable_replication ? data.aws_iam_policy_document.destination_replication_policy[0].json : null
}