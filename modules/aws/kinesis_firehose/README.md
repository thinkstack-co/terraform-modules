Kinesis Firehose Module
=================

This module sets up each componenet required to build a Kinesis Firehose stream that will deliver to a dedicated S3 bucket. By default this module will be set up to work without any changes to variables. The result of this module creates a unique S3 bucket with a prefix of 'kinesis-firehose-', an IAM policy and IAM role which can be used with to deliver logs or data to that S3 bucket.


# Usage

    module "kinesis_firehose" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/kinesis_firehose"

        firehose_name = "kinesis_ingestion"
    }

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.firehose_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.firehose_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.role_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_firehose_delivery_stream.extended_s3_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_s3_bucket.firehose_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firehose_backup_error_output_prefix"></a> [firehose\_backup\_error\_output\_prefix](#input\_firehose\_backup\_error\_output\_prefix) | (Optional) Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects. | `string` | `""` | no |
| <a name="input_firehose_backup_prefix"></a> [firehose\_backup\_prefix](#input\_firehose\_backup\_prefix) | (Optional) The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket | `string` | `""` | no |
| <a name="input_firehose_buffer_interval"></a> [firehose\_buffer\_interval](#input\_firehose\_buffer\_interval) | (Optional) Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300. | `number` | `300` | no |
| <a name="input_firehose_buffer_size"></a> [firehose\_buffer\_size](#input\_firehose\_buffer\_size) | (Optional) Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher. | `number` | `5` | no |
| <a name="input_firehose_cloudwatch_logging_enabled"></a> [firehose\_cloudwatch\_logging\_enabled](#input\_firehose\_cloudwatch\_logging\_enabled) | (Optional) Enables or disables the logging. Defaults to false. | `bool` | `false` | no |
| <a name="input_firehose_cloudwatch_logging_log_group_name"></a> [firehose\_cloudwatch\_logging\_log\_group\_name](#input\_firehose\_cloudwatch\_logging\_log\_group\_name) | (Optional) The CloudWatch group name for logging. This value is required if enabled is true. | `string` | `null` | no |
| <a name="input_firehose_cloudwatch_logging_log_stream_name"></a> [firehose\_cloudwatch\_logging\_log\_stream\_name](#input\_firehose\_cloudwatch\_logging\_log\_stream\_name) | (Optional) The CloudWatch log stream name for logging. This value is required if enabled is true. | `string` | `null` | no |
| <a name="input_firehose_compression_format"></a> [firehose\_compression\_format](#input\_firehose\_compression\_format) | (Optional) The compression format. If no value is specified, the default is UNCOMPRESSED. Other supported values are GZIP, ZIP, Snappy, & HADOOP\_SNAPPY. | `string` | `"UNCOMPRESSED"` | no |
| <a name="input_firehose_destination"></a> [firehose\_destination](#input\_firehose\_destination) | (Optional) This is the destination to where the data is delivered. The only options are s3 (Deprecated, use extended\_s3 instead), extended\_s3, redshift, elasticsearch, splunk, and http\_endpoint. | `string` | `"extended_s3"` | no |
| <a name="input_firehose_dynamic_partitioning_enabled"></a> [firehose\_dynamic\_partitioning\_enabled](#input\_firehose\_dynamic\_partitioning\_enabled) | (Optional) Enables or disables dynamic partitioning. Defaults to false. | `bool` | `false` | no |
| <a name="input_firehose_dynamic_partitioning_retry_duration"></a> [firehose\_dynamic\_partitioning\_retry\_duration](#input\_firehose\_dynamic\_partitioning\_retry\_duration) | (Optional) Total amount of seconds Firehose spends on retries. Valid values between 0 and 7200. Default is 300. | `number` | `300` | no |
| <a name="input_firehose_error_output_prefix"></a> [firehose\_error\_output\_prefix](#input\_firehose\_error\_output\_prefix) | (Optional) Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects. | `string` | `""` | no |
| <a name="input_firehose_key_arn"></a> [firehose\_key\_arn](#input\_firehose\_key\_arn) | (Optional) Amazon Resource Name (ARN) of the encryption key. Required when key\_type is CUSTOMER\_MANAGED\_CMK. | `string` | `""` | no |
| <a name="input_firehose_key_type"></a> [firehose\_key\_type](#input\_firehose\_key\_type) | (Optional) Type of encryption key. Default is AWS\_OWNED\_CMK. Valid values are AWS\_OWNED\_CMK and CUSTOMER\_MANAGED\_CMK | `string` | `"AWS_OWNED_CMK"` | no |
| <a name="input_firehose_kms_key_arn"></a> [firehose\_kms\_key\_arn](#input\_firehose\_kms\_key\_arn) | (Optional) Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used. | `string` | `""` | no |
| <a name="input_firehose_name"></a> [firehose\_name](#input\_firehose\_name) | (Required) A name to identify the stream. This is unique to the AWS account and region the Stream is created in. | `string` | n/a | yes |
| <a name="input_firehose_prefix"></a> [firehose\_prefix](#input\_firehose\_prefix) | (Optional) The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket | `string` | `""` | no |
| <a name="input_firehose_s3_backup_mode"></a> [firehose\_s3\_backup\_mode](#input\_firehose\_s3\_backup\_mode) | (Optional) The Amazon S3 backup mode. Valid values are Disabled and Enabled. Default value is Enabled. | `string` | `"Enabled"` | no |
| <a name="input_firehose_server_side_encryption_enabled"></a> [firehose\_server\_side\_encryption\_enabled](#input\_firehose\_server\_side\_encryption\_enabled) | (Optional) Encrypt at rest options. Server-side encryption should not be enabled when a kinesis stream is configured as the source of the firehose delivery stream. | `bool` | `true` | no |
| <a name="input_iam_policy_description"></a> [iam\_policy\_description](#input\_iam\_policy\_description) | (Optional, Forces new resource) Description of the IAM policy. | `string` | `"Used with kinesis firehose send data to a dedicated S3 bucket"` | no |
| <a name="input_iam_policy_name_prefix"></a> [iam\_policy\_name\_prefix](#input\_iam\_policy\_name\_prefix) | (Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name. | `string` | `"kinesis_firehose_policy_"` | no |
| <a name="input_iam_policy_path"></a> [iam\_policy\_path](#input\_iam\_policy\_path) | (Optional, default '/') Path in which to create the policy. See IAM Identifiers for more information. | `string` | `"/"` | no |
| <a name="input_iam_role_assume_role_policy"></a> [iam\_role\_assume\_role\_policy](#input\_iam\_role\_assume\_role\_policy) | (Required) The policy that grants an entity permission to assume the role. | `string` | `"{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"firehose.amazonaws.com\"\n      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n"` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | (Optional) The description of the role. | `string` | `"Role utilized for Kinesis Firehose to read and write to it's own dedicated S3 bucket"` | no |
| <a name="input_iam_role_force_detach_policies"></a> [iam\_role\_force\_detach\_policies](#input\_iam\_role\_force\_detach\_policies) | (Optional) Specifies to force detaching any policies the role has before destroying it. Defaults to false. | `bool` | `false` | no |
| <a name="input_iam_role_max_session_duration"></a> [iam\_role\_max\_session\_duration](#input\_iam\_role\_max\_session\_duration) | (Optional) The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours. | `number` | `3600` | no |
| <a name="input_iam_role_name_prefix"></a> [iam\_role\_name\_prefix](#input\_iam\_role\_name\_prefix) | (Required, Forces new resource) Creates a unique friendly name beginning with the specified prefix. Conflicts with name. | `string` | `"kinesis_firehose_role_"` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | (Optional) The ARN of the policy that is used to set the permissions boundary for the role. | `string` | `""` | no |
| <a name="input_s3_acl"></a> [s3\_acl](#input\_s3\_acl) | (Optional) The canned ACL to apply. Defaults to private. | `string` | `"private"` | no |
| <a name="input_s3_bucket_prefix"></a> [s3\_bucket\_prefix](#input\_s3\_bucket\_prefix) | (Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. | `string` | `"kinesis-firehose-"` | no |
| <a name="input_s3_lifecycle_enabled"></a> [s3\_lifecycle\_enabled](#input\_s3\_lifecycle\_enabled) | (Required) Specifies lifecycle rule status. | `bool` | `true` | no |
| <a name="input_s3_lifecycle_expiration_days"></a> [s3\_lifecycle\_expiration\_days](#input\_s3\_lifecycle\_expiration\_days) | (Optional) Specifies the number of days after object creation when the specific rule action takes effect. | `number` | `7` | no |
| <a name="input_s3_lifecycle_id"></a> [s3\_lifecycle\_id](#input\_s3\_lifecycle\_id) | (Optional) Unique identifier for the rule. Must be less than or equal to 255 characters in length. | `string` | `"delete_after_7_days"` | no |
| <a name="input_s3_lifecycle_prefix"></a> [s3\_lifecycle\_prefix](#input\_s3\_lifecycle\_prefix) | (Optional) Object key prefix identifying one or more objects to which the rule applies. | `string` | `""` | no |
| <a name="input_s3_policy"></a> [s3\_policy](#input\_s3\_policy) | (Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the object. | `map` | <pre>{<br>  "created_by": "ThinkStack",<br>  "environment": "prod",<br>  "priority": "low",<br>  "terraform": "true"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the kinesis firehose stream |
<!-- END_TF_DOCS -->