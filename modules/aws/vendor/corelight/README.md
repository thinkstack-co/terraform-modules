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

<h3 align="center">Corelight Collector</h3>
  <p align="center">
    Utilized to deploy a corelight collector
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

### Interfaces

- eth0 - Collecto listener. Send VPC Mirror traffic to this interface
- eth1 - Management

```
module "aws_prod_corelight" {
      source              = "github.com/thinkstack-co/terraform-modules//modules/aws/corelight"

      ami                 = "ami-b7f895cffdsaaafdsa"
      availability_zones  = [module.vpc.availability_zone[0], module.vpc.availability_zone[1]]
      number              = 2
      listener_subnet_ids = module.vpc.private_subnet_ids
      mgmt_subnet_ids     = module.vpc.mgmt_subnet_ids
      name                = "aws_prod_corelight"
      region              = var.aws_region
      user_data           = "customer_id_key"
      vpc_id              = "vpc-222222222"
      vxlan_cidr_blocks   = ["10.44.1.1/32"]

      tags                = {
        terraform        = "true"
        created_by       = "Zachary Hill"
        environment      = "prod"
        role             = "corelight network monitor"
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

| Name                                                                                                                                        | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudwatch_metric_alarm.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)   | resource |
| [aws_instance.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)                                    | resource |
| [aws_lb.corelight_nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)                                      | resource |
| [aws_network_interface.listener_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface)         | resource |
| [aws_network_interface.mgmt_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface)             | resource |
| [aws_security_group.corelight_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)               | resource |

## Inputs

| Name                                                                                                                                          | Description                                                                                                                                                                                                                                                                                                                                                            | Type           | Default                                                                                                                                                            | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :------: |
| <a name="input_ami"></a> [ami](#input_ami)                                                                                                    | (Required) AMI ID to use when launching the instance                                                                                                                                                                                                                                                                                                                   | `string`       | n/a                                                                                                                                                                |   yes    |
| <a name="input_availability_zones"></a> [availability_zones](#input_availability_zones)                                                       | (Required) The AZ to start the instance in                                                                                                                                                                                                                                                                                                                             | `list(string)` | n/a                                                                                                                                                                |   yes    |
| <a name="input_disable_api_termination"></a> [disable_api_termination](#input_disable_api_termination)                                        | (Optional) If true, enables EC2 Instance Termination Protection                                                                                                                                                                                                                                                                                                        | `bool`         | `false`                                                                                                                                                            |    no    |
| <a name="input_ebs_optimized"></a> [ebs_optimized](#input_ebs_optimized)                                                                      | (Optional) If true, the launched EC2 instance will be EBS-optimized                                                                                                                                                                                                                                                                                                    | `bool`         | `false`                                                                                                                                                            |    no    |
| <a name="input_enable_deletion_protection"></a> [enable_deletion_protection](#input_enable_deletion_protection)                               | (Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false.                                                                                                                                                                                                    | `bool`         | `false`                                                                                                                                                            |    no    |
| <a name="input_encrypted"></a> [encrypted](#input_encrypted)                                                                                  | (Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection.                                                                                                                                                                                                                                                                  | `bool`         | `true`                                                                                                                                                             |    no    |
| <a name="input_http_endpoint"></a> [http_endpoint](#input_http_endpoint)                                                                      | (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled.                                                                                                                                                                                                                                                   | `string`       | `"enabled"`                                                                                                                                                        |    no    |
| <a name="input_http_tokens"></a> [http_tokens](#input_http_tokens)                                                                            | (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional.                                                                                                                                                             | `string`       | `"required"`                                                                                                                                                       |    no    |
| <a name="input_iam_instance_profile"></a> [iam_instance_profile](#input_iam_instance_profile)                                                 | (Optional) The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile.                                                                                                                                                                                                                                                        | `string`       | `""`                                                                                                                                                               |    no    |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance_initiated_shutdown_behavior](#input_instance_initiated_shutdown_behavior) | (Optional) Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances. See Shutdown Behavior for more information. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior | `string`       | `"stop"`                                                                                                                                                           |    no    |
| <a name="input_instance_type"></a> [instance_type](#input_instance_type)                                                                      | (Optional) The AWS instance type to utilize for the specifications of the instance                                                                                                                                                                                                                                                                                     | `string`       | `"m5.xlarge"`                                                                                                                                                      |    no    |
| <a name="input_internal"></a> [internal](#input_internal)                                                                                     | (Optional) If true, the LB will be internal.                                                                                                                                                                                                                                                                                                                           | `bool`         | `true`                                                                                                                                                             |    no    |
| <a name="input_key_name"></a> [key_name](#input_key_name)                                                                                     | (Optional) The key name to use for the instance                                                                                                                                                                                                                                                                                                                        | `string`       | `""`                                                                                                                                                               |    no    |
| <a name="input_listener_nic_description"></a> [listener_nic_description](#input_listener_nic_description)                                     | (Optional) A description for the network interface.                                                                                                                                                                                                                                                                                                                    | `string`       | `"Corelight listener nic"`                                                                                                                                         |    no    |
| <a name="input_listener_subnet_ids"></a> [listener_subnet_ids](#input_listener_subnet_ids)                                                    | (Required) The VPC Subnet ID to launch in                                                                                                                                                                                                                                                                                                                              | `list(any)`    | n/a                                                                                                                                                                |   yes    |
| <a name="input_mgmt_cidr_blocks"></a> [mgmt_cidr_blocks](#input_mgmt_cidr_blocks)                                                             | (Optional) List of IP addresses and cidr blocks which are allowed to access SSH and HTTPS to this instance                                                                                                                                                                                                                                                             | `list(any)`    | `[]`                                                                                                                                                               |    no    |
| <a name="input_mgmt_nic_description"></a> [mgmt_nic_description](#input_mgmt_nic_description)                                                 | (Optional) A description for the network interface.                                                                                                                                                                                                                                                                                                                    | `string`       | `"Corelight mgmt nic"`                                                                                                                                             |    no    |
| <a name="input_mgmt_subnet_ids"></a> [mgmt_subnet_ids](#input_mgmt_subnet_ids)                                                                | (Required) The VPC Subnet ID for the mgmt nic                                                                                                                                                                                                                                                                                                                          | `list(any)`    | n/a                                                                                                                                                                |   yes    |
| <a name="input_monitoring"></a> [monitoring](#input_monitoring)                                                                               | (Optional) If true, the launched EC2 instance will have detailed monitoring enabled                                                                                                                                                                                                                                                                                    | `bool`         | `false`                                                                                                                                                            |    no    |
| <a name="input_name"></a> [name](#input_name)                                                                                                 | (Optional) Name to be used on all resources as a prefix for tags and names                                                                                                                                                                                                                                                                                             | `string`       | `"aws_prod_corelight"`                                                                                                                                             |    no    |
| <a name="input_nlb_name"></a> [nlb_name](#input_nlb_name)                                                                                     | (Optional) The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb.                                                                        | `string`       | `"aws-prod-corelight-nlb"`                                                                                                                                         |    no    |
| <a name="input_number"></a> [number](#input_number)                                                                                           | (Optional) Number of instances and resources to launch                                                                                                                                                                                                                                                                                                                 | `number`       | `1`                                                                                                                                                                |    no    |
| <a name="input_placement_group"></a> [placement_group](#input_placement_group)                                                                | (Optional) The Placement Group to start the instance in                                                                                                                                                                                                                                                                                                                | `string`       | `""`                                                                                                                                                               |    no    |
| <a name="input_region"></a> [region](#input_region)                                                                                           | (Required) VPC Region the resources exist in                                                                                                                                                                                                                                                                                                                           | `string`       | n/a                                                                                                                                                                |   yes    |
| <a name="input_root_delete_on_termination"></a> [root_delete_on_termination](#input_root_delete_on_termination)                               | (Optional) Whether the volume should be destroyed on instance termination (Default: true)                                                                                                                                                                                                                                                                              | `string`       | `true`                                                                                                                                                             |    no    |
| <a name="input_root_volume_size"></a> [root_volume_size](#input_root_volume_size)                                                             | (Optional) The size of the volume in gigabytes.                                                                                                                                                                                                                                                                                                                        | `string`       | `"64"`                                                                                                                                                             |    no    |
| <a name="input_root_volume_type"></a> [root_volume_type](#input_root_volume_type)                                                             | (Optional) The type of volume. Can be standard, gp2, or io1. (Default: standard)                                                                                                                                                                                                                                                                                       | `string`       | `"gp2"`                                                                                                                                                            |    no    |
| <a name="input_sg_description"></a> [sg_description](#input_sg_description)                                                                   | (Optional, Forces new resource) The security group description. Defaults to 'Managed by Terraform'. Cannot be ''. NOTE: This field maps to the AWS GroupDescription attribute, for which there is no Update API. If you'd like to classify your security groups in a way that can be updated, use tags.                                                                | `string`       | `"Corelight security group"`                                                                                                                                       |    no    |
| <a name="input_sg_name"></a> [sg_name](#input_sg_name)                                                                                        | (Optional, Forces new resource) The name of the security group. If omitted, Terraform will assign a random, unique name                                                                                                                                                                                                                                                | `string`       | `"corelight_sg"`                                                                                                                                                   |    no    |
| <a name="input_source_dest_check"></a> [source_dest_check](#input_source_dest_check)                                                          | (Optional) Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs.                                                                                                                                                                                                                               | `bool`         | `false`                                                                                                                                                            |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                                 | (Optional) A mapping of tags to assign to the resource.                                                                                                                                                                                                                                                                                                                | `map(any)`     | <pre>{<br> "backup": "true",<br> "created_by": "terraform",<br> "environment": "prod",<br> "role": "corelight network monitor",<br> "terraform": "true"<br>}</pre> |    no    |
| <a name="input_tenancy"></a> [tenancy](#input_tenancy)                                                                                        | (Optional) The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host.                                                                                                                                                                                                                                              | `string`       | `"default"`                                                                                                                                                        |    no    |
| <a name="input_user_data"></a> [user_data](#input_user_data)                                                                                  | (Required) Input the Customer ID from Corelight. Example: '57ee000-1214-999e-hfij-1827417d7421'                                                                                                                                                                                                                                                                        | `string`       | n/a                                                                                                                                                                |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                                           | (Required, Forces new resource) The VPC ID.                                                                                                                                                                                                                                                                                                                            | `string`       | n/a                                                                                                                                                                |   yes    |
| <a name="input_vxlan_cidr_blocks"></a> [vxlan_cidr_blocks](#input_vxlan_cidr_blocks)                                                          | (Required) List of IP addresses and cidr blocks which are allowed to send VPC mirror traffic                                                                                                                                                                                                                                                                           | `list(any)`    | n/a                                                                                                                                                                |   yes    |

## Outputs

| Name                                                                                   | Description                                            |
| -------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| <a name="output_availability_zone"></a> [availability_zone](#output_availability_zone) | List of availability zones of instances                |
| <a name="output_id"></a> [id](#output_id)                                              | List of IDs of instances                               |
| <a name="output_private_ip"></a> [private_ip](#output_private_ip)                      | List of private IP addresses assigned to the instances |

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
