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

<h3 align="center">EC2 Instance Module</h3>
  <p align="center">
    This module sets up an EC2 instance with the parameters specified. This module has root block devices modifiable
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
    <li><a href="#Resources">Resources</a></li>
    <li><a href="#inputs">Inputs</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- USAGE EXAMPLES -->

## Usage

### Simple EC2 Instance Example

```
module "aws_prod_app" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance"

  ami                    = "ami-ffffffff"
  availability_zone      = module.vpc.availability_zone[0]
  count                  = 1
  instance_type          = "m5.xlarge"
  key_name               = module.keypair.key_name
  name                   = "aws_prod_app"
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = ["sg-ffffffff"]
  tags = {
    terraform        = "true"
    created_by       = "YOUR NAME"
    environment      = "prod"
    role             = "app"
    backup           = "true"
  }
}
```

### EC2 Instance with Detailed Monitoring (Optional)

By default, instances use free basic monitoring (5-min intervals). Set `enable_detailed_monitoring = true` for 1-min intervals (~$2.10/month/instance).
Alarms automatically adjust their period to match the monitoring mode.

```
module "aws_prod_app" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance"

  ami                         = "ami-ffffffff"
  availability_zone           = module.vpc.availability_zone[0]
  instance_type               = "m5.xlarge"
  key_name                    = module.keypair.key_name
  name                        = "aws_prod_app"
  subnet_id                   = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids      = ["sg-ffffffff"]
  # Optional: enable detailed monitoring for 1-min metric resolution (~$2.10/month/instance)
  enable_detailed_monitoring = true  # Default: false (basic monitoring, free)
  tags = {
    terraform   = "true"
    created_by  = "YOUR NAME"
    environment = "prod"
    role        = "app"
  }
}
```

### EC2 Instance With Second Attached EBS Volume

```
module "app_server" {
    source                 = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance"

    name                   = "app_server"
    ami                    = "ami-ffffffff"
    count                  = 1
    availability_zone      = module.vpc.availability_zone[0]
    subnet_id              = module.vpc.private_subnet_ids[0]
    instance_type          = "t2.large"
    key_name               = module.keypair.key_name
    vpc_security_group_ids = module.app_server_sg.id
    root_volume_size       = "100"
    tags                   = {
        terraform   = "true"
        created_by  = "terraform"
        environment = "prod"
        role        = "app_server"
        backup      = "true"
    }
}

module "app_server_d_drive" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/ebs_volume"

    availability_zone   = module.vpc.availability_zone[0]
    size                = "50"
    device_name         = "xvdb"
    instance_id         = module.app_server.id[0]
    tags                = {
        Name        = "app_server"
        os_drive    = "d"
        device_name = "xvdb"
        terraform   = "true"
        created_by  = "terraform"
        environment = "prod"
        role        = "app_server"
        backup      = "true"
    }
}
```

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.0.0 |

## Providers

| Name                                             | Version  |
| ------------------------------------------------ | -------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                        | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_metric_alarm.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource    |
| [aws_cloudwatch_metric_alarm.system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)   | resource    |
| [aws_instance.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)                                    | resource    |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                 | data source |

## Inputs

| Name                                                                                                                                          | Description                                                                                                                                                                                                                                                                                                                                                            | Type           | Default      | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------ | :------: |
| <a name="input_ami"></a> [ami](#input_ami)                                                                                                    | (Optional) AMI to use for the instance. Required unless launch_template is specified and the Launch Template specifes an AMI. If an AMI is specified in the Launch Template, setting ami will override the AMI specified in the Launch Template.                                                                                                                       | `string`       | n/a          |   yes    |
| <a name="input_associate_public_ip_address"></a> [associate_public_ip_address](#input_associate_public_ip_address)                            | If true, the EC2 instance will have associated public IP address                                                                                                                                                                                                                                                                                                       | `bool`         | `false`      |    no    |
| <a name="input_auto_recovery"></a> [auto_recovery](#input_auto_recovery)                                                                      | (Optional) Whether the instance is protected from auto recovery by Auto Recovery from User Space (ARU) feature. Can be 'default' or 'disabled'. Defaults to default. See Auto Recovery from User Space for more information. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-auto-recovery.html                                                           | `string`       | `"default"`  |    no    |
| <a name="input_availability_zone"></a> [availability_zone](#input_availability_zone)                                                          | The AZ to start the instance in                                                                                                                                                                                                                                                                                                                                        | `string`       | `""`         |    no    |
| <a name="input_disable_api_termination"></a> [disable_api_termination](#input_disable_api_termination)                                        | If true, enables EC2 Instance Termination Protection                                                                                                                                                                                                                                                                                                                   | `bool`         | `false`      |    no    |
| <a name="input_ebs_optimized"></a> [ebs_optimized](#input_ebs_optimized)                                                                      | If true, the launched EC2 instance will be EBS-optimized                                                                                                                                                                                                                                                                                                               | `bool`         | `false`      |    no    |
| <a name="input_encrypted"></a> [encrypted](#input_encrypted)                                                                                  | (Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection.                                                                                                                                                                                                                                                                  | `bool`         | `true`       |    no    |
| <a name="input_http_endpoint"></a> [http_endpoint](#input_http_endpoint)                                                                      | (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled.                                                                                                                                                                                                                                                   | `string`       | `"enabled"`  |    no    |
| <a name="input_http_tokens"></a> [http_tokens](#input_http_tokens)                                                                            | (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional, which accepts both IMDSv1 and IMDSv2 calls. Set to required to enforce IMDSv2.                                                                              | `string`       | `"optional"` |    no    |
| <a name="input_iam_instance_profile"></a> [iam_instance_profile](#input_iam_instance_profile)                                                 | (Optional) IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. Ensure your credentials have the correct permission to assign the instance profile according to the EC2 documentation, notably iam:PassRole.                                                                                                               | `string`       | `null`       |    no    |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance_initiated_shutdown_behavior](#input_instance_initiated_shutdown_behavior) | (Optional) Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances. See Shutdown Behavior for more information. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior | `string`       | `"stop"`     |    no    |
| <a name="input_instance_type"></a> [instance_type](#input_instance_type)                                                                      | The AWS instance type to utilize for the specifications of the instance                                                                                                                                                                                                                                                                                                | `string`       | n/a          |   yes    |
| <a name="input_ipv6_addresses"></a> [ipv6_addresses](#input_ipv6_addresses)                                                                   | Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface                                                                                                                                                                                                                                                        | `list(string)` | `[]`         |    no    |
| <a name="input_key_name"></a> [key_name](#input_key_name)                                                                                     | The key name to use for the instance                                                                                                                                                                                                                                                                                                                                   | `string`       | `""`         |    no    |
| <a name="input_monitoring"></a> [monitoring](#input_monitoring)                                                                               | If true, the launched EC2 instance will have detailed monitoring enabled                                                                                                                                                                                                                                                                                               | `bool`         | `false`      |    no    |
| <a name="input_name"></a> [name](#input_name)                                                                                                 | Name to be used on all resources as prefix                                                                                                                                                                                                                                                                                                                             | `string`       | n/a          |   yes    |
| <a name="input_number"></a> [number](#input_number)                                                                                           | Number of instances to launch                                                                                                                                                                                                                                                                                                                                          | `number`       | `1`          |    no    |
| <a name="input_placement_group"></a> [placement_group](#input_placement_group)                                                                | The Placement Group to start the instance in                                                                                                                                                                                                                                                                                                                           | `string`       | `""`         |    no    |
| <a name="input_private_ip"></a> [private_ip](#input_private_ip)                                                                               | Private IP address to associate with the instance in a VPC                                                                                                                                                                                                                                                                                                             | `string`       | `null`       |    no    |
| <a name="input_root_delete_on_termination"></a> [root_delete_on_termination](#input_root_delete_on_termination)                               | (Optional) Whether the volume should be destroyed on instance termination (Default: true)                                                                                                                                                                                                                                                                              | `bool`         | `true`       |    no    |
| <a name="input_root_volume_iops"></a> [root_volume_iops](#input_root_volume_iops)                                                             | IOPS for the root volume of the EC2 instance.                                                                                                                                                                                                                                                                                                                          | `number`       | `3000`       |    no    |
| <a name="input_root_volume_size"></a> [root_volume_size](#input_root_volume_size)                                                             | (Optional) The size of the volume in gigabytes.                                                                                                                                                                                                                                                                                                                        | `string`       | `"100"`      |    no    |
| <a name="input_root_volume_throughput"></a> [root_volume_throughput](#input_root_volume_throughput)                                           | Throughput for the root volume of the EC2 instance.                                                                                                                                                                                                                                                                                                                    | `number`       | `125`        |    no    |
| <a name="input_root_volume_type"></a> [root_volume_type](#input_root_volume_type)                                                             | (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp3.                                                                                                                                                                                                                                                            | `string`       | `"gp3"`      |    no    |
| <a name="input_source_dest_check"></a> [source_dest_check](#input_source_dest_check)                                                          | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs.                                                                                                                                                                                                                                          | `bool`         | `true`       |    no    |
| <a name="input_subnet_id"></a> [subnet_id](#input_subnet_id)                                                                                  | The VPC Subnet ID to launch in                                                                                                                                                                                                                                                                                                                                         | `string`       | `""`         |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                                 | A mapping of tags to assign to the resource                                                                                                                                                                                                                                                                                                                            | `map(string)`  | `{}`         |    no    |
| <a name="input_tenancy"></a> [tenancy](#input_tenancy)                                                                                        | The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host.                                                                                                                                                                                                                                                         | `string`       | `"default"`  |    no    |
| <a name="input_user_data"></a> [user_data](#input_user_data)                                                                                  | The user data to provide when launching the instance                                                                                                                                                                                                                                                                                                                   | `string`       | `""`         |    no    |
| <a name="input_vpc_security_group_ids"></a> [vpc_security_group_ids](#input_vpc_security_group_ids)                                           | A list of security group IDs to associate with                                                                                                                                                                                                                                                                                                                         | `list(any)`    | n/a          |   yes    |

## Outputs

| Name                                                                                                                    | Description                                                                                                                                                  |
| ----------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| <a name="output_availability_zone"></a> [availability_zone](#output_availability_zone)                                  | List of availability zones of instances                                                                                                                      |
| <a name="output_id"></a> [id](#output_id)                                                                               | List of IDs of instances                                                                                                                                     |
| <a name="output_key_name"></a> [key_name](#output_key_name)                                                             | List of key names of instances                                                                                                                               |
| <a name="output_primary_network_interface_id"></a> [primary_network_interface_id](#output_primary_network_interface_id) | List of IDs of the primary network interface of instances                                                                                                    |
| <a name="output_private_dns"></a> [private_dns](#output_private_dns)                                                    | List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC |
| <a name="output_private_ip"></a> [private_ip](#output_private_ip)                                                       | List of private IP addresses assigned to the instances                                                                                                       |
| <a name="output_public_dns"></a> [public_dns](#output_public_dns)                                                       | List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC                         |
| <a name="output_public_ip"></a> [public_ip](#output_public_ip)                                                          | List of public IP addresses assigned to the instances, if applicable                                                                                         |
| <a name="output_security_groups"></a> [security_groups](#output_security_groups)                                        | List of associated security groups of instances                                                                                                              |
| <a name="output_subnet_id"></a> [subnet_id](#output_subnet_id)                                                          | List of IDs of VPC subnets of instances                                                                                                                      |
| <a name="output_vpc_security_group_ids"></a> [vpc_security_group_ids](#output_vpc_security_group_ids)                   | List of associated security groups of instances, if running in non-default VPC                                                                               |

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

- [Zachary Hill](https://zacharyhill.co)
- [Jake Jones](https://github.com/jakeasarus)

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
