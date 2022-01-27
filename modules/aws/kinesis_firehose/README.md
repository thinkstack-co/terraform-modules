Kinesis Firehose Module
=================

This module sets up each componenet required to build a Kinesis Firehose stream that will deliver to a dedicated S3 bucket. By default this module will be set up to work without any changes to variables. The result of this module creates a unique S3 bucket with a prefix of 'kinesis-firehose-', an IAM policy and IAM role which can be used with to deliver logs or data to that S3 bucket.


# Usage

    module "kinesis_firehose" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/kinesis_firehose"

        firehose_name = "kinesis_ingestion"
    }

# Variables
    firehose_name
    firehose_destination
    firehose_server_side_encryption_enabled
    firehose_key_type
    firehose_key_arn
    firehose_prefix
    firehose_buffer_size
    firehose_buffer_interval
    firehose_compression_format
    firehose_error_output_prefix
    firehose_kms_key_arn
    s3_acl
    s3_bucket_prefix
    s3_policy
    s3_lifecycle_id
    s3_lifecycle_prefix
    s3_lifecycle_enabled
    s3_lifecycle_expiration_days
    iam_policy_description
    iam_policy_name_prefix
    iam_policy_path
    iam_role_assume_role_policy
    iam_role_description
    iam_role_force_detach_policies
    iam_role_max_session_duration
    iam_role_name_prefix
    iam_role_permissions_boundary
    tags
## Required
    firehose_name

## Optional
    firehose_destination
    firehose_server_side_encryption_enabled
    firehose_key_type
    firehose_key_arn
    firehose_prefix
    firehose_buffer_size
    firehose_buffer_interval
    firehose_compression_format
    firehose_error_output_prefix
    firehose_kms_key_arn
    s3_acl
    s3_bucket_prefix
    s3_policy
    s3_lifecycle_id
    s3_lifecycle_prefix
    s3_lifecycle_enabled
    s3_lifecycle_expiration_days
    iam_policy_description
    iam_policy_name_prefix
    iam_policy_path
    iam_role_assume_role_policy
    iam_role_description
    iam_role_force_detach_policies
    iam_role_max_session_duration
    iam_role_name_prefix
    iam_role_permissions_boundary
    tags
# Outputs
    arn
