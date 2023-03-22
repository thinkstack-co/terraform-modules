## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acl | (Optional) The canned ACL to apply. Defaults to private. | `string` | `"private"` | no |
| bucket\_prefix | (Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. | `any` | n/a | yes |
| kms\_master\_key\_id | (optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse\_algorithm is aws:kms. | `string` | `""` | no |
| mfa\_delete | (Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false. | `bool` | `false` | no |
| policy | (Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. | `string` | `""` | no |
| region | (Optional) If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee. | `any` | n/a | yes |
| sse\_algorithm | (required) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms | `string` | `"aws:kms"` | no |
| tags | (Optional) A mapping of tags to assign to the bucket. | `map` | <pre>{<br>  "created_by": "Zachary Hill",<br>  "environment": "prod",<br>  "terraform": "true"<br>}</pre> | no |
| target\_bucket | (Required) The name of the bucket that will receive the log objects. | `string` | `""` | no |
| target\_prefix | (Optional) To specify a key prefix for log objects. | `string` | `"log/"` | no |
| versioning | (Optional) A state of versioning (documented below) | `bool` | `true` | no |
| days | (required) Specifies the number of days after object creation when it will be moved to another storage class. Each class is defined independently in variables.tf | `number` | `defined in vars` | yes |
| enabled | (required) Specifies the number of days after object creation when it will be moved to another storage class. Each class is defined independently in variables.tf | `bool` | `true` | yes |
## Outputs

| Name | Description |
|------|-------------|
| s3\_bucket\_arn | n/a |
| s3\_bucket\_domain\_name | n/a |
| s3\_bucket\_id | n/a |
| s3\_bucket\_region | n/a |
| s3\_hosted\_zone\_id | n/a |
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
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acl"></a> [acl](#input\_acl) | (Optional) The canned ACL to apply. Defaults to private. | `string` | `"private"` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | (Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. | `any` | n/a | yes |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | (optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse\_algorithm is aws:kms. | `string` | `""` | no |
| <a name="input_lifecycle_days_to_deep_archive_transition"></a> [lifecycle\_days\_to\_deep\_archive\_transition](#input\_lifecycle\_days\_to\_deep\_archive\_transition) | Specifies the number of days after object creation when it will be moved to Glacier storage. | `number` | `120` | no |
| <a name="input_lifecycle_days_to_glacier_transition"></a> [lifecycle\_days\_to\_glacier\_transition](#input\_lifecycle\_days\_to\_glacier\_transition) | Specifies the number of days after object creation when it will be moved to Glacier storage. | `number` | `90` | no |
| <a name="input_lifecycle_days_to_infrequent_storage_transition"></a> [lifecycle\_days\_to\_infrequent\_storage\_transition](#input\_lifecycle\_days\_to\_infrequent\_storage\_transition) | Specifies the number of days after object creation when it will be moved to standard infrequent access storage. | `number` | `30` | no |
| <a name="input_lifecycle_deep_archive_object_prefix"></a> [lifecycle\_deep\_archive\_object\_prefix](#input\_lifecycle\_deep\_archive\_object\_prefix) | Object key prefix identifying one or more objects to which the lifecycle rule applies. | `string` | `""` | no |
| <a name="input_lifecycle_deep_archive_transition_enabled"></a> [lifecycle\_deep\_archive\_transition\_enabled](#input\_lifecycle\_deep\_archive\_transition\_enabled) | Specifies Deep Archive transition lifecycle rule status. | `bool` | `true` | no |
| <a name="input_lifecycle_glacier_object_prefix"></a> [lifecycle\_glacier\_object\_prefix](#input\_lifecycle\_glacier\_object\_prefix) | Object key prefix identifying one or more objects to which the lifecycle rule applies. | `string` | `""` | no |
| <a name="input_lifecycle_glacier_transition_enabled"></a> [lifecycle\_glacier\_transition\_enabled](#input\_lifecycle\_glacier\_transition\_enabled) | Specifies Glacier transition lifecycle rule status. | `bool` | `true` | no |
| <a name="input_lifecycle_infrequent_storage_object_prefix"></a> [lifecycle\_infrequent\_storage\_object\_prefix](#input\_lifecycle\_infrequent\_storage\_object\_prefix) | Object key prefix identifying one or more objects to which the lifecycle rule applies. | `string` | `""` | no |
| <a name="input_lifecycle_infrequent_storage_transition_enabled"></a> [lifecycle\_infrequent\_storage\_transition\_enabled](#input\_lifecycle\_infrequent\_storage\_transition\_enabled) | Specifies infrequent storage transition lifecycle rule status. | `bool` | `true` | no |
| <a name="input_mfa_delete"></a> [mfa\_delete](#input\_mfa\_delete) | (Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false. | `bool` | `false` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. | `string` | `""` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | (required) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms | `string` | `"aws:kms"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the bucket. | `map(any)` | <pre>{<br>  "created_by": "Zachary Hill",<br>  "environment": "prod",<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_target_bucket"></a> [target\_bucket](#input\_target\_bucket) | (Required) The name of the bucket that will receive the log objects. | `string` | `""` | no |
| <a name="input_target_prefix"></a> [target\_prefix](#input\_target\_prefix) | (Optional) To specify a key prefix for log objects. | `string` | `"log/"` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | (Optional) A state of versioning (documented below) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | n/a |
| <a name="output_s3_bucket_domain_name"></a> [s3\_bucket\_domain\_name](#output\_s3\_bucket\_domain\_name) | n/a |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | n/a |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | n/a |
| <a name="output_s3_hosted_zone_id"></a> [s3\_hosted\_zone\_id](#output\_s3\_hosted\_zone\_id) | n/a |
<!-- END_TF_DOCS -->