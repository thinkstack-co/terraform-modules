# AWS ALB Listener Rule Terraform Module

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

<h3 align="center">AWS ALB Listener Rule Module</h3>
  <p align="center">
    This module creates and manages AWS Application Load Balancer Listener Rules, which determine how the load balancer routes requests to registered targets.
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

This Terraform module creates and manages AWS Application Load Balancer Listener Rules. Listener rules define how the load balancer routes requests to registered targets based on conditions such as path patterns or host headers.

The module supports:
- Path-based routing
- Host-based routing
- Priority configuration for rule evaluation
- Forward actions to target groups

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Path-Based Routing Example

```hcl
module "path_based_rule" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_listener_rule"

  listener_arn      = module.https_listener.listener_arn
  priority          = 100
  target_group_arn  = module.api_target_group.arn
  condition_field   = "path-pattern"
  condition_values  = ["/api/*"]
  type              = "forward"
}
```

### Host-Based Routing Example

```hcl
module "host_based_rule" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_listener_rule"

  listener_arn      = module.https_listener.listener_arn
  priority          = 200
  target_group_arn  = module.blog_target_group.arn
  condition_field   = "host-header"
  condition_values  = ["blog.example.com"]
  type              = "forward"
}
```

### Multiple Rules Example

```hcl
module "api_rule" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_listener_rule"

  listener_arn      = module.https_listener.listener_arn
  priority          = 100
  target_group_arn  = module.api_target_group.arn
  condition_field   = "path-pattern"
  condition_values  = ["/api/*"]
  type              = "forward"
}

module "admin_rule" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_listener_rule"

  listener_arn      = module.https_listener.listener_arn
  priority          = 110
  target_group_arn  = module.admin_target_group.arn
  condition_field   = "path-pattern"
  condition_values  = ["/admin/*"]
  type              = "forward"
}
```

### Argument Reference

* `listener_arn` - (Required) The ARN of the listener to which to attach the rule.
* `priority` - (Optional) The priority for the rule between 1 and 50000. If unset, the next available priority after the current highest rule will be used.
* `target_group_arn` - (Required) The ARN of the Target Group to which to route traffic.
* `condition_field` - (Required) The name of the field. It must be 'path-pattern' for path-based routing or 'host-header' for host-based routing.
* `condition_values` - (Required) The path patterns or host headers to match.
* `type` - (Optional) Type of routing action. Default is "forward".

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
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource | [AWS Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-update-rules.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| listener_arn | The ARN of the listener to attach the rule | `string` | n/a | yes |
| priority | The priority for the rule between 1 and 50000 | `number` | `null` | no |
| target_group_arn | The ARN of the Target Group to which to route traffic | `string` | n/a | yes |
| condition_field | The name of the field (path-pattern or host-header) | `string` | n/a | yes |
| condition_values | The path patterns or host headers to match | `list(string)` | n/a | yes |
| type | Type of routing action | `string` | `"forward"` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

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
