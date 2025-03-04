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
    <img src="https://raw.githubusercontent.com/thinkstack-co/terraform-modules/main/images/thinkstack_logo.png" alt="ThinkStack Logo" width="300" height="100">
  </a>

<h3 align="center">AWS EC2 Instance Module</h3>
  <p align="center">
    This module creates an EC2 instance with intelligent recovery capabilities and customizable settings.
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
    <li><a href="#modules">Modules</a></li>
    <li><a href="#Resources">Resources</a></li>
    <li><a href="#inputs">Inputs</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>


## Overview

This Terraform module creates and manages AWS EC2 instances with intelligent recovery capabilities. The module includes:

- EC2 instance with customizable settings
- CloudWatch alarms for instance and system status monitoring
- Intelligent auto-recovery configuration based on instance type support
- Customizable root volume settings
- Metadata options for IMDSv2 configuration

The module dynamically checks if an instance type supports auto-recovery and configures CloudWatch alarms accordingly, ensuring optimal resilience while avoiding errors with unsupported instance types. It also verifies the instance state, as recovery actions only work on running instances.

### Auto-Recovery Logic

The module implements comprehensive checks to determine if CloudWatch recovery actions should be enabled:

1. **Instance Type Compatibility**: Checks if the instance family is in the supported list based on AWS documentation
2. **Instance Store Volumes**: Verifies if instance store volumes are compatible with recovery actions
3. **Auto Scaling Group**: Detects if the instance is part of an ASG (which handles its own recovery)
4. **Tenancy Restrictions**: Checks for dedicated host tenancy which doesn't support recovery
5. **Network Interface Type**: Detects Elastic Fabric Adapter usage
6. **Instance State**: Ensures the instance is in a running state, as recovery actions only work on running instances
7. **Manual Override**: Allows explicit disabling of recovery actions

This intelligent approach prevents configuration errors and ensures recovery actions are only applied to supported instances in appropriate states.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic Example

```hcl
module "web_server" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance"

  ami                         = "ami-0c55b159cbfafe1f0"
  instance_type               = "t3.micro"
  name                        = "web-server"
  subnet_id                   = "subnet-0123456789abcdef0"
  vpc_security_group_ids      = ["sg-0123456789abcdef0"]
  key_name                    = "my-key-pair"
  associate_public_ip_address = true
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    role        = "web-server"
  }
}
```

### Example with Custom Root Volume and Disabled Recovery

```hcl
module "database_server" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance"

  ami                         = "ami-0c55b159cbfafe1f0"
  instance_type               = "r5.large"
  name                        = "db-server"
  subnet_id                   = "subnet-0123456789abcdef0"
  vpc_security_group_ids      = ["sg-0123456789abcdef0"]
  key_name                    = "my-key-pair"
  
  # Root volume configuration
  root_volume_size            = 100
  root_volume_type            = "gp3"
  root_volume_iops            = 3000
  root_volume_throughput      = 125
  encrypted                   = true
  
  # Disable recovery actions
  disable_recovery_actions    = true
  auto_recovery               = "disabled"
  
  # Enhanced metadata options
  http_endpoint               = "enabled"
  http_tokens                 = "required"
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    role        = "database"
  }
}
```

### Example with Recovery Support Diagnostic Output

```hcl
module "app_server" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance"

  ami                         = "ami-0c55b159cbfafe1f0"
  instance_type               = "m5.large"
  name                        = "app-server"
  subnet_id                   = "subnet-0123456789abcdef0"
  vpc_security_group_ids      = ["sg-0123456789abcdef0"]
  key_name                    = "my-key-pair"
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    role        = "application"
  }
}

# After applying, you can check recovery support information
output "app_server_recovery_info" {
  description = "Diagnostic information about recovery support for the app server"
  value       = module.app_server.recovery_support_info
}

# Example output will include:
# {
#   instance_family = "m5"
#   is_supported_instance_family = true
#   has_instance_store_volumes = false
#   is_instance_running = true
#   instance_state = "running"
#   is_in_asg = false
#   uses_efa = false
#   is_on_dedicated_host = false
#   recovery_disabled_by_user = false
#   recovery_supported = true
# }
```

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type | Documentation |
|------|------|---------------|
| [aws_instance.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource | [AWS Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Instances.html) |
| [aws_cloudwatch_metric_alarm.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource | [AWS Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html) |
| [aws_cloudwatch_metric_alarm.system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource | [AWS Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html) |
| [aws_ec2_instance_type.instance_type_info](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type) | data source | [AWS Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html) |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source | [AWS Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source | [AWS Documentation](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional resource tags | `map(string)` | `{}` | no |
| <a name="input_additional_unsupported_instance_types"></a> [additional\_unsupported\_instance\_types](#input\_additional\_unsupported\_instance\_types) | List of additional instance types that don't support CloudWatch recovery actions | `list(string)` | `[]` | no |
| <a name="input_ami"></a> [ami](#input\_ami) | ID of AMI to use for the instance | `string` | n/a | yes |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | If true, the EC2 instance will have associated public IP address | `bool` | `false` | no |
| <a name="input_auto_recovery"></a> [auto\_recovery](#input\_auto\_recovery) | Whether the instance is protected from auto recovery by Auto Recovery from User Space (ARU) feature | `string` | `"default"` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The AZ to start the instance in | `string` | `""` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_disable_recovery_actions"></a> [disable\_recovery\_actions](#input\_disable\_recovery\_actions) | If true, disables CloudWatch alarm recovery actions regardless of instance type | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | Enable volume encryption | `bool` | `true` | no |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | Whether the metadata service is available | `string` | `"enabled"` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | Whether or not the metadata service requires session tokens (IMDSv2) | `string` | `"required"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM Instance Profile to launch the instance with | `string` | `null` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the instance | `string` | `"stop"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The AWS instance type to utilize for the specifications of the instance | `string` | n/a | yes |
| <a name="input_ipv6_addresses"></a> [ipv6\_addresses](#input\_ipv6\_addresses) | Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface | `list(string)` | `[]` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The key name to use for the instance | `string` | `""` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on EC2 instance created | `string` | n/a | yes |
| <a name="input_number"></a> [number](#input\_number) | Number of instances to launch | `number` | `1` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | The Placement Group to start the instance in | `string` | `""` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address to associate with the instance in a VPC | `string` | `null` | no |
| <a name="input_root_delete_on_termination"></a> [root\_delete\_on\_termination](#input\_root\_delete\_on\_termination) | Whether the volume should be destroyed on instance termination (Default: true) | `bool` | `true` | no |
| <a name="input_root_volume_iops"></a> [root\_volume\_iops](#input\_root\_volume\_iops) | IOPS for the root volume of the EC2 instance | `number` | `3000` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | The size of the volume in gigabytes | `string` | `"100"` | no |
| <a name="input_root_volume_throughput"></a> [root\_volume\_throughput](#input\_root\_volume\_throughput) | Throughput for the root volume of the EC2 instance | `number` | `125` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | Type of volume | `string` | `"gp3"` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | Controls if traffic is routed to the instance when the destination address does not match the instance | `bool` | `true` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The VPC Subnet ID to launch in | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The tenancy of the instance (if the instance is running in a VPC) | `string` | `"default"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the instance | `string` | `""` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | A list of security group IDs to associate with | `list(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | List of availability zones of instances |
| <a name="output_id"></a> [id](#output\_id) | List of IDs of instances |
| <a name="output_key_name"></a> [key\_name](#output\_key\_name) | List of key names of instances |
| <a name="output_primary_network_interface_id"></a> [primary\_network\_interface\_id](#output\_primary\_network\_interface\_id) | List of IDs of the primary network interface of instances |
| <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns) | List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | List of private IP addresses assigned to the instances |
| <a name="output_public_dns"></a> [public\_dns](#output\_public\_dns) | List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | List of public IP addresses assigned to the instances, if applicable |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | List of associated security groups of instances |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | List of IDs of VPC subnets of instances |
| <a name="output_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#output\_vpc\_security\_group\_ids) | List of associated security groups of instances, if running in non-default VPC |
| <a name="output_recovery_support_info"></a> [recovery\_support\_info](#output\_recovery\_support\_info) | Diagnostic information about CloudWatch recovery action support for this instance, including instance state |
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