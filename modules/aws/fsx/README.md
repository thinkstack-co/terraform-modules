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

<h3 align="center">FSx Module</h3>
  <p align="center">
    This module creates FSx resources within AWS
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
module test {
    source = 

    variable = 
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
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_fsx_windows_file_system.fsx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_windows_file_system) | resource |
| [aws_kms_alias.cloudwatch_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.fsx_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.fsx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aliases"></a> [aliases](#input\_aliases) | (Optional) An array DNS alias names that you want to associate with the Amazon FSx file system. For more information, see Working with DNS Aliases. | `any` | n/a | yes |
| <a name="input_automatic_backup_retention_days"></a> [automatic\_backup\_retention\_days](#input\_automatic\_backup\_retention\_days) | (Optional) The number of days to retain automatic backups. Minimum of 0 and maximum of 90. Defaults to 7. Set to 0 to disable. | `string` | `"7"` | no |
| <a name="input_backup_id"></a> [backup\_id](#input\_backup\_id) | (Optional) The ID of the source backup to create the filesystem from. | `string` | `""` | no |
| <a name="input_cloudwatch_name_prefix"></a> [cloudwatch\_name\_prefix](#input\_cloudwatch\_name\_prefix) | n/a | `string` | `"/aws/fsx/fsx_access_logs_"` | no |
| <a name="input_cloudwatch_retention_in_days"></a> [cloudwatch\_retention\_in\_days](#input\_cloudwatch\_retention\_in\_days) | (Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `90` | no |
| <a name="input_copy_tags_to_backups"></a> [copy\_tags\_to\_backups](#input\_copy\_tags\_to\_backups) | (Optional) A boolean flag indicating whether tags on the file system should be copied to backups. Defaults to true. | `bool` | `true` | no |
| <a name="input_daily_automatic_backup_start_time"></a> [daily\_automatic\_backup\_start\_time](#input\_daily\_automatic\_backup\_start\_time) | (Optional) The preferred time (in HH:MM format) to take daily automatic backups, in the UTC time zone. | `string` | `"23:59"` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | (Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days. | `number` | `30` | no |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | (Optional) Specifies the file system deployment type, valid values are MULTI\_AZ\_1, SINGLE\_AZ\_1 and SINGLE\_AZ\_2. Default value is SINGLE\_AZ\_1. | `string` | `"SINGLE_AZ_1"` | no |
| <a name="input_dns_ips"></a> [dns\_ips](#input\_dns\_ips) | (Required) A list of up to two IP addresses of DNS servers or domain controllers in the self-managed AD directory. The IP addresses need to be either in the same VPC CIDR range as the file system or in the private IP version 4 (IPv4) address ranges as specified in RFC 1918. | `list` | <pre>[<br>  "10.11.1.100",<br>  "10.11.2.100"<br>]</pre> | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | (Required) The fully qualified domain name of the self-managed AD directory. For example, corp.example.com. | `any` | n/a | yes |
| <a name="input_enable_audit_logs"></a> [enable\_audit\_logs](#input\_enable\_audit\_logs) | Determines count for cloudwatch log group, IAM policy, and IAM role. Defaults to true and enters a count of 1 to create resources. | `bool` | `true` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | (Optional) Specifies whether key rotation is enabled. Defaults to false. | `bool` | `true` | no |
| <a name="input_file_access_audit_log_level"></a> [file\_access\_audit\_log\_level](#input\_file\_access\_audit\_log\_level) | (Optional) Sets which attempt type is logged by Amazon FSx for file and folder accesses. Valid values are SUCCESS\_ONLY, FAILURE\_ONLY, SUCCESS\_AND\_FAILURE, and DISABLED. Default value is DISABLED. | `string` | `"SUCCESS_AND_FAILURE"` | no |
| <a name="input_file_share_access_audit_log_level"></a> [file\_share\_access\_audit\_log\_level](#input\_file\_share\_access\_audit\_log\_level) | (Optional) Sets which attempt type is logged by Amazon FSx for file share accesses. Valid values are SUCCESS\_ONLY, FAILURE\_ONLY, SUCCESS\_AND\_FAILURE, and DISABLED. Default value is DISABLED. | `string` | `"SUCCESS_AND_FAILURE"` | no |
| <a name="input_file_system_administrators_group"></a> [file\_system\_administrators\_group](#input\_file\_system\_administrators\_group) | (Optional) The name of the domain group whose members are granted administrative privileges for the file system. Administrative privileges include taking ownership of files and folders, and setting audit controls (audit ACLs) on files and folders. The group that you specify must already exist in your domain. Defaults to Domain Admins. | `string` | `"Domain Admins"` | no |
| <a name="input_fsx_cloudwatch_key_description"></a> [fsx\_cloudwatch\_key\_description](#input\_fsx\_cloudwatch\_key\_description) | (Optional) The description of the key as viewed in AWS console. | `string` | `"CloudWatch kms key used to encrypt fsx logs"` | no |
| <a name="input_fsx_cloudwatch_key_name"></a> [fsx\_cloudwatch\_key\_name](#input\_fsx\_cloudwatch\_key\_name) | Name of the cloudwatch for fsx KMS key | `string` | `"alias/fsx_cloudwatch_kms_key"` | no |
| <a name="input_fsx_key_description"></a> [fsx\_key\_description](#input\_fsx\_key\_description) | (Optional) The description of the key as viewed in AWS console. | `string` | `"fsx kms key used to encrypt fsx data at rest"` | no |
| <a name="input_fsx_key_name"></a> [fsx\_key\_name](#input\_fsx\_key\_name) | Name of the fsx KMS key | `string` | `"alias/fsx_kms_key"` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) Specifies whether the key is enabled. Defaults to true. | `string` | `true` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | (Optional) Specifies the intended use of the key. Defaults to ENCRYPT\_DECRYPT, and only symmetric encryption and decryption are supported. | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_organizational_unit_distinguished_name"></a> [organizational\_unit\_distinguished\_name](#input\_organizational\_unit\_distinguished\_name) | (Optional) The fully qualified distinguished name of the organizational unit within your self-managed AD directory that the Windows File Server instance will join. For example, OU=FSx,DC=yourdomain,DC=corp,DC=com. Only accepts OU as the direct parent of the file system. If none is provided, the FSx file system is created in the default location of your self-managed AD directory. To learn more, see RFC 2253. | `any` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | (Required) The password for the service account on your self-managed AD domain that Amazon FSx will use to join to your AD domain. | `any` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid policy JSON document. Although this is a key policy, not an IAM policy, an aws\_iam\_policy\_document, in the form that designates a principal, can be used. For more information about building policy documents with Terraform, see the AWS IAM Policy Document Guide. | `string` | `""` | no |
| <a name="input_preferred_subnet_id"></a> [preferred\_subnet\_id](#input\_preferred\_subnet\_id) | (Optional) Specifies the subnet in which you want the preferred file server to be located. Required for when deployment type is MULTI\_AZ\_1. | `string` | `""` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | (Optional) A list of IDs for the security groups that apply to the specified network interfaces created for file system access. These security groups will apply to all network interfaces. | `any` | n/a | yes |
| <a name="input_skip_final_backup"></a> [skip\_final\_backup](#input\_skip\_final\_backup) | (Optional) When enabled, will skip the default final backup taken when the file system is deleted. This configuration must be applied separately before attempting to delete the resource to have the desired behavior. Defaults to false. | `bool` | `false` | no |
| <a name="input_storage_capacity"></a> [storage\_capacity](#input\_storage\_capacity) | (Optional) Storage capacity (GiB) of the file system. Minimum of 32 and maximum of 65536. If the storage type is set to HDD the minimum value is 2000. Required when not creating filesystem for a backup. | `string` | `"2000"` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | (Optional) Specifies the storage type, Valid values are SSD and HDD. HDD is supported on SINGLE\_AZ\_2 and MULTI\_AZ\_1 Windows file system deployment types. Default value is SSD. | `string` | `"SSD"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (Required) A list of IDs for the subnets that the file system will be accessible from. To specify more than a single subnet set deployment\_type to MULTI\_AZ\_1. | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the object. | `map` | <pre>{<br>  "created_by": "ThinkStack",<br>  "environment": "prod",<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_throughput_capacity"></a> [throughput\_capacity](#input\_throughput\_capacity) | (Required) Throughput (megabytes per second) of the file system in power of 2 increments. Minimum of 8 and maximum of 2048. | `string` | `"64"` | no |
| <a name="input_username"></a> [username](#input\_username) | (Required) The user name for the service account on your self-managed AD domain that Amazon FSx will use to join to your AD domain. | `any` | n/a | yes |
| <a name="input_weekly_maintenance_start_time"></a> [weekly\_maintenance\_start\_time](#input\_weekly\_maintenance\_start\_time) | (Optional) The preferred start time (in d:HH:MM format) to perform weekly maintenance, in the UTC time zone. | `string` | `"1:01:00"` | no |

## Outputs

No outputs.
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