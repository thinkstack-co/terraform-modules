<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.destination_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.source_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.destination_replication_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.s3_kms_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.source_replication_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.destination_replication_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_kms_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.source_replication_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.s3_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.destination_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_accelerate_configuration.acceleration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_accelerate_configuration) | resource |
| [aws_s3_bucket_intelligent_tiering_configuration.intelligent_tiering](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_intelligent_tiering_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.replication_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.sse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.destination_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.destination_replication_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.source_replication_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerate_status"></a> [accelerate\_status](#input\_accelerate\_status) | The accelerate status of the bucket, 'Enabled' or 'Suspended'. | `string` | `null` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Whether Amazon S3 should block public ACLs for the bucket. | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for the bucket. | `bool` | `true` | no |
| <a name="input_bucket_acl"></a> [bucket\_acl](#input\_bucket\_acl) | The canned ACL for the S3 bucket. | `string` | `"private"` | no |
| <a name="input_bucket_key_enabled"></a> [bucket\_key\_enabled](#input\_bucket\_key\_enabled) | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. | `bool` | `null` | no |
| <a name="input_bucket_name_prefix"></a> [bucket\_name\_prefix](#input\_bucket\_name\_prefix) | The bucket name prefix for the S3 bucket. | `string` | `"example-bucket"` | no |
| <a name="input_create_destination_bucket"></a> [create\_destination\_bucket](#input\_create\_destination\_bucket) | Flag to create a destination bucket for replication. | `bool` | `false` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Determines if a new KMS key should be created for server-side encryption. | `bool` | `false` | no |
| <a name="input_days_to_deep_archive"></a> [days\_to\_deep\_archive](#input\_days\_to\_deep\_archive) | Number of days to transition to DEEP\_ARCHIVE storage class | `any` | `null` | no |
| <a name="input_days_to_glacier_flexible"></a> [days\_to\_glacier\_flexible](#input\_days\_to\_glacier\_flexible) | Number of days to transition to GLACIER\_FLEXIBLE\_RETRIEVAL storage class | `any` | `null` | no |
| <a name="input_days_to_glacier_instant"></a> [days\_to\_glacier\_instant](#input\_days\_to\_glacier\_instant) | Number of days to transition to GLACIER\_INSTANT\_RETRIEVAL storage class | `any` | `null` | no |
| <a name="input_days_to_onezone_ia"></a> [days\_to\_onezone\_ia](#input\_days\_to\_onezone\_ia) | Number of days to transition to ONEZONE\_IA storage class | `any` | `null` | no |
| <a name="input_days_to_standard_ia"></a> [days\_to\_standard\_ia](#input\_days\_to\_standard\_ia) | Number of days to transition to STANDARD\_IA storage class | `any` | `null` | no |
| <a name="input_destination_bucket_acl"></a> [destination\_bucket\_acl](#input\_destination\_bucket\_acl) | The ACL for the destination bucket. | `string` | `null` | no |
| <a name="input_destination_bucket_mfa_delete"></a> [destination\_bucket\_mfa\_delete](#input\_destination\_bucket\_mfa\_delete) | Flag to enable or disable MFA delete for the destination bucket. | `string` | `"Disabled"` | no |
| <a name="input_destination_bucket_name"></a> [destination\_bucket\_name](#input\_destination\_bucket\_name) | The name for the destination bucket. | `string` | `null` | no |
| <a name="input_destination_bucket_status"></a> [destination\_bucket\_status](#input\_destination\_bucket\_status) | Flag to enable or disable MFA delete for the destination bucket. | `string` | `"Disabled"` | no |
| <a name="input_destroy_objects_with_bucket"></a> [destroy\_objects\_with\_bucket](#input\_destroy\_objects\_with\_bucket) | Determines if objects should be destroyed when bucket is destroyed. | `bool` | `false` | no |
| <a name="input_enable_acceleration"></a> [enable\_acceleration](#input\_enable\_acceleration) | Flag to enable or disable acceleration for the S3 bucket. | `bool` | `false` | no |
| <a name="input_enable_deep_archive"></a> [enable\_deep\_archive](#input\_enable\_deep\_archive) | Enable transition to DEEP\_ARCHIVE storage class | `bool` | `null` | no |
| <a name="input_enable_glacier_flexible"></a> [enable\_glacier\_flexible](#input\_enable\_glacier\_flexible) | Enable transition to GLACIER\_FLEXIBLE\_RETRIEVAL storage class | `bool` | `null` | no |
| <a name="input_enable_glacier_instant"></a> [enable\_glacier\_instant](#input\_enable\_glacier\_instant) | Enable transition to GLACIER\_INSTANT\_RETRIEVAL storage class | `bool` | `null` | no |
| <a name="input_enable_intelligent_tiering"></a> [enable\_intelligent\_tiering](#input\_enable\_intelligent\_tiering) | Flag to enable or disable intelligent tiering for the S3 bucket. | `bool` | `false` | no |
| <a name="input_enable_intelligent_tiering_archive_access"></a> [enable\_intelligent\_tiering\_archive\_access](#input\_enable\_intelligent\_tiering\_archive\_access) | Enable the Archive Access tier in Intelligent Tiering | `bool` | `null` | no |
| <a name="input_enable_intelligent_tiering_deep_archive_access"></a> [enable\_intelligent\_tiering\_deep\_archive\_access](#input\_enable\_intelligent\_tiering\_deep\_archive\_access) | Enable the Deep Archive Access tier in Intelligent Tiering | `bool` | `null` | no |
| <a name="input_enable_lifecycle_configuration"></a> [enable\_lifecycle\_configuration](#input\_enable\_lifecycle\_configuration) | Flag to enable or disable lifecycle configuration. | `bool` | `false` | no |
| <a name="input_enable_onezone_ia"></a> [enable\_onezone\_ia](#input\_enable\_onezone\_ia) | Enable transition to ONEZONE\_IA storage class | `bool` | `null` | no |
| <a name="input_enable_public_access_block"></a> [enable\_public\_access\_block](#input\_enable\_public\_access\_block) | Flag to enable or disable public access block. | `bool` | `true` | no |
| <a name="input_enable_replication"></a> [enable\_replication](#input\_enable\_replication) | Flag to enable or disable replication. | `bool` | `false` | no |
| <a name="input_enable_standard_ia"></a> [enable\_standard\_ia](#input\_enable\_standard\_ia) | Enable transition to STANDARD\_IA storage class | `bool` | `null` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Flag to enable or disable versioning for the S3 bucket. | `bool` | `false` | no |
| <a name="input_filter_prefix"></a> [filter\_prefix](#input\_filter\_prefix) | Only objects with this prefix will be considered for intelligent tiering. | `string` | `null` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for the bucket. | `bool` | `true` | no |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | AWS KMS master key ID used for the SSE-KMS encryption. | `string` | `null` | no |
| <a name="input_lifecycle_rule_id"></a> [lifecycle\_rule\_id](#input\_lifecycle\_rule\_id) | The ID for the lifecycle rule. | `string` | `null` | no |
| <a name="input_mfa_delete"></a> [mfa\_delete](#input\_mfa\_delete) | Flag to enable or disable MFA delete. | `bool` | `false` | no |
| <a name="input_replication_rule_id"></a> [replication\_rule\_id](#input\_replication\_rule\_id) | The ID for the replication rule. | `string` | `null` | no |
| <a name="input_replication_rule_status"></a> [replication\_rule\_status](#input\_replication\_rule\_status) | The status for the replication rule. | `string` | `null` | no |
| <a name="input_replication_storage_class"></a> [replication\_storage\_class](#input\_replication\_storage\_class) | The storage class for replication. | `string` | `null` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for the bucket. | `bool` | `true` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | Server side encryption algorithm to use on the S3 bucket. | `string` | `"AES256"` | no |
| <a name="input_target_bucket_arn"></a> [target\_bucket\_arn](#input\_target\_bucket\_arn) | The ARN for the target bucket for replication. | `string` | `null` | no |
| <a name="input_tiering_config_id"></a> [tiering\_config\_id](#input\_tiering\_config\_id) | The unique ID for the intelligent tiering configuration. | `string` | `null` | no |
| <a name="input_versioning_status"></a> [versioning\_status](#input\_versioning\_status) | Enabled or Suspended | `string` | `"Suspended"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_destination_bucket_arn"></a> [destination\_bucket\_arn](#output\_destination\_bucket\_arn) | The ARN of the destination S3 bucket (if created) |
| <a name="output_destination_bucket_id"></a> [destination\_bucket\_id](#output\_destination\_bucket\_id) | The ID of the destination S3 bucket (if created) |
| <a name="output_destination_bucket_versioning"></a> [destination\_bucket\_versioning](#output\_destination\_bucket\_versioning) | Versioning settings for the destination S3 bucket (if created) |
| <a name="output_destination_replication_policy_document"></a> [destination\_replication\_policy\_document](#output\_destination\_replication\_policy\_document) | IAM policy document for destination bucket replication permissions |
| <a name="output_iam_destination_replication_role_arn"></a> [iam\_destination\_replication\_role\_arn](#output\_iam\_destination\_replication\_role\_arn) | ARN of the IAM role for destination bucket replication |
| <a name="output_iam_source_replication_role_arn"></a> [iam\_source\_replication\_role\_arn](#output\_iam\_source\_replication\_role\_arn) | ARN of the IAM role for source bucket replication |
| <a name="output_s3_bucket_accelerate_configuration"></a> [s3\_bucket\_accelerate\_configuration](#output\_s3\_bucket\_accelerate\_configuration) | Acceleration settings for the S3 bucket |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the S3 bucket |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The ID of the S3 bucket |
| <a name="output_s3_bucket_intelligent_tiering_configuration"></a> [s3\_bucket\_intelligent\_tiering\_configuration](#output\_s3\_bucket\_intelligent\_tiering\_configuration) | Intelligent tiering configuration for the S3 bucket |
| <a name="output_s3_bucket_lifecycle_configuration"></a> [s3\_bucket\_lifecycle\_configuration](#output\_s3\_bucket\_lifecycle\_configuration) | Lifecycle configuration for the S3 bucket |
| <a name="output_s3_bucket_public_access_block"></a> [s3\_bucket\_public\_access\_block](#output\_s3\_bucket\_public\_access\_block) | Public access block settings for the S3 bucket |
| <a name="output_s3_bucket_replication_configuration"></a> [s3\_bucket\_replication\_configuration](#output\_s3\_bucket\_replication\_configuration) | Replication configuration for the S3 bucket |
| <a name="output_s3_bucket_server_side_encryption_configuration"></a> [s3\_bucket\_server\_side\_encryption\_configuration](#output\_s3\_bucket\_server\_side\_encryption\_configuration) | Server side encryption configuration for the S3 bucket |
| <a name="output_s3_bucket_versioning"></a> [s3\_bucket\_versioning](#output\_s3\_bucket\_versioning) | Versioning settings for the S3 bucket |
| <a name="output_source_replication_policy_document"></a> [source\_replication\_policy\_document](#output\_source\_replication\_policy\_document) | IAM policy document for source bucket replication permissions |
<!-- END_TF_DOCS -->