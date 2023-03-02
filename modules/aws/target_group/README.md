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

  <h3 align="center">Target Group Module</h3>

  <p align="center">
    This module sets up a target group with the parameters specified. 
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
    <li><a href="#resources">Resources</a></li>
    <li><a href="#inputs">Inputs</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>


<!-- USAGE EXAMPLES -->
## Usage

### Simple Target Group Example

```
module "application_target_group" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/target_group"

  name                   = "aws_prod_alb"
  port                   = 443
  protocol               = "https"
  vpc_id                 = var.vpc_id
  target_type            = "instance"
  health_check_interval  = 30
  health_check_path      = var.health_check_path
  health_check_port      = 80
  health_check_protocol  = "http"
  health_check_timeout   = 30
  health_check_threshold = 3
  health_check_matcher   = [200, 204, 301, 302]
  
  tags = {
    terraform        = "true"
    created_by       = "YOUR NAME"
    environment      = "prod"
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.45.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.45.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | (Optional) Approximate amount of time, in seconds, between health checks of an individual target. The range is 5-300. For lambda target groups, it needs to be greater than the timeout of the underlying lambda. Defaults to 30. | `number` | `30` | no |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | (May be required) Response codes to use when checking for a healthy responses from a target. You can specify multiple values (for example, 200,202 for HTTP(s) or 0,12 for GRPC) or a range of values (for example, 200-299 or 0-99). Required for HTTP/HTTPS/GRPC ALB. Only applies to Application Load Balancers (i.e., HTTP/HTTPS/GRPC) not Network Load Balancers (i.e., TCP). | `list(number)` | <pre>[<br>  200,<br>  204,<br>  301,<br>  302<br>]</pre> | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | (May be required) Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS. | `string` | `"/"` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | (Optional) The port the load balancer uses when performing health checks on targets. Default is traffic-port. | `number` | `80` | no |
| <a name="input_health_check_protocol"></a> [health\_check\_protocol](#input\_health\_check\_protocol) | (Optional) Protocol the load balancer uses when performing health checks on targets. Must be either TCP, HTTP, or HTTPS. The TCP protocol is not supported for health checks if the protocol of the target group is HTTP or HTTPS. Defaults to HTTP. | `string` | `"HTTP"` | no |
| <a name="input_health_check_threshold"></a> [health\_check\_threshold](#input\_health\_check\_threshold) | (Optional) Number of consecutive health check successes required before considering a target healthy. The range is 2-10. Defaults to 3. | `number` | `3` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | (optional) Amount of time, in seconds, during which no response from a target means a failed health check. The range is 2–120 seconds. For target groups with a protocol of HTTP, the default is 6 seconds. For target groups with a protocol of TCP, TLS or HTTPS, the default is 10 seconds. For target groups with a protocol of GENEVE, the default is 5 seconds. If the target type is lambda, the default is 30 seconds. | `number` | `30` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional, Forces new resource) Name of the target group. If omitted, Terraform will assign a random, unique name. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | (May be required, Forces new resource) Port on which targets receive traffic, unless overridden when registering a specific target. Required when target\_type is instance, ip or alb. Does not apply when target\_type is lambda. | `number` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (May be required, Forces new resource) Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP\_UDP, TLS, or UDP. Required when target\_type is instance, ip or alb. Does not apply when target\_type is lambda. | `string` | n/a | yes |
| <a name="input_stickiness_cookie_duration"></a> [stickiness\_cookie\_duration](#input\_stickiness\_cookie\_duration) | (Optional) Only used when the type is lb\_cookie. The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds). | `number` | `86400` | no |
| <a name="input_stickiness_enabled"></a> [stickiness\_enabled](#input\_stickiness\_enabled) | (Optional) Boolean to enable / disable stickiness. Default is true. | `bool` | `true` | no |
| <a name="input_stickiness_type"></a> [stickiness\_type](#input\_stickiness\_type) | (Required) The type of sticky sessions. The only current possible values are lb\_cookie, app\_cookie for ALBs, source\_ip for NLBs, and source\_ip\_dest\_ip, source\_ip\_dest\_ip\_proto for GWLBs. | `string` | `"lb_cookie"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of tags to assign to the resource. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | `{}` | no |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | (May be required, Forces new resource) Type of target that you must specify when registering targets with this target group. See doc for supported values. The default is instance. | `string` | `"instance"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Optional, Forces new resource) Identifier of the VPC in which to create the target group. Required when target\_type is instance, ip or alb. Does not apply when target\_type is lambda. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the target group |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics |
| <a name="output_id"></a> [id](#output\_id) | The ARN of the target group |
| <a name="output_name"></a> [name](#output\_name) | The name of the target group |
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
* [Derek McCallister](https://github.com/TheJalpa)
* [Wesley Bey](https://github.com/beywesley)

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