# AWS Certificate Manager (ACM) Terraform Module

<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
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
    <img src="https://raw.githubusercontent.com/thinkstack-co/terraform-modules/main/images/thinkstack_logo.png" alt="ThinkStack Logo" width="300" height="100">
  </a>

<h3 align="center">AWS Certificate Manager Module</h3>
  <p align="center">
    This module provisions and manages SSL/TLS certificates in AWS Certificate Manager (ACM).
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
    <li><a href="#overview">Overview</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#providers">Providers</a></li>
    <li><a href="#resources">Resources</a></li>
    <li><a href="#inputs">Inputs</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## Overview

This Terraform module creates and manages AWS Certificate Manager (ACM) certificates. ACM certificates are used to secure applications with SSL/TLS, enabling encrypted connections for services like Application Load Balancers, CloudFront distributions, and API Gateway APIs.

The module supports:
- Domain validation via DNS or email
- Subject Alternative Names (SANs) for multi-domain certificates
- Custom key algorithms
- Resource tagging

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic Example

```hcl
module "acm_certificate" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/acm_certificate"

  domain_name       = "example.com"
  validation_method = "DNS"
  tags              = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}
```

### With Subject Alternative Names

```hcl
module "acm_certificate" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/acm_certificate"

  domain_name               = "example.com"
  validation_method         = "DNS"
  subject_alternative_names = ["www.example.com", "api.example.com", "*.example.com"]
  key_algorithm             = "RSA_2048"
  tags                      = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}
```

### Argument Reference

* `domain_name` - (Required) The primary domain name for the certificate.
* `validation_method` - (Optional) The method to validate certificate ownership. Valid values are `DNS`, `EMAIL`, or `NONE`. Default is `DNS`.
* `subject_alternative_names` - (Optional) A list of additional domain names to include in the certificate.
* `key_algorithm` - (Optional) The algorithm of the public and private key pair. Default is `EC_secp384r1`.
* `tags` - (Optional) A map of tags to assign to the certificate.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- REQUIREMENTS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0.0 |

## Resources

| Name | Type | Documentation |
|------|------|--------------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource | [AWS Documentation](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain_name | The domain name for which the certificate should be issued | `string` | n/a | yes |
| validation_method | The method to use for validation (DNS, EMAIL, or NONE) | `string` | `"DNS"` | no |
| subject_alternative_names | A list of domains that should be included as Subject Alternative Names (SANs) in the certificate | `list(string)` | `null` | no |
| key_algorithm | The algorithm of the public and private key pair (e.g., EC_secp384r1, RSA_2048) | `string` | `"EC_secp384r1"` | no |
| tags | A mapping of tags to assign to the certificate | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN (Amazon Resource Name) of the certificate |
| id | The ID of the certificate |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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

* [Wesley Bey](https://github.com/beywesley)
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
