<!-- Blank module readme template: Do a search and replace with your text editor for the following: `module_name`, `module_description` -->
<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>


<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/thinkstack-co/terraform-modules">
    <img src="/images/terraform_modules_logo.webp" alt="Logo" width="300" height="300">
  </a>

<h3 align="center">S3 Module</h3>
  <p align="center">
    This module creates S3 resources.
    <br />
    <a href="https://github.com/thinkstack-co/terraform-modules"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://www.thinkstack.co/">Think|Stack</a>
    ·
    <a href="https://github.com/thinkstack-co/terraform-modules/issues">Report Bug</a>
    ·
    <a href="https://github.com/thinkstack-co/terraform-modules/issues">Request Feature</a>
  </p>
</div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#providers">Providers</a></li>
    <li><a href="#modules">Modules</a></li>
    <li><a href="#Resources">Resources</a></li>
    <li><a href="#inputs">Inputs</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>


<!-- USAGE EXAMPLES -->
## Usage
### Simple Example
This example creates a bucket with encryption enabled by default, using the 'aws/s3' KMS key managed by AWS. It also has the default of blocking all public access to the bucket and objects. There is no bucket policy attached to this bucket.
```
module "bucket" {
  source        = "github.com/thinkstack-co/terraform-modules//modules/aws/s3/bucket"
  bucket_prefix = "octo-prod-"
  tags          = {
    created_by  = "<YOUR_NAME>"
    environment = "prod"
    terraform   = "true"
  }
}
```

### Lifecycle Rules Example
This example creates a bucket with multiple lifecycle rules configured to transition objects to Standard-IA after 7 days, Glacier after 30 days, and expire objects after 90 days.
```
module "logging_bucket" {
  source          = "github.com/thinkstack-co/terraform-modules//modules/aws/s3/bucket?ref=dev_s3_lifecycle"
  bucket_prefix   = "octo-prod-bucket-"
  lifecycle_rules = [
    {
      id         = "Transition all objects to Standard-IA after 7 days"
      status     = "Enabled"
      transition = {
        days          = 7
        storage_class = "STANDARD_IA"
      }
    },
    {
      id         = "Transition all objects to Glacier after 30 days"
      status     = "Enabled"
      transition = {
        days          = 30
        storage_class = "GLACIER"
      }
    },
    {
      id         = "Remove all objects after 90 days"
      status     = "Enabled"
      
      expiration = {
        days                         = 90
        expired_object_delete_marker = true
      }
      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
      filter      = {
        prefix = "*"
      }
    }
  ]
  tags = {
    created_by  = "<YOUR_NAME>"
    environment = "prod"
    terraform   = "true"
  }
}
```

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
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
| [aws_kms_alias.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | (Optional) Whether Amazon S3 should block public ACLs for this bucket. Defaults to false. Enabling this setting does not affect existing policies or ACLs. | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | (Optional) Whether Amazon S3 should block public bucket policies for this bucket. Defaults to false. Enabling this setting does not affect the existing bucket policy. | `bool` | `true` | no |
| <a name="input_bucket_force_destroy"></a> [bucket\_force\_destroy](#input\_bucket\_force\_destroy) | (Optional, Default:false) Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error. These objects are not recoverable. This only deletes objects when the bucket is destroyed, not when setting this parameter to true. Once this parameter is set to true, there must be a successful terraform apply run before a destroy is required to update this value in the resource state. Without a successful terraform apply after this parameter is set, this flag will have no effect. If setting this field in the same operation that would require replacing the bucket or destroying the bucket, this flag will not work. Additionally when importing a bucket, a successful terraform apply is required to set this value in state before it will take effect on a destroy operation. | `bool` | `false` | no |
| <a name="input_bucket_key_enabled"></a> [bucket\_key\_enabled](#input\_bucket\_key\_enabled) | (Optional) Specifies whether Amazon S3 should use an S3 bucket key for object encryption with server-side encryption using AWS KMS (SSE-KMS). Setting this element to true causes the following behavior: When an object is uploaded, the S3 bucket key is used to encrypt the object. When an object is overwritten, the S3 bucket key is re-used to encrypt the object. When an object is copied, the S3 bucket key is re-used to encrypt the object. When an object is restored from Amazon Glacier, the S3 bucket key is re-used to encrypt the object. Defaults to true. | `bool` | `true` | no |
| <a name="input_bucket_object_lock_enabled"></a> [bucket\_object\_lock\_enabled](#input\_bucket\_object\_lock\_enabled) | (Optional, Forces new resource) Indicates whether this bucket has an Object Lock configuration enabled. Valid values are true or false. This argument is not supported in all regions or partitions. | `bool` | `false` | no |
| <a name="input_bucket_policy"></a> [bucket\_policy](#input\_bucket\_policy) | (Optional) Text of the policy. Although this is a bucket policy rather than an IAM policy, the aws\_iam\_policy\_document data source may be used, so long as it specifies a principal. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. Note: Bucket policies are limited to 20 KB in size. | `string` | `null` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | (Required, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. | `string` | n/a | yes |
| <a name="input_enable_kms_key"></a> [enable\_kms\_key](#input\_enable\_kms\_key) | (Optional) Enable KMS key for S3 bucket. If true, this will create a kms key and alias for use with the bucket encryption. Defaults to false. | `bool` | `false` | no |
| <a name="input_enable_s3_bucket_logging"></a> [enable\_s3\_bucket\_logging](#input\_enable\_s3\_bucket\_logging) | (Optional) Enable logging on the cloudtrail S3 bucket. If true, the 'target\_bucket' is required. Defaults to false. | `bool` | `false` | no |
| <a name="input_expected_bucket_owner"></a> [expected\_bucket\_owner](#input\_expected\_bucket\_owner) | (Optional) Account ID of the expected bucket owner. If the bucket is owned by a different account, the request will fail with an HTTP 403 (Access Denied) error. | `string` | `null` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | (Optional) Whether Amazon S3 should ignore public ACLs for this bucket. Defaults to false. Enabling this setting does not affect the persistence of any existing ACLs and doesn't prevent new public ACLs from being set. | `bool` | `true` | no |
| <a name="input_key_customer_master_key_spec"></a> [key\_customer\_master\_key\_spec](#input\_key\_customer\_master\_key\_spec) | (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC\_DEFAULT, RSA\_2048, RSA\_3072, RSA\_4096, ECC\_NIST\_P256, ECC\_NIST\_P384, ECC\_NIST\_P521, or ECC\_SECG\_P256K1. Defaults to SYMMETRIC\_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide. | `string` | `"SYMMETRIC_DEFAULT"` | no |
| <a name="input_key_deletion_window_in_days"></a> [key\_deletion\_window\_in\_days](#input\_key\_deletion\_window\_in\_days) | (Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days. | `number` | `30` | no |
| <a name="input_key_description"></a> [key\_description](#input\_key\_description) | (Optional) The description of the key as viewed in AWS console. | `string` | `"S3 kms key used to encrypt bucket objects logs"` | no |
| <a name="input_key_enable_key_rotation"></a> [key\_enable\_key\_rotation](#input\_key\_enable\_key\_rotation) | (Optional) Specifies whether key rotation is enabled. Defaults to false. | `bool` | `true` | no |
| <a name="input_key_is_enabled"></a> [key\_is\_enabled](#input\_key\_is\_enabled) | (Optional) Specifies whether the key is enabled. Defaults to true. | `string` | `true` | no |
| <a name="input_key_name_prefix"></a> [key\_name\_prefix](#input\_key\_name\_prefix) | (Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/). | `string` | `"alias/s3_key_"` | no |
| <a name="input_key_policy"></a> [key\_policy](#input\_key\_policy) | (Optional) A valid policy JSON document. Although this is a key policy, not an IAM policy, an aws\_iam\_policy\_document, in the form that designates a principal, can be used. For more information about building policy documents with Terraform, see the AWS IAM Policy Document Guide. | `string` | `""` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | (Optional) Specifies the intended use of the key. Defaults to ENCRYPT\_DECRYPT, and only symmetric encryption and decryption are supported. | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | (Optional) Configuration of object lifecycle management (LCM). Can have several rules as a list of maps where each map is the lifecycle rule configuration. | `list(map(any))` | `null` | no |
| <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket) | (Optional) The name of the bucket that will receive the logs. Required if logging of the S3 bucket is set to true. | `string` | `null` | no |
| <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix) | (Optional) The prefix that is prepended to all log object keys. If not set, the logs are stored in the root of the bucket. | `string` | `"log/"` | no |
| <a name="input_mfa_delete"></a> [mfa\_delete](#input\_mfa\_delete) | (Optional) Specifies whether MFA delete is enabled in the bucket versioning configuration. Valid values: Enabled or Disabled. | `string` | `"Disabled"` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | (Optional) Whether Amazon S3 should restrict public bucket policies for this bucket. Defaults to false. Enabling this setting does not affect the previously stored bucket policy, except that public and cross-account access within the public bucket policy, including non-public delegation to specific accounts, is blocked. | `bool` | `true` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | (Optional) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms | `string` | `"aws:kms"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the bucket. | `map(any)` | <pre>{<br>  "created_by": "<YOUR NAME>",<br>  "environment": "prod",<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_versioning_status"></a> [versioning\_status](#input\_versioning\_status) | (Optional) Versioning state of the bucket. Valid values: Enabled, Suspended, or Disabled. Disabled should only be used when creating or importing resources that correspond to unversioned S3 buckets. | `string` | `"Disabled"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | n/a |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | n/a |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | n/a |
| <a name="output_s3_hosted_zone_id"></a> [s3\_hosted\_zone\_id](#output\_s3\_hosted\_zone\_id) | n/a |
<!-- END_TF_DOCS -->

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Think|Stack - [![LinkedIn][linkedin-shield]][linkedin-url] - info@thinkstack.co

Project Link: [https://github.com/thinkstack-co/terraform-modules](https://github.com/thinkstack-co/terraform-modules)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Zachary Hill](https://zacharyhill.co)
* [Jake Jones](https://github.com/jakeasarus)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/thinkstack-co/terraform-modules.svg?style=for-the-badge
[contributors-url]: https://github.com/thinkstack-co/terraform-modules/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/thinkstack-co/terraform-modules.svg?style=for-the-badge
[forks-url]: https://github.com/thinkstack-co/terraform-modules/network/members
[stars-shield]: https://img.shields.io/github/stars/thinkstack-co/terraform-modules.svg?style=for-the-badge
[stars-url]: https://github.com/thinkstack-co/terraform-modules/stargazers
[issues-shield]: https://img.shields.io/github/issues/thinkstack-co/terraform-modules.svg?style=for-the-badge
[issues-url]: https://github.com/thinkstack-co/terraform-modules/issues
[license-shield]: https://img.shields.io/github/license/thinkstack-co/terraform-modules.svg?style=for-the-badge
[license-url]: https://github.com/thinkstack-co/terraform-modules/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/company/thinkstack/
[product-screenshot]: /images/screenshot.webp
[Terraform.io]: https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform
[Terraform-url]: https://terraform.io