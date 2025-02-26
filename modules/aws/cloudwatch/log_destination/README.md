# AWS CloudWatch Log Destination Terraform Module

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

<h3 align="center">AWS CloudWatch Log Destination Module</h3>
  <p align="center">
    This module creates CloudWatch Log Destinations to forward log data to other AWS services or cross-account destinations.
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

This Terraform module creates AWS CloudWatch Log Destinations, which are used to forward log data to other AWS services or cross-account destinations. CloudWatch Log Destinations enable:

1. Centralized log management across multiple AWS accounts
2. Real-time log data processing
3. Integration with services like Kinesis Data Streams, Lambda, and Firehose
4. Secure log data sharing with proper access controls

The module supports creating log destinations with appropriate IAM policies and subscription filters to route log data to the specified target service.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Cross-Account Log Forwarding Example

```hcl
module "log_destination" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/cloudwatch/log_destination"

  name                  = "central-logging-destination"
  role_arn              = aws_iam_role.cloudwatch_logs.arn
  target_arn            = aws_kinesis_stream.log_stream.arn
  destination_policy    = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::111122223333:root"  # Source account
        },
        Action = "logs:PutSubscriptionFilter",
        Resource = "arn:aws:logs:us-east-1:444455556666:destination:central-logging-destination"  # This destination
      }
    ]
  })
}
```

### Log Forwarding to Kinesis Firehose Example

```hcl
module "firehose_log_destination" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/cloudwatch/log_destination"

  name                  = "firehose-s3-archive"
  role_arn              = aws_iam_role.cloudwatch_logs.arn
  target_arn            = aws_kinesis_firehose_delivery_stream.s3_delivery.arn
  destination_policy    = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "logs.amazonaws.com"
        },
        Action = "logs:PutSubscriptionFilter",
        Resource = "*"
      }
    ]
  })
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
| [aws_cloudwatch_log_destination.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_destination) | resource | [AWS CloudWatch Log Destination Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html#DestinationMembershipFirehose) |
| [aws_cloudwatch_log_destination_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_destination_policy) | resource | [AWS CloudWatch Log Destination Policy Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html#CrossAccountSubscriptions) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the CloudWatch Log Destination | `string` | n/a | yes |
| role_arn | The ARN of the IAM role that grants CloudWatch Logs permission to deliver logs to the target | `string` | n/a | yes |
| target_arn | The ARN of the target resource (Kinesis stream, Lambda function, or Firehose delivery stream) | `string` | n/a | yes |
| destination_policy | The IAM policy document that governs which AWS accounts can create subscription filters against this destination | `string` | n/a | yes |

<!-- OUTPUTS -->
## Outputs

| Name | Description |
|------|-------------|
| destination_arn | The ARN of the CloudWatch Log Destination |
| destination_name | The name of the CloudWatch Log Destination |

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