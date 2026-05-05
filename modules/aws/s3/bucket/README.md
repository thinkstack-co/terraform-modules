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

This example creates a bucket with multiple lifecycle rules configured to transition objects to Standard-IA after 30 days, Glacier after 60 days, and expire objects after 90 days.

```
module "logging_bucket" {
  source          = "github.com/thinkstack-co/terraform-modules//modules/aws/s3/bucket"
  bucket_prefix   = "octo-prod-bucket-"
  lifecycle_rules = [
    {
      id         = "Transition all objects to STANDARD_IA/Glacier after 30/60 days"
      status     = "Enabled"
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        },
      ]
    },
    {
      id         = "Delete all objects after 90 days"
      status     = "Enabled"
      expiration = {
        days = 90
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

### Alternative Lifecycle Rules Example

This example uses multiple rules, each with a single transition or expire configuration for more granular control.

```
module "logging_bucket" {
  source          = "github.com/thinkstack-co/terraform-modules//modules/aws/s3/bucket"
  bucket_prefix   = "octo-prod-bucket-"
  lifecycle_rules = [
    {
      id     = "Transition log prefix objects to Standard-IA after 30 days"
      status = "Enabled"
      filter = {
        prefix = "log/"
      }
      transition = {
        days          = 30
        storage_class = "STANDARD_IA"
      }
    },
    {
      id         = "Transition all objects to ONEZONE_IA after 60 days"
      status     = "Enabled"
      transition = {
        days          = 60
        storage_class = "ONEZONE_IA"
      }
    },
    {
      id         = "Transition all objects to Glacier after 120 days"
      status     = "Enabled"
      transition = {
        days          = 120
        storage_class = "GLACIER"
      }
    },
  ]
  tags = {
    created_by  = "<YOUR_NAME>"
    environment = "prod"
    terraform   = "true"
  }
}
```

### Lifecycle Rules With All Available Options

This example shows all of the available options. All transition configurations are lists and can have multiple transitions configured.

```
module "logging_bucket" {
  source          = "github.com/thinkstack-co/terraform-modules//modules/aws/s3/bucket"
  bucket_prefix   = "octo-prod-bucket-"
  lifecycle_rules = [
    {
      id     = "Transition all objects to STANDARD_IA then Glacier after 30/60 days"
      status = "Enabled"
      filter = {
        prefix = "log/"
      }

      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
      noncurrent_version_expiration = {
        newer_noncurrent_versions = 1
        noncurrent_days           = 90
      }
      noncurrent_version_transition = [
        {
          newer_noncurrent_versions = 1
          noncurrent_days           = 30
          storage_class             = "STANDARD_IA"
        },
        {
          newer_noncurrent_versions = 1
          noncurrent_days           = 60
          storage_class             = "GLACIER"
        },
      ]
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        },
      ]
    },
    {
      id         = "Delete all objects after 90 days"
      status     = "Enabled"
      expiration = {
        days = 90
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

### Intelligent Tiering Example

This example makes use of a simple S3 bucket with intelligent tiering enabled. The intelligent tiering configuration will eventually end up with objects in the ARCHIVE_ACCESS glacier tier after 365 days. All objects in the bucket will utilize this intelligent tiering configuration.

```
module "app_bucket" {
  source                          = "github.com/thinkstack-co/terraform-modules//modules/aws/s3/bucket"
  bucket_prefix                   = "octo-prod-app-"
  enable_intelligent_tiering      = true
  intelligent_tiering_access_tier = "ARCHIVE_ACCESS"
  intelligent_tiering_days        = 365
  tags = {
    created_by  = "<YOUR_NAME>"
    environment = "prod"
    terraform   = "true"
  }
}
```

### Intelligent Tiering Filter Example

This example makes use of a simple S3 bucket with intelligent tiering enabled. The intelligent tiering configuration will eventually end up with objects in the DEEP_ARCHIVE_ACCESS glacier tier after 120 days. Objects with the prefix 'test/' and tagged with 'project' = 'app' will utilize this intelligent tiering configuration.

```
module "app_bucket" {
  source                          = "github.com/thinkstack-co/terraform-modules//modules/aws/s3/bucket"
  bucket_prefix                   = "octo-prod-app-"
  enable_intelligent_tiering      = true
  intelligent_tiering_access_tier = "DEEP_ARCHIVE_ACCESS"
  intelligent_tiering_days        = 180
  intelligent_tiering_filter      = {
    prefix = "test/"
    tags   = {
      "project" = "app"
    }
  }
  tags = {
    created_by  = "<YOUR_NAME>"
    environment = "prod"
    terraform   = "true"
  }
}
```

### Using ACLs

This example makes use of the canned ACLs for the S3 bucket logging service. ACLs should typically not be used, instead bucket policies allow for better control. The S3 log delivery ACL is one such time where you can use ACLs. Another time is when the owner of the bucket and the objects differ.

```
module "logging_bucket" {
  source        = "github.com/thinkstack-co/terraform-modules//modules/aws/s3/bucket"
  acl           = ""log-delivery-write""
  bucket_prefix = "octo-prod-s3-logging-bucket-"
  tags          = {
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

| Name                                                                                                                                                                                  | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_kms_alias.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                                                                             | resource |
| [aws_kms_key.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                                                                 | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                           | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                                                   | resource |
| [aws_s3_bucket_intelligent_tiering_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_intelligent_tiering_configuration)       | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                           | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging)                                                           | resource |
| [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls)                  | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                             | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                   | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                     | resource |

## Inputs

| Name                                                                                                                           | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | Type       | Default                                                                                               | Required |
| ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- | ----------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_acl"></a> [acl](#input_acl)                                                                                     | (Optional) The canned ACL to apply. Defaults to private. Valid values are private, public-read, public-read-write, aws-exec-read, authenticated-read, log-delivery-write, bucket-owner-read, bucket-owner-full-control, and authenticated-read.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `string`   | `null`                                                                                                |    no    |
| <a name="input_block_public_acls"></a> [block_public_acls](#input_block_public_acls)                                           | (Optional) Whether Amazon S3 should block public ACLs for this bucket. Defaults to false. Enabling this setting does not affect existing policies or ACLs.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | `bool`     | `true`                                                                                                |    no    |
| <a name="input_block_public_policy"></a> [block_public_policy](#input_block_public_policy)                                     | (Optional) Whether Amazon S3 should block public bucket policies for this bucket. Defaults to false. Enabling this setting does not affect the existing bucket policy.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | `bool`     | `true`                                                                                                |    no    |
| <a name="input_bucket"></a> [bucket](#input_bucket)                                                                            | (Optional, bucket or bucket_prefix must exist) Name of the bucket. If omitted, Terraform will assign a random, unique name. Must be lowercase and less than or equal to 63 characters in length. Conflicts with bucket_prefix.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | `string`   | `null`                                                                                                |    no    |
| <a name="input_bucket_force_destroy"></a> [bucket_force_destroy](#input_bucket_force_destroy)                                  | (Optional, Default:false) Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error. These objects are not recoverable. This only deletes objects when the bucket is destroyed, not when setting this parameter to true. Once this parameter is set to true, there must be a successful terraform apply run before a destroy is required to update this value in the resource state. Without a successful terraform apply after this parameter is set, this flag will have no effect. If setting this field in the same operation that would require replacing the bucket or destroying the bucket, this flag will not work. Additionally when importing a bucket, a successful terraform apply is required to set this value in state before it will take effect on a destroy operation. | `bool`     | `false`                                                                                               |    no    |
| <a name="input_bucket_key_enabled"></a> [bucket_key_enabled](#input_bucket_key_enabled)                                        | (Optional) Specifies whether Amazon S3 should use an S3 bucket key for object encryption with server-side encryption using AWS KMS (SSE-KMS). Setting this element to true causes the following behavior: When an object is uploaded, the S3 bucket key is used to encrypt the object. When an object is overwritten, the S3 bucket key is re-used to encrypt the object. When an object is copied, the S3 bucket key is re-used to encrypt the object. When an object is restored from Amazon Glacier, the S3 bucket key is re-used to encrypt the object. Defaults to true.                                                                                                                                                                                                                                                                                                                                      | `bool`     | `true`                                                                                                |    no    |
| <a name="input_bucket_object_lock_enabled"></a> [bucket_object_lock_enabled](#input_bucket_object_lock_enabled)                | (Optional, Forces new resource) Indicates whether this bucket has an Object Lock configuration enabled. Valid values are true or false. This argument is not supported in all regions or partitions.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `bool`     | `false`                                                                                               |    no    |
| <a name="input_bucket_policy"></a> [bucket_policy](#input_bucket_policy)                                                       | (Optional) Text of the policy. Although this is a bucket policy rather than an IAM policy, the aws_iam_policy_document data source may be used, so long as it specifies a principal. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. Note: Bucket policies are limited to 20 KB in size.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | `string`   | `null`                                                                                                |    no    |
| <a name="input_bucket_prefix"></a> [bucket_prefix](#input_bucket_prefix)                                                       | (Optional, bucket_name or bucket_prefix must exist) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. Must be lowercase and less than or equal to 37 characters in length.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `string`   | `null`                                                                                                |    no    |
| <a name="input_enable_intelligent_tiering"></a> [enable_intelligent_tiering](#input_enable_intelligent_tiering)                | (Optional) Enable intelligent tiering for S3 bucket. If true, this will create an intelligent tiering configuration for the bucket. Defaults to false.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | `bool`     | `false`                                                                                               |    no    |
| <a name="input_enable_kms_key"></a> [enable_kms_key](#input_enable_kms_key)                                                    | (Optional) Enable KMS key for S3 bucket. If true, this will create a kms key and alias for use with the bucket encryption. Defaults to false.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `bool`     | `false`                                                                                               |    no    |
| <a name="input_enable_public_access_block"></a> [enable_public_access_block](#input_enable_public_access_block)                | (Optional) Enable public access block for S3 bucket. If true, this will create a public access block for the bucket. Defaults to true.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | `bool`     | `true`                                                                                                |    no    |
| <a name="input_enable_s3_bucket_logging"></a> [enable_s3_bucket_logging](#input_enable_s3_bucket_logging)                      | (Optional) Enable logging on the cloudtrail S3 bucket. If true, the 'target_bucket' is required. Defaults to false.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | `bool`     | `false`                                                                                               |    no    |
| <a name="input_expected_bucket_owner"></a> [expected_bucket_owner](#input_expected_bucket_owner)                               | (Optional) Account ID of the expected bucket owner. If the bucket is owned by a different account, the request will fail with an HTTP 403 (Access Denied) error.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | `string`   | `null`                                                                                                |    no    |
| <a name="input_ignore_public_acls"></a> [ignore_public_acls](#input_ignore_public_acls)                                        | (Optional) Whether Amazon S3 should ignore public ACLs for this bucket. Defaults to false. Enabling this setting does not affect the persistence of any existing ACLs and doesn't prevent new public ACLs from being set.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | `bool`     | `true`                                                                                                |    no    |
| <a name="input_intelligent_tiering_access_tier"></a> [intelligent_tiering_access_tier](#input_intelligent_tiering_access_tier) | (Optional) Specifies the access tier to use for objects that meet the filter criteria. Valid values: ARCHIVE_ACCESS, DEEP_ARCHIVE_ACCESS. Default is ARCHIVE_ACCESS.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `string`   | `"ARCHIVE_ACCESS"`                                                                                    |    no    |
| <a name="input_intelligent_tiering_days"></a> [intelligent_tiering_days](#input_intelligent_tiering_days)                      | (Optional) Number of consecutive days of no access after which an object will be eligible to be transitioned to the corresponding tier. For ARCHIVE_ACCESS the date range must be between 90 to 730 days. For DEEP_ARCHIVE_ACCESS the date range must be between 180 to 730 days. Default is 90 days.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | `number`   | `90`                                                                                                  |    no    |
| <a name="input_intelligent_tiering_filter"></a> [intelligent_tiering_filter](#input_intelligent_tiering_filter)                | (Optional) Specifies the S3 Intelligent-Tiering filter that identifies the subset of objects to which the configuration applies. Can have several filters as a list of maps where each map is the filter configuration. Type should be list(map(string)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | `any`      | `null`                                                                                                |    no    |
| <a name="input_intelligent_tiering_name"></a> [intelligent_tiering_name](#input_intelligent_tiering_name)                      | (Optional) Unique name used to identify the S3 Intelligent-Tiering configuration for the bucket. The name can be up to 64 characters and contain only letters, numbers, underscores, periods, or dashes.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `string`   | `"bucket_tiering"`                                                                                    |    no    |
| <a name="input_intelligent_tiering_status"></a> [intelligent_tiering_status](#input_intelligent_tiering_status)                | (Optional) Specifies the status of the configuration. Valid values: Enabled, Disabled. Defaults to Enabled.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `string`   | `"Enabled"`                                                                                           |    no    |
| <a name="input_key_customer_master_key_spec"></a> [key_customer_master_key_spec](#input_key_customer_master_key_spec)          | (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | `string`   | `"SYMMETRIC_DEFAULT"`                                                                                 |    no    |
| <a name="input_key_deletion_window_in_days"></a> [key_deletion_window_in_days](#input_key_deletion_window_in_days)             | (Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `number`   | `30`                                                                                                  |    no    |
| <a name="input_key_description"></a> [key_description](#input_key_description)                                                 | (Optional) The description of the key as viewed in AWS console.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `string`   | `"S3 kms key used to encrypt bucket objects logs"`                                                    |    no    |
| <a name="input_key_enable_key_rotation"></a> [key_enable_key_rotation](#input_key_enable_key_rotation)                         | (Optional) Specifies whether key rotation is enabled. Defaults to false.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `bool`     | `true`                                                                                                |    no    |
| <a name="input_key_is_enabled"></a> [key_is_enabled](#input_key_is_enabled)                                                    | (Optional) Specifies whether the key is enabled. Defaults to true.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `string`   | `true`                                                                                                |    no    |
| <a name="input_key_name_prefix"></a> [key_name_prefix](#input_key_name_prefix)                                                 | (Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | `string`   | `"alias/s3_key_"`                                                                                     |    no    |
| <a name="input_key_policy"></a> [key_policy](#input_key_policy)                                                                | (Optional) A valid policy JSON document. Although this is a key policy, not an IAM policy, an aws_iam_policy_document, in the form that designates a principal, can be used. For more information about building policy documents with Terraform, see the AWS IAM Policy Document Guide.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `string`   | `""`                                                                                                  |    no    |
| <a name="input_key_usage"></a> [key_usage](#input_key_usage)                                                                   | (Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | `string`   | `"ENCRYPT_DECRYPT"`                                                                                   |    no    |
| <a name="input_lifecycle_rules"></a> [lifecycle_rules](#input_lifecycle_rules)                                                 | (Optional) Configuration of object lifecycle management (LCM). Can have several rules as a list of maps where each map is the lifecycle rule configuration. Type should be list(map(string)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `any`      | `null`                                                                                                |    no    |
| <a name="input_logging_target_bucket"></a> [logging_target_bucket](#input_logging_target_bucket)                               | (Optional) The name of the bucket that will receive the logs. Required if logging of the S3 bucket is set to true.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `string`   | `null`                                                                                                |    no    |
| <a name="input_logging_target_prefix"></a> [logging_target_prefix](#input_logging_target_prefix)                               | (Optional) The prefix that is prepended to all log object keys. If not set, the logs are stored in the root of the bucket.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | `string`   | `"log/"`                                                                                              |    no    |
| <a name="input_mfa_delete"></a> [mfa_delete](#input_mfa_delete)                                                                | (Optional) Specifies whether MFA delete is enabled in the bucket versioning configuration. Valid values: Enabled or Disabled.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `string`   | `"Disabled"`                                                                                          |    no    |
| <a name="input_restrict_public_buckets"></a> [restrict_public_buckets](#input_restrict_public_buckets)                         | (Optional) Whether Amazon S3 should restrict public bucket policies for this bucket. Defaults to false. Enabling this setting does not affect the previously stored bucket policy, except that public and cross-account access within the public bucket policy, including non-public delegation to specific accounts, is blocked.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `bool`     | `true`                                                                                                |    no    |
| <a name="input_sse_algorithm"></a> [sse_algorithm](#input_sse_algorithm)                                                       | (Optional) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `string`   | `"aws:kms"`                                                                                           |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                  | (Optional) A mapping of tags to assign to the bucket.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | `map(any)` | <pre>{<br> "created_by": "<YOUR NAME>",<br> "environment": "prod",<br> "terraform": "true"<br>}</pre> |    no    |
| <a name="input_versioning_status"></a> [versioning_status](#input_versioning_status)                                           | (Optional) Versioning state of the bucket. Valid values: Enabled, Suspended, or Disabled. Disabled should only be used when creating or importing resources that correspond to unversioned S3 buckets.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | `string`   | `"Disabled"`                                                                                          |    no    |

## Outputs

| Name                                                                                   | Description |
| -------------------------------------------------------------------------------------- | ----------- |
| <a name="output_s3_bucket_arn"></a> [s3_bucket_arn](#output_s3_bucket_arn)             | n/a         |
| <a name="output_s3_bucket_id"></a> [s3_bucket_id](#output_s3_bucket_id)                | n/a         |
| <a name="output_s3_bucket_region"></a> [s3_bucket_region](#output_s3_bucket_region)    | n/a         |
| <a name="output_s3_hosted_zone_id"></a> [s3_hosted_zone_id](#output_s3_hosted_zone_id) | n/a         |

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

- [Zachary Hill](https://zacharyhill.co)
- [Jake Jones](https://github.com/jakeasarus)

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
