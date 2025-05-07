# AWS Cost Report Terraform Module

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

<h3 align="center">AWS Cost Report Module</h3>
  <p align="center">
    This module generates a PDF cost report itemized by AWS resource cost allocation tag (default: <code>Name</code>) and uploads it to an S3 bucket.
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

This Terraform module creates a scheduled AWS Lambda function that fetches cost data from the Cost Explorer API, generates a PDF report grouped by the specified cost allocation tag (default: <code>Name</code>), and uploads the report to an S3 bucket. The report includes:

- EC2 instance cost per server
- EBS storage cost per server
- Data transfer cost per server
- AWS Backup cost per server

Additional features:
- Customizable tag key
- S3 bucket lifecycle rules and Glacier transitions
- Output: S3 URL of the latest PDF report

## Usage
```hcl
module "aws_cost_report" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/aws_cost_report"
  bucket_prefix = "my-cost-report-"
  # Optionally override schedule or tag key
  # report_tag_key = "Name"
}
```

## Requirements
- Cost Explorer must be enabled in your AWS account
- Lambda execution role must have permissions for Cost Explorer and S3

## Providers
- aws >= 4.0

## Resources
- AWS Lambda function (Python)
- S3 bucket for report storage
- CloudWatch Event Rule for scheduling
- IAM roles and policies

## Inputs
| Name                     | Description                                      | Type    | Default                  |
|--------------------------|--------------------------------------------------|---------|--------------------------|
| bucket_prefix            | Prefix for the S3 bucket name                    | string  | "aws-cost-report-"       |
| report_tag_key           | Cost allocation tag key for grouping             | string  | "Name"                   |

| enable_s3_lifecycle_rules| Enable S3 lifecycle rules for report retention   | bool    | true                     |
| report_retention_days    | Days to retain reports in S3                     | number  | 90                       |
| enable_glacier_transition| Enable transition to Glacier storage             | bool    | false                    |
| glacier_transition_days  | Days before transitioning to Glacier             | number  | 30                       |
| glacier_retention_days   | Days to retain in Glacier before deletion        | number  | 365                      |
| schedule_expression      | CloudWatch schedule expression for Lambda        | string  | "cron(0 1 1 * ? *)"      |
| tags                     | Tags to apply to all resources                   | map     | {}                       |

## Outputs
| Name                   | Description                                  |
|------------------------|----------------------------------------------|
| cost_report_pdf_url    | S3 URL of the latest PDF report              |
| lambda_function_arn    | ARN of the Lambda function                   |
| s3_bucket_name         | Name of the S3 bucket for reports            |

## License
Distributed under the MIT License. See `LICENSE` for more information.

## Contact
Think|Stack – <https://www.thinkstack.co/>

## Acknowledgments
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Lambda](https://aws.amazon.com/lambda/)
- [AWS Cost Explorer](https://docs.aws.amazon.com/cost-management/latest/userguide/ce-api.html)
- [FPDF](https://pyfpdf.github.io/)

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/thinkstack-co/terraform-modules.svg?style=for-the-badge
[contributors-url]: https://github.com/thinkstack-co/terraform-modules/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/thinkstack-co/terraform-modules.svg?style=for-the-badge
[forks-url]: https://github.com/thinkstack-co/terraform-modules/network/members
[stars-shield]: https://img.shields.io/github/stars/thinkstack-co/terraform-modules.svg?style=for-the-badge
[stars-url]: https://github.com/thinkstack-co/terraform-modules/stargazers
[issues-shield]: https://img.shields.io/github/issues/thinkstack-co/terraform-modules.svg?style=for-the-badge
[issues-url]: https://github.com/thinkstack-co/terraform-modules/issues
[license-shield]: https://img.shields.io/github/license/thinkstack-co/terraform-modules.svg?style=for-the-badge
[license-url]: https://github.com/thinkstack-co/terraform-modules/blob/main/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/company/thinkstack-co/
