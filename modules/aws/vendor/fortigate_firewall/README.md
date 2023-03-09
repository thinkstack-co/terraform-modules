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

<h3 align="center">module_name</h3>
  <p align="center">
    module_description
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

```
module "aws_ec2_fortigate_fw" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/fortigate_firewall"

    vpc_id               = module.vpc.vpc_id
    number_of_instances  = 2
    public_subnet_id     = module.vpc.public_subnet_ids
    private_subnet_id    = module.vpc.private_subnet_ids
    ami_id               = "ami-ffffffff"
    instance_type        = "m3.medium"
    key_name             = module.keypair.key_name
    instance_name_prefix = "aws_fw"

    tags = {
        terraform         = "true"
        created_by        = "YOUR NAME"
        environment       = "prod"
        project           = "core_infrastructure"
        role              = "fortigate_firewall"
        backup            = "true"
        hourly_retention  = "7"
        daily_retention   = "14"
        monthly_retention = "60"
    }
}
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

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_eip.external_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.fw_external_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.fw_dmz_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.fw_private_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.fw_public_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_security_group.fortigate_fw_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI to use | `string` | n/a | yes |
| <a name="input_dmz_nic_description"></a> [dmz\_nic\_description](#input\_dmz\_nic\_description) | Description of the dmz network interface | `string` | `"Fortigate FW DMZ nic"` | no |
| <a name="input_dmz_private_ips"></a> [dmz\_private\_ips](#input\_dmz\_private\_ips) | (Optional) List of private IPs to assign to the ENI. | `list(string)` | <pre>[<br>  "10.11.101.10",<br>  "10.11.102.10"<br>]</pre> | no |
| <a name="input_dmz_subnet_id"></a> [dmz\_subnet\_id](#input\_dmz\_subnet\_id) | The VPC subnet the instance(s) will be assigned. Set in main.tf | `list(any)` | n/a | yes |
| <a name="input_ebs_device_name"></a> [ebs\_device\_name](#input\_ebs\_device\_name) | ebs volume mount name | `string` | `"/dev/sdb"` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| <a name="input_ebs_volume_encrypted"></a> [ebs\_volume\_encrypted](#input\_ebs\_volume\_encrypted) | Boolean whether or not the ebs volume is encrypted | `bool` | `true` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | ebs volume disk size | `number` | `30` | no |
| <a name="input_ebs_volume_type"></a> [ebs\_volume\_type](#input\_ebs\_volume\_type) | ebs volume type | `string` | `"gp3"` | no |
| <a name="input_enable_dmz"></a> [enable\_dmz](#input\_enable\_dmz) | describe your variable | `bool` | `true` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | (Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection. | `bool` | `true` | no |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled. | `string` | `"enabled"` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional. | `string` | `"required"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | `string` | `""` | no |
| <a name="input_instance_name_prefix"></a> [instance\_name\_prefix](#input\_instance\_name\_prefix) | Used to populate the Name tag. Set in main.tf | `string` | `"aws_fw"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Select the instance type. Set in main.tf | `string` | `"c5.large"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | keypair name to use for ec2 instance deployment. Keypairs are used to obtain the username/password | `string` | n/a | yes |
| <a name="input_lan_private_ips"></a> [lan\_private\_ips](#input\_lan\_private\_ips) | (Optional) List of private IPs to assign to the ENI. | `list(string)` | <pre>[<br>  "10.11.1.10",<br>  "10.11.2.10"<br>]</pre> | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `true` | no |
| <a name="input_number"></a> [number](#input\_number) | number of resources to make | `number` | `2` | no |
| <a name="input_private_nic_description"></a> [private\_nic\_description](#input\_private\_nic\_description) | Description of the private network interface | `string` | `"Fortigate FW private nic"` | no |
| <a name="input_private_subnet_id"></a> [private\_subnet\_id](#input\_private\_subnet\_id) | The VPC subnet the instance(s) will be assigned. Set in main.tf | `list(any)` | n/a | yes |
| <a name="input_public_nic_description"></a> [public\_nic\_description](#input\_public\_nic\_description) | Description of the public network interface | `string` | `"Fortigate FW public nic"` | no |
| <a name="input_public_subnet_id"></a> [public\_subnet\_id](#input\_public\_subnet\_id) | The VPC subnet the instance(s) will be assigned. Set in main.tf | `list(any)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Required) VPC Region the resources exist in | `string` | n/a | yes |
| <a name="input_root_delete_on_termination"></a> [root\_delete\_on\_termination](#input\_root\_delete\_on\_termination) | (Optional) Whether the volume should be destroyed on instance termination (Default: true) | `bool` | `true` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | root volume disk size | `number` | `20` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp3. | `string` | `"gp3"` | no |
| <a name="input_sg_name"></a> [sg\_name](#input\_sg\_name) | Name of the security group | `string` | `"fortigate_fw_sg"` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | Boolean for source and destination checking on the nics | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br>  "created_by": "terraform",<br>  "environment": "dev",<br>  "role": "fortigate_firewall",<br>  "terraform": "yes"<br>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id to add the security group | `string` | n/a | yes |
| <a name="input_wan_private_ips"></a> [wan\_private\_ips](#input\_wan\_private\_ips) | (Optional) Private IP addresses to associate with the instance in a VPC. | `list(string)` | <pre>[<br>  "10.11.201.10",<br>  "10.11.202.10"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dmz_network_interface_id"></a> [dmz\_network\_interface\_id](#output\_dmz\_network\_interface\_id) | n/a |
| <a name="output_ec2_instance_id"></a> [ec2\_instance\_id](#output\_ec2\_instance\_id) | n/a |
| <a name="output_eip_id"></a> [eip\_id](#output\_eip\_id) | n/a |
| <a name="output_eip_private_ip"></a> [eip\_private\_ip](#output\_eip\_private\_ip) | n/a |
| <a name="output_eip_public_ip"></a> [eip\_public\_ip](#output\_eip\_public\_ip) | n/a |
| <a name="output_network_interface_id"></a> [network\_interface\_id](#output\_network\_interface\_id) | n/a |
| <a name="output_private_network_interface_id"></a> [private\_network\_interface\_id](#output\_private\_network\_interface\_id) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | n/a |
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