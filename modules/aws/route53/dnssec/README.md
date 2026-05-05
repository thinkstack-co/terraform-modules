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

<h3 align="center">Route53 DNSSEC Module</h3>
  <p align="center">
    This module configures DNSSEC on a Route53 zone.
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

```
module "example_com_dnssec" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/route53/dnssec"

    hosted_zone_id = module.example_com_zone.zone_id
    name           = "example_com_signing_key"
    tags           = {
        terraform   = "true"
        created_by  = "YOUR NAME"
        environment = "prod"
        role        = "dns"
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

| Name                                                                                                                                          | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                                   | resource    |
| [aws_kms_key.dnssec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                     | resource    |
| [aws_route53_hosted_zone_dnssec.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_hosted_zone_dnssec) | resource    |
| [aws_route53_key_signing_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_key_signing_key)       | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                 | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                   | data source |

## Inputs

| Name                                                                                                      | Description                                                                                                                                                                                                                                                                                                                                                                                                                     | Type       | Default                                   | Required |
| --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ----------------------------------------- | :------: |
| <a name="input_customer_master_key_spec"></a> [customer_master_key_spec](#input_customer_master_key_spec) | (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, HMAC_256, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide.                 | `string`   | `"ECC_NIST_P256"`                         |    no    |
| <a name="input_deletion_window_in_days"></a> [deletion_window_in_days](#input_deletion_window_in_days)    | (Optional) The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive. If you do not specify a value, it defaults to 30. If the KMS key is a multi-Region primary key with replicas, the waiting period begins when the last of its replica keys is deleted. Otherwise, the waiting period begins immediately. | `number`   | `7`                                       |    no    |
| <a name="input_description"></a> [description](#input_description)                                        | (Optional) The description of the key as viewed in AWS console.                                                                                                                                                                                                                                                                                                                                                                 | `string`   | `"KMS key used in Route53 zone DNSSEC"`   |    no    |
| <a name="input_enable_key_rotation"></a> [enable_key_rotation](#input_enable_key_rotation)                | (Optional) Specifies whether key rotation is enabled. Defaults to false.                                                                                                                                                                                                                                                                                                                                                        | `bool`     | `false`                                   |    no    |
| <a name="input_hosted_zone_id"></a> [hosted_zone_id](#input_hosted_zone_id)                               | (Required) Identifier of the Route 53 Hosted Zone.                                                                                                                                                                                                                                                                                                                                                                              | `string`   | n/a                                       |   yes    |
| <a name="input_is_enabled"></a> [is_enabled](#input_is_enabled)                                           | (Optional) Specifies whether the key is enabled. Defaults to true.                                                                                                                                                                                                                                                                                                                                                              | `bool`     | `true`                                    |    no    |
| <a name="input_key_usage"></a> [key_usage](#input_key_usage)                                              | (Optional) Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC. Defaults to ENCRYPT_DECRYPT.                                                                                                                                                                                                                                                                              | `string`   | `"SIGN_VERIFY"`                           |    no    |
| <a name="input_name"></a> [name](#input_name)                                                             | (Required) Name of the key-signing key (KSK). Must be unique for each key-singing key in the same hosted zone.                                                                                                                                                                                                                                                                                                                  | `string`   | n/a                                       |   yes    |
| <a name="input_name_prefix"></a> [name_prefix](#input_name_prefix)                                        | (Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/).                                                                                                                                                                                                                                                                           | `string`   | `"alias/dnssec_"`                         |    no    |
| <a name="input_signing_status"></a> [signing_status](#input_signing_status)                               | (Optional) Hosted Zone signing status. Valid values: SIGNING, NOT_SIGNING. Defaults to SIGNING.                                                                                                                                                                                                                                                                                                                                 | `string`   | `"SIGNING"`                               |    no    |
| <a name="input_status"></a> [status](#input_status)                                                       | (Optional) Status of the key-signing key (KSK). Valid values: ACTIVE, INACTIVE. Defaults to ACTIVE.                                                                                                                                                                                                                                                                                                                             | `string`   | `"ACTIVE"`                                |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                             | (Optional) A map of tags to assign to the object. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level.                                                                                                                                                                                                                           | `map(any)` | <pre>{<br> "terraform": "true"<br>}</pre> |    no    |

## Outputs

| Name                                                                                                              | Description |
| ----------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_digest_algorithm_mnemonic"></a> [digest_algorithm_mnemonic](#output_digest_algorithm_mnemonic)    | n/a         |
| <a name="output_digest_algorithm_type"></a> [digest_algorithm_type](#output_digest_algorithm_type)                | n/a         |
| <a name="output_digest_value"></a> [digest_value](#output_digest_value)                                           | n/a         |
| <a name="output_dnskey_record"></a> [dnskey_record](#output_dnskey_record)                                        | n/a         |
| <a name="output_ds_record"></a> [ds_record](#output_ds_record)                                                    | n/a         |
| <a name="output_flag"></a> [flag](#output_flag)                                                                   | n/a         |
| <a name="output_key_tag"></a> [key_tag](#output_key_tag)                                                          | n/a         |
| <a name="output_public_key"></a> [public_key](#output_public_key)                                                 | n/a         |
| <a name="output_signing_algorithm_mnemonic"></a> [signing_algorithm_mnemonic](#output_signing_algorithm_mnemonic) | n/a         |
| <a name="output_signing_algorithm_type"></a> [signing_algorithm_type](#output_signing_algorithm_type)             | n/a         |

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
