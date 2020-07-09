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
| error\_document | (Optional) An absolute path to the document to return in case of a 4XX error. | `string` | `"error.html"` | no |
| index\_document | (Required, unless using redirect\_all\_requests\_to) Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders. | `string` | `"index.html"` | no |
| mfa\_delete | (Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false. | `bool` | `false` | no |
| policy | (Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. | `string` | `""` | no |
| region | (Optional) If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee. | `any` | n/a | yes |
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

