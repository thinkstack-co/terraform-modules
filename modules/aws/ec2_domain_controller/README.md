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

<h3 align="center">EC2 Domain Controller Module</h3>
  <p align="center">
    Creates an EC2 instance, status checks, and optional DHCP option sets.
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
### Simple Example
```
module "domain_controllers" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_domain_controller"

    vpc_id                 = module.vpc.vpc_id
    ami                    = lookup(var.aws_amis, var.aws_prod_region)
    name                   = "aws_prod_dc"
    subnet_id              = module.vpc.private_subnet_ids
    number                  = 2
    domain_name            = "example.local"
    vpc_security_group_ids = [module.domain_controller_sg.id]

    tags = {
        terraform         = "true"
        created_by        = "YOUR NAME"
        environment       = "prod"
        project           = "core_infrastructure"
        role              = "domain_controller"
        backup            = "true"
        ssm_update        = "true"
    }
}
```
### Complex Example
```
module "domain_controllers" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_domain_controller"

    vpc_id                 = module.vpc.vpc_id
    ami                    = lookup(var.aws_amis, var.aws_prod_region)
    encrypted              = true
    key_name               = module.keypair.key_name
    kms_key_id             = module.ec2_key.arn
    name                   = "aws_prod_dc"
    instance_type          = "t3a.large"
    subnet_id              = module.vpc.private_subnet_ids
    iam_instance_profile   = "ssm-service-role"
    number                  = 2
    domain_name            = "example.local"
    private_ip             = ["10.11.1.100", "10.11.2.100"]
    vpc_security_group_ids = [module.domain_controller_sg.id]

    tags = {
        terraform         = "true"
        created_by        = "YOUR NAME"
        environment       = "prod"
        project           = "core_infrastructure"
        role              = "domain_controller"
        backup            = "true"
        ssm_update        = "true"
    }
}
```

### Disable DHCP Options Group
```
module "aws_ec2_domain_controllers" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_domain_controller"

  vpc_id                 = module.vpc.vpc_id
  key_name               = module.keypair.key_name
  name                   = "aws-dc"
  instance_type          = "t3a.medium"
  subnet_id              = module.vpc.private_subnet_ids
  ami                    = "ami-ffffffff"
  count                  = 2
  domain_name            = "ad.yourdomain.com"
  vpc_security_group_ids = [module.domain_controller_sg.id]
  enable_dhcp_options    = false #can exclude argument if true, defaults to true.

  tags = {
    terraform         = "true"
    created_by        = "terraform"
    environment       = "prod"
    project           = "core_infrastructure"
    role              = "domain_controller"
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
| [aws_instance.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_vpc_dhcp_options.dc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.dc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | (Optional) AMI to use for the instance. Required unless launch\_template is specified and the Launch Template specifes an AMI. If an AMI is specified in the Launch Template, setting ami will override the AMI specified in the Launch Template. | `string` | n/a | yes |
| <a name="input_auto_recovery"></a> [auto\_recovery](#input\_auto\_recovery) | (Optional) Whether the instance is protected from auto recovery by Auto Recovery from User Space (ARU) feature. Can be 'default' or 'disabled'. Defaults to default. See Auto Recovery from User Space for more information. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-auto-recovery.html | `string` | `"default"` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | (Optional) If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | (Required) the suffix domain name to use by default when resolving non Fully Qualified Domain Names. In other words, this is what ends up being the search value in the /etc/resolv.conf file. | `string` | n/a | yes |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | (Optional) If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. See the EBS Optimized section of the AWS User Guide for more information. | `bool` | `false` | no |
| <a name="input_enable_dhcp_options"></a> [enable\_dhcp\_options](#input\_enable\_dhcp\_options) | (Optional) boolean to determine if DHCP options are enabled | `bool` | `true` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | (Optional) Enable volume encryption. (Default: true). Must be configured to perform drift detection. | `bool` | `true` | no |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled. | `string` | `"enabled"` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional. | `string` | `"required"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | (Optional) IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. Ensure your credentials have the correct permission to assign the instance profile according to the EC2 documentation, notably iam:PassRole. | `string` | `null` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | (Optional) Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances. See Shutdown Behavior for more information. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior | `string` | `"stop"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | (Optional) Instance type to use for the instance. Required unless launch\_template is specified and the Launch Template specifies an instance type. If an instance type is specified in the Launch Template, setting instance\_type will override the instance type specified in the Launch Template. Updates to this field will trigger a stop/start of the EC2 instance. | `string` | `"t3a.medium"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | (Optional) Key name of the Key Pair to use for the instance; which can be managed using the aws\_key\_pair resource. | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | (Optional) Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. Must be configured to perform drift detection. | `string` | `null` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | (Optional) If true, the launched EC2 instance will have detailed monitoring enabled. (Available since v0.6.0) | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the instance. Used in tags for resources. | `string` | n/a | yes |
| <a name="input_number"></a> [number](#input\_number) | (Optional) The number of instances and supporting resources to create. This allows high availability configurations. Default is 2. | `number` | `2` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | (Optional) Placement Group to start the instance in. | `string` | `null` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | (Required) Private IP address(es) to associate with the instance(s) in a VPC. | `list(string)` | n/a | yes |
| <a name="input_root_delete_on_termination"></a> [root\_delete\_on\_termination](#input\_root\_delete\_on\_termination) | (Optional) Whether the volume should be destroyed on instance termination. Defaults to true. | `string` | `true` | no |
| <a name="input_root_iops"></a> [root\_iops](#input\_root\_iops) | (Optional) Amount of provisioned IOPS. Only valid for volume\_type of io1, io2 or gp3. | `number` | `null` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | (Optional) The size of the volume in gigabytes. | `number` | `100` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | (Optional) The type of volume. Can be standard, gp2, gp3 or io1. (Default: standard) | `string` | `"gp3"` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | (Optional) Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. Defaults true. | `bool` | `true` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Required) The VPC subnet(s) the instance(s) will be assigned and launched in. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of tags to assign to the resource. Note that these tags apply to the instance and not block storage devices. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | <pre>{<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | (Optional) Tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command. Valid values are default, dedicated, and host. | `string` | `"default"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | (Optional) User data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user\_data\_base64 instead. Updates to this field will trigger a stop/start of the EC2 instance by default. If the user\_data\_replace\_on\_change is set then updates to this field will trigger a destroy and recreate. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The ID of the VPC to which we would like to associate a DHCP Options Set. | `string` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | (Required, VPC only) List of security group IDs to associate with. | `list(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dhcp_options_id"></a> [dhcp\_options\_id](#output\_dhcp\_options\_id) | n/a |
| <a name="output_ec2_instance_id"></a> [ec2\_instance\_id](#output\_ec2\_instance\_id) | n/a |
| <a name="output_ec2_instance_priv_ip"></a> [ec2\_instance\_priv\_ip](#output\_ec2\_instance\_priv\_ip) | n/a |
| <a name="output_ec2_instance_pub_ip"></a> [ec2\_instance\_pub\_ip](#output\_ec2\_instance\_pub\_ip) | n/a |
| <a name="output_ec2_instance_security_groups"></a> [ec2\_instance\_security\_groups](#output\_ec2\_instance\_security\_groups) | n/a |
| <a name="output_ec2_instance_subnet_id"></a> [ec2\_instance\_subnet\_id](#output\_ec2\_instance\_subnet\_id) | n/a |
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