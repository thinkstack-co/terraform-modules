# AWS CloudWatch Alarm Terraform Module

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

<h3 align="center">AWS CloudWatch Alarm Module</h3>
  <p align="center">
    This module creates CloudWatch metric alarms to monitor AWS resources and trigger actions based on threshold conditions.
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

This Terraform module creates AWS CloudWatch metric alarms that monitor specific metrics and trigger actions when those metrics cross defined thresholds. CloudWatch alarms can be used to:

1. Monitor resource utilization (CPU, memory, disk space, etc.)
2. Track application performance metrics
3. Set up automated responses to operational events
4. Alert teams to potential issues before they impact users

The module supports all CloudWatch alarm features including multiple evaluation periods, various comparison operators, and the ability to trigger different actions based on alarm states.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic CPU Utilization Alarm Example

```hcl
module "cpu_alarm" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/cloudwatch/alarm"

  alarm_name          = "high-cpu-utilization"
  alarm_description   = "This metric monitors EC2 CPU utilization exceeding 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [aws_sns_topic.alerts.arn]
  
  dimensions = {
    InstanceId = aws_instance.web_server.id
  }
}
```

### Low Storage Space Alarm Example

```hcl
module "storage_alarm" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/cloudwatch/alarm"

  alarm_name          = "low-ebs-storage"
  alarm_description   = "Alert when EBS volume has less than 10% free space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/EBS"
  period              = 60
  statistic           = "Average"
  threshold           = 10
  alarm_actions       = [aws_sns_topic.alerts.arn]
  
  dimensions = {
    VolumeId = aws_ebs_volume.data_volume.id
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

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0.0 |

## Resources

| Name | Type | Documentation |
|------|------|--------------|
| [aws_cloudwatch_metric_alarm.alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource | [AWS CloudWatch Alarm Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| actions_enabled | Indicates whether or not actions should be executed during any changes to the alarm's state | `bool` | `true` | no |
| alarm_actions | The list of actions to execute when this alarm transitions into an ALARM state from any other state | `list(string)` | `null` | no |
| alarm_description | The description for the alarm | `string` | `null` | no |
| alarm_name | The descriptive name for the alarm | `string` | n/a | yes |
| comparison_operator | The arithmetic operation to use when comparing the specified Statistic and Threshold | `string` | n/a | yes |
| datapoints_to_alarm | The number of datapoints that must be breaching to trigger the alarm | `number` | `null` | no |
| dimensions | The dimensions for the alarm's associated metric | `map(any)` | n/a | yes |
| evaluation_periods | The number of periods over which data is compared to the specified threshold | `string` | n/a | yes |
| insufficient_data_actions | The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state | `string` | n/a | yes |
| metric_name | The name for the alarm's associated metric | `string` | n/a | yes |
| namespace | The namespace for the alarm's associated metric | `string` | n/a | yes |
| ok_actions | The list of actions to execute when this alarm transitions into an OK state from any other state | `list(string)` | `null` | no |
| period | The period in seconds over which the specified statistic is applied | `string` | n/a | yes |
| statistic | The statistic to apply to the alarm's associated metric | `string` | n/a | yes |
| threshold | The value against which the specified statistic is compared | `string` | n/a | yes |
| treat_missing_data | Sets how this alarm is to handle missing data points | `string` | `"missing"` | no |
| unit | The unit for the alarm's associated metric | `string` | `null` | no |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- OUTPUTS -->
## Outputs

No outputs.

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