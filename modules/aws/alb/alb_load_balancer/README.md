# AWS Application Load Balancer (ALB) Terraform Module

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

<h3 align="center">AWS Application Load Balancer Module</h3>
  <p align="center">
    This module provisions and manages AWS Application Load Balancers (ALB) for distributing incoming application traffic across multiple targets.
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

This Terraform module creates and manages AWS Application Load Balancers (ALB). ALBs automatically distribute incoming application traffic across multiple targets, such as EC2 instances, containers, and IP addresses, in multiple Availability Zones.

The module supports:
- Internal or internet-facing load balancers
- Cross-zone load balancing
- HTTP/2 support
- Access logs to S3
- Security group configuration
- Deletion protection
- Custom idle timeout settings

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic Example

```hcl
module "web_alb" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_load_balancer"

  alb_name                         = "web-application-lb"
  internal                         = false
  subnets                          = ["subnet-12345678", "subnet-87654321"]
  security_groups                  = [module.alb_security_group.id]
  enable_deletion_protection       = true
  access_logs_enabled              = true
  access_logs_bucket               = "my-alb-logs-bucket"
  
  tags = {
    terraform   = "true"
    environment = "production"
    role        = "web"
  }
}
```

### Internal Load Balancer Example

```hcl
module "internal_alb" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_load_balancer"

  alb_name                         = "internal-app-lb"
  internal                         = true
  subnets                          = ["subnet-private1", "subnet-private2"]
  security_groups                  = [module.internal_sg.id]
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 120
  
  tags = {
    terraform   = "true"
    environment = "production"
    role        = "application"
  }
}
```

### Argument Reference

* `alb_name` - (Required) The name of the load balancer.
* `subnets` - (Required) A list of subnet IDs to attach to the load balancer.
* `security_groups` - (Required) A list of security group IDs to assign to the load balancer.
* `internal` - (Optional) If true, the load balancer will be internal. Default is false.
* `enable_deletion_protection` - (Optional) If true, deletion of the load balancer will be disabled. Default is false.
* `enable_http2` - (Optional) Indicates whether HTTP/2 is enabled. Default is true.
* `enable_cross_zone_load_balancing` - (Optional) If true, cross-zone load balancing is enabled. Default is false.
* `idle_timeout` - (Optional) The time in seconds that the connection is allowed to be idle. Default is 60.
* `access_logs_enabled` - (Optional) Boolean to enable/disable access logs. Default is false.
* `access_logs_bucket` - (Optional) The S3 bucket name to store access logs.
* `access_logs_prefix` - (Optional) The S3 bucket prefix for access logs. Default is "alb-log".
* `tags` - (Optional) A map of tags to assign to the resource.

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
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource | [AWS Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alb_name | The name of the LB | `string` | n/a | yes |
| subnets | A list of subnet IDs to attach to the LB | `list(string)` | n/a | yes |
| security_groups | A list of security group IDs to assign to the LB | `list(any)` | n/a | yes |
| internal | If true, the LB will be internal | `bool` | `false` | no |
| enable_deletion_protection | If true, deletion of the load balancer will be disabled | `bool` | `false` | no |
| enable_http2 | Indicates whether HTTP/2 is enabled | `bool` | `true` | no |
| enable_cross_zone_load_balancing | If true, cross-zone load balancing is enabled | `bool` | `false` | no |
| idle_timeout | The time in seconds that the connection is allowed to be idle | `number` | `60` | no |
| drop_invalid_header_fields | Indicates whether invalid header fields are dropped | `bool` | `true` | no |
| ip_address_type | The type of IP addresses used by the subnets (ipv4 or dualstack) | `string` | `"ipv4"` | no |
| load_balancer_type | The type of load balancer to create | `string` | `"application"` | no |
| access_logs_enabled | Boolean to enable/disable access logs | `bool` | `false` | no |
| access_logs_bucket | The S3 bucket name to store access logs | `string` | n/a | no |
| access_logs_prefix | The S3 bucket prefix for access logs | `string` | `"alb-log"` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| lb_arn | The ARN of the Load Balancer |
| lb_dns_name | The DNS name of the Load Balancer |

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
