## Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | >= 0.12.0 |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | n/a     |

## Inputs

| Name              | Description                                                                                                                                                                                                                                                                             | Type     | Default                                                                                                | Required |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------ | :------: |
| acl               | (Optional) The canned ACL to apply. Defaults to private.                                                                                                                                                                                                                                | `string` | `"private"`                                                                                            |    no    |
| bucket            | (Required) The ARN of the S3 bucket where you want Amazon S3 to store replicas of the object identified by the rule.                                                                                                                                                                    | `any`    | n/a                                                                                                    |   yes    |
| kms_master_key_id | (optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms.                             | `string` | `""`                                                                                                   |    no    |
| mfa_delete        | (Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false.                                                                                                                                           | `bool`   | `false`                                                                                                |    no    |
| policy            | (Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. | `string` | `""`                                                                                                   |    no    |
| region            | (Optional) If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee.                                                                                                                                                                         | `any`    | n/a                                                                                                    |   yes    |
| sse_algorithm     | (required) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms                                                                                                                                                                                             | `string` | `"aws:kms"`                                                                                            |    no    |
| tags              | (Optional) A mapping of tags to assign to the bucket.                                                                                                                                                                                                                                   | `map`    | <pre>{<br> "created_by": "Zachary Hill",<br> "environment": "prod",<br> "terraform": "true"<br>}</pre> |    no    |
| target_bucket     | (Required) The name of the bucket that will receive the log objects.                                                                                                                                                                                                                    | `string` | `""`                                                                                                   |    no    |
| target_prefix     | (Optional) To specify a key prefix for log objects.                                                                                                                                                                                                                                     | `string` | `"log/"`                                                                                               |    no    |
| versioning        | (Optional) A state of versioning (documented below)                                                                                                                                                                                                                                     | `bool`   | `true`                                                                                                 |    no    |

## Outputs

| Name                  | Description |
| --------------------- | ----------- |
| s3_bucket_arn         | n/a         |
| s3_bucket_domain_name | n/a         |
| s3_bucket_id          | n/a         |
| s3_bucket_region      | n/a         |
| s3_hosted_zone_id     | n/a         |

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.0.0 |

## Providers

| Name                                             | Version  |
| ------------------------------------------------ | -------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name                                                                                                             | Type     |
| ---------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |

## Inputs

| Name                                                                                 | Description                                                                                                                                                                                                                                                                             | Type       | Default                                                                                                | Required |
| ------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ------------------------------------------------------------------------------------------------------ | :------: |
| <a name="input_acl"></a> [acl](#input_acl)                                           | (Optional) The canned ACL to apply. Defaults to private.                                                                                                                                                                                                                                | `string`   | `"private"`                                                                                            |    no    |
| <a name="input_bucket"></a> [bucket](#input_bucket)                                  | (Required) The ARN of the S3 bucket where you want Amazon S3 to store replicas of the object identified by the rule.                                                                                                                                                                    | `any`      | n/a                                                                                                    |   yes    |
| <a name="input_kms_master_key_id"></a> [kms_master_key_id](#input_kms_master_key_id) | (optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms.                             | `string`   | `""`                                                                                                   |    no    |
| <a name="input_mfa_delete"></a> [mfa_delete](#input_mfa_delete)                      | (Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false.                                                                                                                                           | `bool`     | `false`                                                                                                |    no    |
| <a name="input_policy"></a> [policy](#input_policy)                                  | (Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. | `string`   | `""`                                                                                                   |    no    |
| <a name="input_sse_algorithm"></a> [sse_algorithm](#input_sse_algorithm)             | (required) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms                                                                                                                                                                                             | `string`   | `"aws:kms"`                                                                                            |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                        | (Optional) A mapping of tags to assign to the bucket.                                                                                                                                                                                                                                   | `map(any)` | <pre>{<br> "created_by": "Zachary Hill",<br> "environment": "prod",<br> "terraform": "true"<br>}</pre> |    no    |
| <a name="input_target_bucket"></a> [target_bucket](#input_target_bucket)             | (Required) The name of the bucket that will receive the log objects.                                                                                                                                                                                                                    | `string`   | `""`                                                                                                   |    no    |
| <a name="input_target_prefix"></a> [target_prefix](#input_target_prefix)             | (Optional) To specify a key prefix for log objects.                                                                                                                                                                                                                                     | `string`   | `"log/"`                                                                                               |    no    |
| <a name="input_versioning"></a> [versioning](#input_versioning)                      | (Optional) A state of versioning (documented below)                                                                                                                                                                                                                                     | `bool`     | `true`                                                                                                 |    no    |

## Outputs

| Name                                                                                               | Description |
| -------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_s3_bucket_arn"></a> [s3_bucket_arn](#output_s3_bucket_arn)                         | n/a         |
| <a name="output_s3_bucket_domain_name"></a> [s3_bucket_domain_name](#output_s3_bucket_domain_name) | n/a         |
| <a name="output_s3_bucket_id"></a> [s3_bucket_id](#output_s3_bucket_id)                            | n/a         |
| <a name="output_s3_bucket_region"></a> [s3_bucket_region](#output_s3_bucket_region)                | n/a         |
| <a name="output_s3_hosted_zone_id"></a> [s3_hosted_zone_id](#output_s3_hosted_zone_id)             | n/a         |
| <a name="output_website_domain"></a> [website_domain](#output_website_domain)                      | n/a         |
| <a name="output_website_endpoint"></a> [website_endpoint](#output_website_endpoint)                | n/a         |

<!-- END_TF_DOCS -->
