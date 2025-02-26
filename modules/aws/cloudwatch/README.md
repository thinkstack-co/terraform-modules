# AWS CloudWatch Terraform Modules

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

<h3 align="center">AWS CloudWatch Modules</h3>
  <p align="center">
    This collection of modules helps you configure AWS CloudWatch monitoring, alerting, and logging capabilities.
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
    <li><a href="#providers">Providers</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## Overview

AWS CloudWatch is a monitoring and observability service that provides data and actionable insights for AWS, hybrid, and on-premises applications and infrastructure resources. This collection of Terraform modules helps you configure various CloudWatch components to monitor your infrastructure, set up alarms, schedule events, and manage log destinations.

The modules in this collection work together to create a comprehensive monitoring and alerting system for your AWS resources, helping you maintain visibility into your infrastructure's health and performance.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Module Components

This collection includes the following modules:

### 1. CloudWatch Alarm Module

Creates CloudWatch metric alarms that trigger based on metric thresholds. These alarms can notify you or take automated actions when metrics cross specified thresholds.

[View Documentation](./alarm/README.md)

### 2. CloudWatch Event Module

Sets up CloudWatch Events (now Amazon EventBridge) rules and targets to respond to operational changes and trigger automated actions based on events or schedules.

[View Documentation](./event/README.md)

### 3. CloudWatch Log Destination Module

Configures CloudWatch Logs destinations to send log data to other services or third-party tools for further processing, analysis, or storage.

[View Documentation](./log_destination/README.md)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

The CloudWatch modules can be used individually or together to create a comprehensive monitoring solution. Here's an example of how you might use them together:

```hcl
# Create a CloudWatch alarm to monitor CPU utilization
module "cpu_alarm" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/cloudwatch/alarm"

  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  
  dimensions = {
    InstanceId = aws_instance.web_server.id
  }
}

# Create a scheduled event to run a Lambda function every day
module "daily_backup_event" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/cloudwatch/event"

  name                = "daily-backup-trigger"
  description         = "Triggers daily backup Lambda function"
  schedule_expression = "cron(0 1 * * ? *)"
  is_enabled          = true
  event_target_arn    = aws_lambda_function.backup.arn
}

# Set up a log destination to send logs to S3
module "log_destination" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/cloudwatch/log_destination"

  destination_name    = "s3-log-destination"
  destination_target_arn = aws_kinesis_firehose_delivery_stream.s3_stream.arn
  
  # Additional configuration for IAM roles and policies
  # ...
}
```

For detailed usage instructions for each module, please refer to their individual README files.

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
