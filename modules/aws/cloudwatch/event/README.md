# AWS CloudWatch Event Terraform Module

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

<h3 align="center">AWS CloudWatch Event Module</h3>
  <p align="center">
    This module creates CloudWatch Events (now Amazon EventBridge) rules and targets to trigger automated actions based on events or schedules.
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

This Terraform module creates AWS CloudWatch Events (now known as Amazon EventBridge) rules and targets. CloudWatch Events allow you to:

1. Create scheduled tasks that run on a regular basis
2. Respond to operational changes within your AWS resources
3. Trigger automated actions when specific events occur
4. Connect event-driven applications with various AWS services

The module supports creating event rules with schedule expressions and connecting them to target resources like Lambda functions, SNS topics, or other AWS services.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Scheduled Event Example

```hcl
module "daily_backup_event" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/cloudwatch/event"

  name                = "daily-backup-trigger"
  description         = "Triggers daily backup Lambda function at 1 AM UTC"
  schedule_expression = "cron(0 1 * * ? *)"
  is_enabled          = true
  event_target_arn    = aws_lambda_function.backup.arn
}
```

### Weekly Maintenance Window Example

```hcl
module "weekly_maintenance" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/cloudwatch/event"

  name                = "weekly-maintenance-window"
  description         = "Triggers weekly maintenance tasks every Sunday at 2 AM UTC"
  schedule_expression = "cron(0 2 ? * SUN *)"
  is_enabled          = true
  event_target_arn    = aws_lambda_function.maintenance.arn
}
```

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
| [aws_cloudwatch_event_rule.event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource | [AWS CloudWatch Events Documentation](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-rules.html) |
| [aws_cloudwatch_event_target.event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource | [AWS CloudWatch Event Targets Documentation](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the CloudWatch Event Rule | `string` | n/a | yes |
| description | The description of the CloudWatch Event Rule | `string` | n/a | yes |
| schedule_expression | The scheduling expression (rate or cron expression) for when the rule should be triggered | `string` | n/a | yes |
| is_enabled | Whether the rule should be enabled | `bool` | `true` | no |
| event_target_arn | The Amazon Resource Name (ARN) of the target resource for the CloudWatch Event Rule | `string` | n/a | yes |

<!-- OUTPUTS -->
## Outputs

| Name | Description |
|------|-------------|
| event_rule_id | The ID of the CloudWatch Event Rule |

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
[Terraform.io]: https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform
[Terraform-url]: https://terraform.io