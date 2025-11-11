# AWS ALB Target Group Terraform Module

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

<h3 align="center">AWS ALB Target Group Module</h3>
  <p align="center">
    This module creates and manages AWS Application Load Balancer Target Groups, which are used to route requests to registered targets.
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

This Terraform module creates and manages AWS Application Load Balancer Target Groups and Target Group Attachments. Target groups are used to route requests to registered targets (such as EC2 instances, IP addresses, or Lambda functions) as part of a listener rule.

The module supports:
- Different target types (instance, IP, Lambda)
- Customizable health checks
- Protocol configuration
- Target registration

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic Example with EC2 Instances

```hcl
module "web_target_group" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_target_group"

  name        = "web-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  health_check_path = "/health"
  health_check_interval_seconds = 15

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.web.id
}
```

### IP-Based Target Group Example

```hcl
module "api_target_group" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_target_group"

  name        = "api-tg"
  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  health_check_path = "/api/health"
  health_check_protocol = "HTTP"
  matcher = "200,201"

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = "10.0.1.15"
}
```

### Lambda Target Group Example

```hcl
module "lambda_target_group" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_target_group"

  name        = "lambda-tg"
  target_type = "lambda"
  vpc_id      = module.vpc.vpc_id

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_lambda_function.api.arn
}
```

### Argument Reference

* `name` - (Required) Name of the target group.
* `target_type` - (Optional) Type of target. Valid values are instance, ip, or lambda. Default is instance.
* `port` - (Required) Port on which targets receive traffic.
* `protocol` - (Required) Protocol to use for routing traffic to the targets.
* `vpc_id` - (Required) The identifier of the VPC that the target group belongs to.
* `target_group_arn` - (Required) The ARN of the target group with which to register targets.
* `target_id` - (Required) The ID of the target.
* `health_check_protocol` - (Optional) The protocol for health checks. Default is HTTP.
* `health_check_port` - (Optional) The port for health checks. Default is traffic-port.
* `health_check_path` - (Optional) The destination path for health checks. Default is /.
* `health_check_timeout_seconds` - (Optional) Health check timeout in seconds. Default is 5.
* `health_check_interval_seconds` - (Optional) Health check interval in seconds. Default is 30.
* `healthy_threshold_count` - (Optional) Number of consecutive successful health checks. Default is 5.
* `unhealthy_threshold_count` - (Optional) Number of consecutive failed health checks. Default is 2.
* `matcher` - (Optional) Response codes to use when checking for a successful response. Default is 200.

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
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource | [AWS Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html) |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource | [AWS Documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#register-targets) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the target group | `string` | n/a | yes |
| target_type | Type of target (instance, ip, or lambda) | `string` | `"instance"` | no |
| port | Port on which targets receive traffic | `number` | n/a | yes |
| protocol | Protocol to use for routing traffic to the targets | `string` | n/a | yes |
| vpc_id | The identifier of the VPC that the target group belongs to | `string` | n/a | yes |
| target_group_arn | The ARN of the target group with which to register targets | `string` | n/a | yes |
| target_id | The ID of the target | `string` | n/a | yes |
| health_check_protocol | The protocol for health checks | `string` | `"HTTP"` | no |
| health_check_port | The port for health checks | `string` | `"traffic-port"` | no |
| health_check_path | The destination path for health checks | `string` | `"/"` | no |
| health_check_timeout_seconds | Health check timeout in seconds | `number` | `5` | no |
| health_check_interval_seconds | Health check interval in seconds | `number` | `30` | no |
| healthy_threshold_count | Number of consecutive successful health checks | `number` | `5` | no |
| unhealthy_threshold_count | Number of consecutive failed health checks | `number` | `2` | no |
| matcher | Response codes to use when checking for a successful response | `string` | `"200"` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| target_group_arn | The ARN of the Target Group |
| target_group_attachment_arn | The ARN of the Target Group to which the attachment is associated |

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
