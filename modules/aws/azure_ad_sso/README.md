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

<h3 align="center">Azure AD SSO Policy Module</h3>
  <p align="center">
    This module allows deployment of the Azure AD iDP for SSO access to AWS accounts. This module should not be used if you have multiple AWS accounts. While it will work, it's less effective and secure than using organization or landing zone IAM assume role chaining.
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
module "thinkstack_azure_ad" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/azure_ad_sso"

  saml_metadata_document = file("global/iam/providers/FederationMetadata.xml")
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
| [aws_iam_access_key.read_user_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_policy.role_reading_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.role_admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.role_read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.role_sysadmins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.admin_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.read_only_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sysadmins_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_saml_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [aws_iam_user.role_reading_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.reading_user_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_policy_document.thinkstack_azure_ad_assume_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_policy_arn"></a> [admin\_policy\_arn](#input\_admin\_policy\_arn) | (Required) - The ARN of the policy you want to apply | `string` | `"arn:aws:iam::aws:policy/AdministratorAccess"` | no |
| <a name="input_pgp_key"></a> [pgp\_key](#input\_pgp\_key) | (Optional) Either a base-64 encoded PGP public key, or a keybase username in the form keybase:some\_person\_that\_exists. | `string` | `"keybase:thinkstack"` | no |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | Description of the policy | `string` | `"This policy will allow to fetch the roles from AWS accounts."` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Name of the policy | `string` | `"azure_ad_sso_user_role_policy"` | no |
| <a name="input_read_only_policy_arn"></a> [read\_only\_policy\_arn](#input\_read\_only\_policy\_arn) | (Required) - The ARN of the policy you want to apply | `string` | `"arn:aws:iam::aws:policy/ReadOnlyAccess"` | no |
| <a name="input_role_admins_description"></a> [role\_admins\_description](#input\_role\_admins\_description) | (Optional) The description of the role. | `string` | `"ThinkStack Azure AD SSO - Admins role"` | no |
| <a name="input_role_admins_force_detach_policies"></a> [role\_admins\_force\_detach\_policies](#input\_role\_admins\_force\_detach\_policies) | (Optional) Specifies to force detaching any policies the role has before destroying it. Defaults to false. | `string` | `false` | no |
| <a name="input_role_admins_max_session_duration"></a> [role\_admins\_max\_session\_duration](#input\_role\_admins\_max\_session\_duration) | (Optional) The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours. | `string` | `7200` | no |
| <a name="input_role_admins_name"></a> [role\_admins\_name](#input\_role\_admins\_name) | (Required) The friendly IAM role name to match. | `string` | `"thinkstack_admins"` | no |
| <a name="input_role_admins_permissions_boundary"></a> [role\_admins\_permissions\_boundary](#input\_role\_admins\_permissions\_boundary) | (Optional) The ARN of the policy that is used to set the permissions boundary for the role. | `string` | `null` | no |
| <a name="input_role_read_only_description"></a> [role\_read\_only\_description](#input\_role\_read\_only\_description) | (Optional) The description of the role. | `string` | `"ThinkStack Azure AD SSO - Read only role"` | no |
| <a name="input_role_read_only_force_detach_policies"></a> [role\_read\_only\_force\_detach\_policies](#input\_role\_read\_only\_force\_detach\_policies) | (Optional) Specifies to force detaching any policies the role has before destroying it. Defaults to false. | `string` | `false` | no |
| <a name="input_role_read_only_max_session_duration"></a> [role\_read\_only\_max\_session\_duration](#input\_role\_read\_only\_max\_session\_duration) | (Optional) The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours. | `string` | `7200` | no |
| <a name="input_role_read_only_name"></a> [role\_read\_only\_name](#input\_role\_read\_only\_name) | (Required) The friendly IAM role name to match. | `string` | `"thinkstack_read_only"` | no |
| <a name="input_role_read_only_permissions_boundary"></a> [role\_read\_only\_permissions\_boundary](#input\_role\_read\_only\_permissions\_boundary) | (Optional) The ARN of the policy that is used to set the permissions boundary for the role. | `string` | `null` | no |
| <a name="input_role_sysadmins_description"></a> [role\_sysadmins\_description](#input\_role\_sysadmins\_description) | (Optional) The description of the role. | `string` | `"ThinkStack Azure AD SSO - Sysadmins role"` | no |
| <a name="input_role_sysadmins_force_detach_policies"></a> [role\_sysadmins\_force\_detach\_policies](#input\_role\_sysadmins\_force\_detach\_policies) | (Optional) Specifies to force detaching any policies the role has before destroying it. Defaults to false. | `string` | `false` | no |
| <a name="input_role_sysadmins_max_session_duration"></a> [role\_sysadmins\_max\_session\_duration](#input\_role\_sysadmins\_max\_session\_duration) | (Optional) The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours. | `string` | `7200` | no |
| <a name="input_role_sysadmins_name"></a> [role\_sysadmins\_name](#input\_role\_sysadmins\_name) | (Required) The friendly IAM role name to match. | `string` | `"thinkstack_sysadmins"` | no |
| <a name="input_role_sysadmins_permissions_boundary"></a> [role\_sysadmins\_permissions\_boundary](#input\_role\_sysadmins\_permissions\_boundary) | (Optional) The ARN of the policy that is used to set the permissions boundary for the role. | `string` | `null` | no |
| <a name="input_saml_metadata_document"></a> [saml\_metadata\_document](#input\_saml\_metadata\_document) | (Required) An XML document generated by an identity provider that supports SAML 2.0. | `string` | n/a | yes |
| <a name="input_saml_name"></a> [saml\_name](#input\_saml\_name) | (Required) The name of the provider to create. | `string` | `"thinkstack_azure_ad"` | no |
| <a name="input_sysadmins_policy_arn"></a> [sysadmins\_policy\_arn](#input\_sysadmins\_policy\_arn) | (Required) - The ARN of the policy you want to apply | `string` | `"arn:aws:iam::aws:policy/job-function/SystemAdministrator"` | no |
| <a name="input_user_force_destroy"></a> [user\_force\_destroy](#input\_user\_force\_destroy) | (Optional, default false) When destroying this user, destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices. Without force\_destroy a user with non-Terraform-managed access keys and login profile will fail to be destroyed. | `string` | `false` | no |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | (Required) The user's name. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-\_.. User names are not distinguished by case. For example, you cannot create users named both 'TESTUSER' and 'testuser'. | `string` | `"azure_ad_role_manager"` | no |
| <a name="input_user_path"></a> [user\_path](#input\_user\_path) | (Optional, default '/') Path in which to create the user. | `string` | `"/"` | no |
| <a name="input_user_permissions_boundary"></a> [user\_permissions\_boundary](#input\_user\_permissions\_boundary) | (Optional) The ARN of the policy that is used to set the permissions boundary for the user. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_encrypted_secret"></a> [encrypted\_secret](#output\_encrypted\_secret) | n/a |
| <a name="output_identity_provider_arn"></a> [identity\_provider\_arn](#output\_identity\_provider\_arn) | n/a |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | n/a |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | n/a |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | n/a |
| <a name="output_read_user_id"></a> [read\_user\_id](#output\_read\_user\_id) | n/a |
| <a name="output_reading_user_arn"></a> [reading\_user\_arn](#output\_reading\_user\_arn) | n/a |
| <a name="output_reading_user_unique_id"></a> [reading\_user\_unique\_id](#output\_reading\_user\_unique\_id) | n/a |
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