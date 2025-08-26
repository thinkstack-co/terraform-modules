# AWS ALB Listener Terraform Module

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

<h3 align="center">AWS ALB Listener Module</h3>
  <p align="center">
    This module creates and manages AWS Application Load Balancer Listeners, which define how the load balancer routes requests to targets.
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

This Terraform module creates and manages AWS Application Load Balancer Listeners. Listeners check for connection requests from clients, using the protocol and port that you configure, and forward requests to one or more target groups based on the rules you define.

The module supports:
- HTTP and HTTPS listeners
- Multiple action types (forward, redirect, fixed-response)
- SSL certificate configuration
- Default actions for unmatched requests
- Stickiness configuration

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### HTTP Listener Example

```hcl
module "http_listener" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_listener"

  load_balancer_arn = module.web_alb.lb_arn
  port              = 80
  protocol          = "HTTP"

  default_action = {
    type             = "forward"
    target_group_arn = module.web_target_group.arn
  }
}
```

### HTTPS Listener with Redirect Example

```hcl
module "https_listener" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_listener"

  load_balancer_arn = module.web_alb.lb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.acm_certificate.acm_certificate_arn

  default_action = {
    type             = "forward"
    target_group_arn = module.web_target_group.arn
  }
}

module "http_redirect_listener" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_listener"

  load_balancer_arn = module.web_alb.lb_arn
  port              = 80
  protocol          = "HTTP"

  default_action = {
    type = "redirect"
    redirect = {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
```

### Argument Reference

* `load_balancer_arn` - (Required) The ARN of the load balancer.
* `port` - (Required) The port on which the load balancer is listening.
* `protocol` - (Required) The protocol for connections from clients to the load balancer. Valid values are HTTP and HTTPS.
* `ssl_policy` - (Optional) The name of the SSL Policy for the listener. Required if protocol is HTTPS.
* `certificate_arn` - (Optional) The ARN of the default SSL server certificate. Required if protocol is HTTPS.
* `default_action` - (Required) An action block. Action blocks are documented below.

#### Default Action Blocks

* `type` - (Required) The type of routing action. Valid values are forward, redirect, fixed-response.
* `target_group_arn` - (Optional) The ARN of the Target Group to which to route traffic. Required if type is forward.
* `redirect` - (Optional) Information for creating a redirect action. Required if type is redirect.
* `fixed_response` - (Optional) Information for creating a fixed-response action. Required if type is fixed-response.

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
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource | [AWS Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| load_balancer_arn | The ARN of the load balancer | `string` | n/a | yes |
| port | The port on which the load balancer is listening | `number` | n/a | yes |
| protocol | The protocol for connections from clients to the load balancer | `string` | n/a | yes |
| ssl_policy | The name of the SSL Policy for the listener | `string` | `null` | no |
| certificate_arn | The ARN of the default SSL server certificate | `string` | `null` | no |
| default_action | An action block containing action configuration | `map(any)` | n/a | yes |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| listener_arn | The ARN of the listener |
| listener_id | The ID of the listener |

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
