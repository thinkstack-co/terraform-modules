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

<h3 align="center">Launch Template Module</h3>
  <p align="center">
    This module creates a launch template for use in launching instances or auto scaling groups.
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
This example creates a launch template with a user_data script which executes on launch, a specific AMI, and sets the root volume to a 30GB gp3 EBS volume.
```
module "application_prod_launch_template" {
  source                    = "github.com/thinkstack-co/terraform-modules//modules/aws/launch_template"
  ebs_optimized             = true
  key_name                  = module.keypair.key_name
  name_prefix               = "application-prod-"
  iam_instance_profile_name = "AmazonSSMRoleForInstancesQuickSetup"
  image_id                  = "ami-006dcf34c09e50022"
  instance_type             = "c5a.large"
  user_data                 = filebase64("user_data.sh")
  vpc_security_group_ids    = [module.application_sg.id]
  block_device_mappings     = [{
      device_name = "/dev/xvda"

      ebs = {
        delete_on_termination = true
        encrypted             = true
        iops                  = 3000
        kms_key_id            = ""
        snapshot_id           = ""
        throughput            = 125
        volume_size           = 30
        volume_type           = "gp3"
      }
    }]

  tags = {
    created_by  = "YOUR NAME"
    environment = "prod"
    terraform   = "true"
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_recovery"></a> [auto\_recovery](#input\_auto\_recovery) | (Optional) Disables the automatic recovery behavior of your instance or sets it to default. Can be 'default' or 'disabled'. See Recover your instance for more details. | `string` | `"default"` | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | (Optional) Customize EBS volumes attached to the instance. | <pre>list(object({<br>    device_name = string<br>    ebs = object({<br>      delete_on_termination = bool<br>      encrypted             = bool<br>      iops                  = number<br>      kms_key_id            = string<br>      snapshot_id           = string<br>      throughput            = number<br>      volume_size           = number<br>      volume_type           = string<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_credit_specification"></a> [credit\_specification](#input\_credit\_specification) | (Optional) Customize the credit specification of the instance. See Credit Specification below for more details. | <pre>object({<br>    cpu_credits = string<br>  })</pre> | <pre>{<br>  "cpu_credits": "standard"<br>}</pre> | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | (Optional) If true, the launched EC2 instance will be EBS-optimized. Default is true | `bool` | `true` | no |
| <a name="input_enclave_options"></a> [enclave\_options](#input\_enclave\_options) | (Optional) Customize the Enclave Options of the instance. See Enclave Options below for more details. | <pre>object({<br>    enabled = bool<br>  })</pre> | `null` | no |
| <a name="input_hibernation_options"></a> [hibernation\_options](#input\_hibernation\_options) | (Optional) Customize the Hibernation Options of the instance. See Hibernation Options below for more details. | <pre>object({<br>    configured = bool<br>  })</pre> | `null` | no |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | (Optional) Whether the metadata service is available. Can be 'enabled' or 'disabled'. Default is 'enabled'. | `string` | `"enabled"` | no |
| <a name="input_http_protocol_ipv6"></a> [http\_protocol\_ipv6](#input\_http\_protocol\_ipv6) | (Optional) Enables or disables the IPv6 endpoint for the instance metadata service. Default is disable. | `string` | `"disabled"` | no |
| <a name="input_http_put_response_hop_limit"></a> [http\_put\_response\_hop\_limit](#input\_http\_put\_response\_hop\_limit) | (Optional) The desired HTTP PUT response hop limit for instance metadata requests. The larger the number, the further instance metadata requests can travel. Can be an integer from 1 to 64. (Default: 1). | `number` | `1` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | (Optional) Whether instance metadata requests should use token authentication. Can be 'optional' or 'required'. Default is 'required'. | `string` | `"required"` | no |
| <a name="input_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#input\_iam\_instance\_profile\_name) | The name of the instance profile. | `string` | `null` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | (Required) The AMI from which to launch the instance. | `string` | n/a | yes |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | (Optional) Shutdown behavior for the instance. Can be stop or terminate. Default is stop. | `string` | `"stop"` | no |
| <a name="input_instance_metadata_tags"></a> [instance\_metadata\_tags](#input\_instance\_metadata\_tags) | (Optional) Enables or disables access to instance tags from the instance metadata service. (Default: disabled). | `string` | `"enabled"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | (Required) The type of the instance. If present then instance\_requirements cannot be present. | `string` | n/a | yes |
| <a name="input_kernel_id"></a> [kernel\_id](#input\_kernel\_id) | (Optional) The ID of the kernel. | `string` | `null` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | (Optional) The key name that should be used for the instance. | `string` | `null` | no |
| <a name="input_license_specification"></a> [license\_specification](#input\_license\_specification) | (Optional) Customize the License Specification of the instance. See License Specification below for more details. | <pre>list(object({<br>    license_configuration_arn = string<br>  }))</pre> | `null` | no |
| <a name="input_monitoring_enabled"></a> [monitoring\_enabled](#input\_monitoring\_enabled) | (Optional) If true, the launched EC2 instance will have detailed monitoring enabled. Default is true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) Creates a unique name for the launch template beginning with the specified prefix. Conflicts with name. | `string` | n/a | yes |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | (Optional) Customize the Network Interfaces of the instance. See Network Interfaces below for more details. | <pre>list(object({<br>    associate_carrier_ip_address = bool<br>    associate_public_ip_address  = bool<br>    delete_on_termination        = bool<br>    description                  = string<br>    device_index                 = number<br>    ipv6_address_count           = number<br>    ipv6_addresses               = list(string)<br>    network_interface_id         = string<br>    private_ip_address           = string<br>    security_groups              = list(string)<br>    subnet_id                    = string<br>  }))</pre> | `null` | no |
| <a name="input_placement"></a> [placement](#input\_placement) | (Optional) Customize the Placement of the instance. See Placement below for more details. | <pre>object({<br>    affinity          = string<br>    availability_zone = string<br>    group_name        = string<br>    host_id           = string<br>    spread_domain     = string<br>    tenancy           = string<br>  })</pre> | `null` | no |
| <a name="input_tag_specifications"></a> [tag\_specifications](#input\_tag\_specifications) | (Optional) Customize the Tag Specifications of the instance. See Tag Specifications below for more details. | <pre>list(object({<br>    resource_type = string<br>    tags          = map(string)<br>  }))</pre> | <pre>[<br>  {<br>    "resource_type": "instance",<br>    "tags": {<br>      "environment": "prod",<br>      "launch_template": "true",<br>      "terraform": "true"<br>    }<br>  },<br>  {<br>    "resource_type": "volume",<br>    "tags": {<br>      "environment": "prod",<br>      "launch_template": "true",<br>      "terraform": "true"<br>    }<br>  }<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to assign to the launch template. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(string)` | <pre>{<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_update_default_version"></a> [update\_default\_version](#input\_update\_default\_version) | (Optional) Whether to update Default Version each update. Conflicts with default\_version. Default is false. | `bool` | `true` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | (Optional) The Base64-encoded user data to provide when launching the instance. | `string` | `null` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | (Optional) A list of security group IDs to associate with. Conflicts with network\_interfaces.security\_groups | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) of the launch template. |
| <a name="output_id"></a> [id](#output\_id) | ID of the launch template. |
| <a name="output_latest_version"></a> [latest\_version](#output\_latest\_version) | The latest version of the launch template. |
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