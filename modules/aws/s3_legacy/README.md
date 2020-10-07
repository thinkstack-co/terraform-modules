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
| bucket | (Required) The ARN of the S3 bucket where you want Amazon S3 to store replicas of the object identified by the rule. | `any` | n/a | yes |
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