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
| <a name="input_bucket"></a> [bucket](#input\_bucket) | (Required) The ARN of the S3 bucket where you want Amazon S3 to store replicas of the object identified by the rule. | `any` | n/a | yes |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | (optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse\_algorithm is aws:kms. | `string` | `""` | no |
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