# AWS ALB SSL Certificate Terraform Module

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
    <img src="/images/terraform_modules_logo.webp" alt="Logo" width="300" height="300">
  </a>

<h3 align="center">AWS ALB SSL Certificate Module</h3>
  <p align="center">
    This module creates and manages SSL certificates for AWS Application Load Balancers, enabling secure HTTPS connections.
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

This Terraform module creates and manages SSL certificates for AWS Application Load Balancers. It provisions an AWS Certificate Manager (ACM) certificate and attaches it to an ALB listener, enabling secure HTTPS connections to your applications.

The module supports:
- DNS validation for certificates
- Subject Alternative Names (SANs)
- Different key algorithms
- Attaching certificates to ALB listeners

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic Example

```hcl
module "alb_ssl_cert" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_ssl_cert"

  domain_name     = "example.com"
  validation_method = "DNS"
  listener_arn    = module.https_listener.listener_arn
  certificate_arn = aws_acm_certificate.cert.arn

  tags = {
    terraform   = "true"
    environment = "production"
  }
}
```

### With Subject Alternative Names

```hcl
module "alb_ssl_cert" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_ssl_cert"

  domain_name               = "example.com"
  validation_method         = "DNS"
  subject_alternative_names = ["www.example.com", "api.example.com"]
  listener_arn              = module.https_listener.listener_arn
  certificate_arn           = aws_acm_certificate.cert.arn

  tags = {
    terraform   = "true"
    environment = "production"
  }
}
```

### Argument Reference

* `domain_name` - (Required) A domain name for which the certificate should be issued.
* `validation_method` - (Optional) Which method to use for validation. DNS or EMAIL are valid. Default is "DNS".
* `subject_alternative_names` - (Optional) A list of domains that should be SANs in the issued certificate.
* `key_algorithm` - (Optional) Specifies the algorithm of the public and private key pair. Default is "RSA_2048".
* `listener_arn` - (Required) The ARN of the listener to which to attach the certificate.
* `certificate_arn` - (Required) The ARN of the certificate to attach to the listener.
* `tags` - (Optional) A mapping of tags to assign to the resource.

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
| [aws_lb_listener_certificate.cert_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource | [AWS Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain_name | A domain name for which the certificate should be issued | `string` | n/a | yes |
| validation_method | Which method to use for validation (DNS or EMAIL) | `string` | `"DNS"` | no |
| subject_alternative_names | A list of domains that should be SANs in the issued certificate | `list(string)` | `null` | no |
| key_algorithm | Specifies the algorithm of the public and private key pair | `string` | `"RSA_2048"` | no |
| listener_arn | The ARN of the listener to which to attach the certificate | `string` | `null` | no |
| certificate_arn | The ARN of the certificate to attach to the listener | `string` | `null` | no |
| tags | A mapping of tags to assign to the resource | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| acm_certificate_arn | The ARN of the ACM certificate |
| lb_listener_certificate_arn | The ARN of the LB Listener Certificate |

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
