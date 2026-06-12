# AppGate SDP Gateway Terraform Module

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

<h3 align="center">AppGate SDP Gateway</h3>
  <p align="center">
    Provisions an AppGate SDP gateway EC2 instance from the marketplace BYOL AMI, with an optional Elastic IP and CloudWatch status-check alarms.
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

This module deploys a single AppGate SDP gateway as a self-contained unit. It resolves the
AppGate SDP BYOL AMI from the AWS Marketplace, launches an EC2 instance from it, and (by default)
allocates and associates an Elastic IP so the gateway keeps a stable public address across
stop/start and instance replacement. CloudWatch status-check alarms for the instance and the
underlying host are created by default.

Unlike a thin wrapper, the instance, Elastic IP, AMI lookup, and alarms are all defined directly
in this module rather than calling the shared `ec2_instance` / `eip` modules — keeping the AppGate
gateway's full lifecycle in one place.

Two behaviours are intentional and worth calling out:

- **The AMI is resolved with `most_recent = true`, but the instance ignores AMI changes after
  launch** (`lifecycle.ignore_changes = [ami, user_data]`). A running gateway is never rebuilt just
  because a newer marketplace image appears; bumping `ami_name_filter` only affects new instances.
- **`associate_public_ip_address` defaults to `true` and requires `private_ip`.** When the gateway
  is public-facing (placed in a public subnet), a `precondition` forces you to pin `private_ip` to
  an address within that public subnet so the gateway lands on a stable, known address. Set
  `associate_public_ip_address = false` to run the gateway private, and `create_eip = false` to skip
  the Elastic IP.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic Example

```hcl
module "appgate_sdp" {
  source = "github.com/thinkstack-co/terraform-modules//modules/netcov/appgate_sdp?ref=v1.0.0"

  name                   = "aws-prod-aggw01"
  instance_type          = "t3a.medium"
  subnet_id              = module.vpc.public_subnet_ids[0]
  availability_zone      = module.vpc.availability_zone[0]
  private_ip             = "10.100.201.125"
  key_name               = module.keypair.key_name
  vpc_security_group_ids = [module.appgate_server_sg.id]

  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "prod"
    backup      = "true"
    role        = "appgate_server"
  }
}
```

### Private Gateway (No Public IP, No EIP)

```hcl
module "appgate_sdp" {
  source = "github.com/thinkstack-co/terraform-modules//modules/netcov/appgate_sdp?ref=v1.0.0"

  name                        = "aws-prod-aggw02"
  instance_type               = "t3a.medium"
  subnet_id                   = module.vpc.private_subnet_ids[0]
  availability_zone           = module.vpc.availability_zone[0]
  vpc_security_group_ids      = [module.appgate_server_sg.id]
  associate_public_ip_address = false # private gateway; private_ip no longer required
  create_eip                  = false # no Elastic IP
}
```

### Pinning a Different AppGate Version

```hcl
module "appgate_sdp" {
  source = "github.com/thinkstack-co/terraform-modules//modules/netcov/appgate_sdp?ref=v1.0.0"

  name                   = "aws-prod-aggw01"
  instance_type          = "t3a.medium"
  subnet_id              = module.vpc.public_subnet_ids[0]
  availability_zone      = module.vpc.availability_zone[0]
  private_ip             = "10.100.201.125"
  vpc_security_group_ids = [module.appgate_server_sg.id]

  # Select a different AppGate SDP BYOL image
  ami_name_filter = "Appgate-SDP-6.5.7-BYOL*"
}
```

### Argument Reference

- `name` - (Required) Name applied to the gateway instance, EIP, and alarms.
- `instance_type` - (Required) EC2 instance type for the gateway.
- `subnet_id` - (Required) Subnet to launch in. Use a public subnet when `associate_public_ip_address` is true.
- `vpc_security_group_ids` - (Required) Security group IDs to associate with the gateway.
- `private_ip` - (Optional) Static private IP. Required when `associate_public_ip_address` is true and must fall within one of the public subnets.
- `associate_public_ip_address` - (Optional) Assign a public IP at launch (public-subnet placement). Default `true`.
- `create_eip` - (Optional) Allocate and associate an Elastic IP. Default `true`.
- `ami_name_filter` - (Optional) Marketplace AMI name filter. Default `Appgate-SDP-6.5.6-BYOL*`.

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
| [aws_instance.appgate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource | [AWS Docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html) |
| [aws_eip.appgate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource | [AWS Docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) |
| [aws_cloudwatch_metric_alarm.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource | [AWS Docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html) |
| [aws_cloudwatch_metric_alarm.system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource | [AWS Docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html) |
| [aws_ami.appgate_sdp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source | [AWS Docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source | [AWS Docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) |
| [aws_ec2_instance_type.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source | [AWS Docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name applied to the gateway instance, EIP, and alarms. | `string` | n/a | yes |
| instance_type | EC2 instance type for the gateway. | `string` | n/a | yes |
| subnet_id | Subnet to launch in. Use a public subnet when associate_public_ip_address is true. | `string` | n/a | yes |
| vpc_security_group_ids | Security group IDs to associate with the gateway. | `list(any)` | n/a | yes |
| create_eip | Allocate and associate an Elastic IP with the gateway. | `bool` | `true` | no |
| associate_public_ip_address | Assign a public IP at launch (public-subnet placement). Requires private_ip when true. | `bool` | `true` | no |
| create_cloudwatch_alarms | Create CloudWatch status-check alarms for the instance. | `bool` | `true` | no |
| ami_name_filter | Name filter used to select the AppGate SDP marketplace AMI. | `string` | `"Appgate-SDP-6.5.6-BYOL*"` | no |
| ami_architecture | CPU architecture of the AppGate SDP AMI. | `string` | `"x86_64"` | no |
| ami_virtualization_type | Virtualization type of the AppGate SDP AMI. | `string` | `"hvm"` | no |
| availability_zone | Availability zone in which to launch the gateway. | `string` | `""` | no |
| private_ip | Static private IP within the subnet. Required when associate_public_ip_address is true. | `string` | `null` | no |
| key_name | Name of the EC2 key pair to associate with the instance. | `string` | `""` | no |
| iam_instance_profile | IAM instance profile to attach. | `string` | `"AmazonSSMRoleForInstancesQuickSetup"` | no |
| ebs_optimized | Whether the instance is EBS-optimized. | `bool` | `true` | no |
| disable_api_termination | Enable EC2 instance termination protection. | `bool` | `false` | no |
| instance_initiated_shutdown_behavior | Shutdown behavior: stop or terminate. | `string` | `"stop"` | no |
| enable_detailed_monitoring | Enable detailed (1-min) monitoring. | `bool` | `false` | no |
| enable_recover_action | Attach the EC2 recover action to the system alarm. Null auto-detects. | `bool` | `null` | no |
| ipv6_addresses | IPv6 addresses to associate with the primary network interface. | `list(string)` | `[]` | no |
| placement_group | Placement group to start the instance in. | `string` | `""` | no |
| source_dest_check | Controls source/destination checking on the instance. | `bool` | `true` | no |
| tenancy | Instance tenancy: default, dedicated, or host. | `string` | `"default"` | no |
| user_data | User data to provide at launch. | `string` | `""` | no |
| user_data_base64 | Base64-encoded user data to provide at launch. | `string` | `""` | no |
| http_endpoint | Whether the instance metadata service is available. | `string` | `"enabled"` | no |
| http_tokens | Whether IMDSv2 session tokens are required. | `string` | `"required"` | no |
| encrypted | Whether the root volume is encrypted. | `bool` | `true` | no |
| root_delete_on_termination | Destroy the root volume on instance termination. | `bool` | `true` | no |
| root_volume_size | Size in GiB of the root EBS volume. | `string` | `"100"` | no |
| root_volume_type | Root volume type. | `string` | `"gp3"` | no |
| root_volume_iops | IOPS for the root volume. | `number` | `3000` | no |
| root_volume_throughput | Throughput for the root volume. | `number` | `125` | no |
| exclude_root_volume_snapshot | Exclude selected tag keys from the root volume tags. | `bool` | `false` | no |
| root_volume_excluded_tag_keys | Tag keys to remove from the root volume when excluding. | `list(string)` | `[]` | no |
| eip_associate_with_private_ip | Private IP to associate the EIP with. | `string` | `""` | no |
| tags | Tags applied to the gateway instance, root volume, and EIP. | `map(string)` | see variables.tf | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the AppGate gateway EC2 instance. |
| availability_zone | Availability zone of the gateway instance. |
| private_ip | Private IP address of the gateway instance. |
| public_ip | Public IP assigned at launch (if associate_public_ip_address is true). |
| ami_id | ID of the AppGate SDP AMI the gateway was launched from. |
| eip_id | Allocation ID of the gateway's Elastic IP. Null if create_eip is false. |
| eip_public_ip | Public IP address of the gateway's Elastic IP. Null if create_eip is false. |
| instance_alarm_id | ID of the instance status-check alarm. Null if create_cloudwatch_alarms is false. |
| system_alarm_id | ID of the system status-check alarm. Null if create_cloudwatch_alarms is false. |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contact

Think|Stack - [![LinkedIn][linkedin-shield]][linkedin-url] - <info@thinkstack.co>

Project Link: [https://github.com/thinkstack-co/terraform-modules](https://github.com/thinkstack-co/terraform-modules)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgments

- [Wesley Bey](https://github.com/beywesley)
- [Zachary Hill](https://zacharyhill.co)
- [Jake Jones](https://github.com/jakeasarus)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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
[license-url]: https://github.com/thinkstack-co/terraform-modules/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/company/thinkstack/
