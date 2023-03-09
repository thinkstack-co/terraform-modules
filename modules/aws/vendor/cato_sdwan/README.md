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

<h3 align="center">Cato SDWAN Module</h3>
  <p align="center">
    This module deploys a Cato SDWAN into your environment.
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
module "aws_prod_cato" {
    source               = "github.com/thinkstack-co/terraform-modules//modules/aws/cato_sdwan"

    ami                  = "ami-0xx6edxxaf4xxdf1e"
    availability_zone    = [module.vpc.availability_zone[0]]
    cato_lan_cidr_blocks = ["10.11.0.0/16"]
    key_name             = module.keypair.key_name
    instance_type        = "c5.large"
    mgmt_subnet_id       = module.vpc.mgmt_subnet_ids
    public_subnet_id     = module.vpc.public_subnet_ids
    private_subnet_id    = module.vpc.private_subnet_ids
    mgmt_ips             = ["10.200.61.12"]
    public_ips           = ["10.200.201.12"]
    private_ips          = ["10.200.1.12"]
    vpc_id               = module.vpc.vpc_id
    user_data            = file("./global/user_data/cato_sdwan_serial.txt")

    tags                 = {
        terraform   = "true"
        created_by  = "Zachary Hill"
        environment = "prod"
        project     = "aws_poc"
        backup      = "true"
        role        = "cato_sdwan"
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
| [aws_eip.wan_external_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.wan_external_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.mgmt_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.private_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.public_nic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_security_group.cato_lan_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.cato_wan_mgmt_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | (Required) AMI to use for the instance. Required unless launch\_template is specified and the Launch Template specifes an AMI. If an AMI is specified in the Launch Template, setting ami will override the AMI specified in the Launch Template. | `string` | n/a | yes |
| <a name="input_cato_lan_cidr_blocks"></a> [cato\_lan\_cidr\_blocks](#input\_cato\_lan\_cidr\_blocks) | (Optional) List of CIDR blocks allowed to utilize the Cato instance for SDWAN communication. | `list(string)` | `null` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | (Optional) If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. See the EBS Optimized section of the AWS User Guide for more information. | `bool` | `true` | no |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled. | `string` | `"enabled"` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional. | `string` | `"required"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | (Optional) IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. Ensure your credentials have the correct permission to assign the instance profile according to the EC2 documentation, notably iam:PassRole. | `string` | `null` | no |
| <a name="input_instance_name_prefix"></a> [instance\_name\_prefix](#input\_instance\_name\_prefix) | (Optional) Used to populate the Name tag. | `string` | `"aws_prod_cato"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | (Optional) Instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance. | `string` | `"c5.xlarge"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | (Required) Key name of the Key Pair to use for the instance; which can be managed using the aws\_key\_pair resource. | `string` | n/a | yes |
| <a name="input_lan_sg_name"></a> [lan\_sg\_name](#input\_lan\_sg\_name) | (Optional, Forces new resource) Name of the security group. If omitted, Terraform will assign a random, unique name. | `string` | `"cato_lan_sg"` | no |
| <a name="input_mgmt_ips"></a> [mgmt\_ips](#input\_mgmt\_ips) | (Optional) List of private IPs to assign to the ENI. | `list(string)` | <pre>[<br>  "10.11.61.12",<br>  "10.11.62.12",<br>  "10.11.63.12"<br>]</pre> | no |
| <a name="input_mgmt_nic_description"></a> [mgmt\_nic\_description](#input\_mgmt\_nic\_description) | (Optional) Description for the network interface. | `string` | `"Cato mgmt nic"` | no |
| <a name="input_mgmt_subnet_id"></a> [mgmt\_subnet\_id](#input\_mgmt\_subnet\_id) | (Required) Subnet ID to create the ENI in. | `list(string)` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | (Optional) If true, the launched EC2 instance will have detailed monitoring enabled. (Available since v0.6.0) | `bool` | `true` | no |
| <a name="input_number"></a> [number](#input\_number) | (Optional) Quantity of resources to make with this module. Example: Setting this to 2 will create 2 of all the required resources. Default: 1 | `number` | `1` | no |
| <a name="input_private_ips"></a> [private\_ips](#input\_private\_ips) | (Optional) List of private IPs to assign to the ENI. | `list(string)` | <pre>[<br>  "10.11.1.12",<br>  "10.11.2.12",<br>  "10.11.3.12"<br>]</pre> | no |
| <a name="input_private_nic_description"></a> [private\_nic\_description](#input\_private\_nic\_description) | (Optional) Description for the network interface. | `string` | `"Cato private nic"` | no |
| <a name="input_private_subnet_id"></a> [private\_subnet\_id](#input\_private\_subnet\_id) | (Required) Subnet ID to create the ENI in. | `list(string)` | n/a | yes |
| <a name="input_public_ips"></a> [public\_ips](#input\_public\_ips) | (Optional) Private IP addresses to associate with the instance in a VPC. | `list(string)` | <pre>[<br>  "10.11.201.12",<br>  "10.11.202.12",<br>  "10.11.203.12"<br>]</pre> | no |
| <a name="input_public_nic_description"></a> [public\_nic\_description](#input\_public\_nic\_description) | (Optional) Description for the network interface. | `string` | `"Cato public nic"` | no |
| <a name="input_public_subnet_id"></a> [public\_subnet\_id](#input\_public\_subnet\_id) | (Required) Subnet ID to create the ENI in. | `list(string)` | n/a | yes |
| <a name="input_root_ebs_volume_encrypted"></a> [root\_ebs\_volume\_encrypted](#input\_root\_ebs\_volume\_encrypted) | (Optional) Whether to enable volume encryption on the root ebs volume. Defaults to true. Must be configured to perform drift detection. | `bool` | `true` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | (Optional) Size of the root volume in gibibytes (GiB). | `number` | `16` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | (Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp3 | `string` | `"gp3"` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | (Optional) Whether to enable source destination checking for the ENI. Default false. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of tags to assign to the device. | `map(any)` | <pre>{<br>  "created_by": "terraform",<br>  "environment": "prod",<br>  "role": "cato_sdwan",<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | (Optional) User data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user\_data\_base64 instead. Updates to this field will trigger a stop/start of the EC2 instance by default. If the user\_data\_replace\_on\_change is set then updates to this field will trigger a destroy and recreate. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required, Forces new resource) VPC ID. Defaults to the region's default VPC. | `string` | n/a | yes |
| <a name="input_wan_mgmt_sg_name"></a> [wan\_mgmt\_sg\_name](#input\_wan\_mgmt\_sg\_name) | (Optional, Forces new resource) Name of the security group. If omitted, Terraform will assign a random, unique name. | `string` | `"cato_wan_mgmt_sg"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_instance_id"></a> [ec2\_instance\_id](#output\_ec2\_instance\_id) | n/a |
| <a name="output_eip_id"></a> [eip\_id](#output\_eip\_id) | n/a |
| <a name="output_eip_public_ip"></a> [eip\_public\_ip](#output\_eip\_public\_ip) | n/a |
| <a name="output_mgmt_network_interface_id"></a> [mgmt\_network\_interface\_id](#output\_mgmt\_network\_interface\_id) | n/a |
| <a name="output_private_network_interface_id"></a> [private\_network\_interface\_id](#output\_private\_network\_interface\_id) | n/a |
| <a name="output_public_network_interface_id"></a> [public\_network\_interface\_id](#output\_public\_network\_interface\_id) | n/a |
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