# AWS Application Load Balancer (ALB) Terraform Modules

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

<h3 align="center">AWS Application Load Balancer Modules</h3>
  <p align="center">
    This collection of modules provides a comprehensive solution for deploying and managing AWS Application Load Balancers and their associated resources.
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
    <li><a href="#module-components">Module Components</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## Overview

This collection of Terraform modules provides a comprehensive solution for deploying and managing AWS Application Load Balancers (ALB) and their associated resources. Application Load Balancers are a feature of Elastic Load Balancing that allows for content-based routing and applications that run in containers.

The modules in this collection work together to create a complete load balancing solution, including the load balancer itself, listeners, target groups, listener rules, and SSL certificates. Each module is designed to be used independently or in combination with the others, providing flexibility for various deployment scenarios.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Module Components

This collection includes the following modules:

### 1. ALB Load Balancer Module

Creates and manages AWS Application Load Balancers with support for internal or internet-facing configurations, security groups, subnets, and access logs.

[View Documentation](./alb_load_balancer/README.md)

### 2. ALB Listener Module

Creates and manages ALB Listeners with support for HTTP and HTTPS protocols, multiple action types, and SSL certificate configuration.

[View Documentation](./alb_listener/README.md)

### 3. ALB Listener Rule Module

Creates and manages ALB Listener Rules for path-based and host-based routing with priority configuration for rule evaluation.

[View Documentation](./alb_listener_rule/README.md)

### 4. ALB SSL Certificate Module

Creates and manages SSL certificates for ALBs with DNS validation and support for Subject Alternative Names (SANs).

[View Documentation](./alb_ssl_cert/README.md)

### 5. ALB Target Group Module

Creates and manages ALB Target Groups with support for different target types, customizable health checks, and target registration.

[View Documentation](./alb_target_group/README.md)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Complete ALB Setup Example

The following example demonstrates how to use all the modules together to create a complete ALB setup:

```hcl
# Create the Application Load Balancer
module "web_alb" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_load_balancer"

  alb_name           = "web-application-lb"
  internal           = false
  subnets            = ["subnet-12345678", "subnet-87654321"]
  security_groups    = [module.alb_security_group.id]
  enable_http2       = true
  access_logs_enabled = true
  access_logs_bucket = "my-alb-logs-bucket"

  tags = {
    terraform   = "true"
    environment = "production"
  }
}

# Create an HTTPS listener
module "https_listener" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_listener"

  load_balancer_arn = module.web_alb.lb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.alb_ssl_cert.acm_certificate_arn

  default_action = {
    type             = "forward"
    target_group_arn = module.web_target_group.target_group_arn
  }
}

# Create an HTTP to HTTPS redirect listener
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

# Create a target group for web servers
module "web_target_group" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_target_group"

  name        = "web-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  health_check_path = "/health"

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.web.id
}

# Create a listener rule for API traffic
module "api_listener_rule" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/alb/alb_listener_rule"

  listener_arn      = module.https_listener.listener_arn
  priority          = 100
  target_group_arn  = module.api_target_group.target_group_arn
  condition_field   = "path-pattern"
  condition_values  = ["/api/*"]
  type              = "forward"
}

# Create and attach an SSL certificate
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

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- REQUIREMENTS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

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
