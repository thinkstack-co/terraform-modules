# AWS Azure AD SSO Terraform Module

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

<h3 align="center">AWS Azure AD SSO Module</h3>
  <p align="center">
    This module sets up Single Sign-On (SSO) between AWS and Azure Active Directory.
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

This Terraform module establishes Single Sign-On (SSO) between AWS and Azure Active Directory. It creates the necessary IAM resources in AWS to enable federated authentication from Azure AD, including:

1. An IAM policy that allows listing roles
2. An IAM user with access keys for role management
3. An IAM SAML provider for Azure AD integration
4. Three predefined IAM roles with different permission levels:
   - Administrator role with full access
   - System Administrator role with system administration capabilities
   - Read-only role with view-only access

This module simplifies the process of setting up secure, role-based access to AWS resources using Azure AD as the identity provider.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

```hcl
module "azure_ad_sso" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/azure_ad_sso"

  # Required parameter - SAML metadata from Azure AD
  saml_metadata_document = file("${path.module}/azure_ad_metadata.xml")
  
  # Optional - customize role names
  role_admins_name      = "azure_ad_admins"
  role_sysadmins_name   = "azure_ad_sysadmins"
  role_read_only_name   = "azure_ad_readonly"
  
  # Optional - customize session duration (in seconds)
  role_admins_max_session_duration     = 3600
  role_sysadmins_max_session_duration  = 3600
  role_read_only_max_session_duration  = 3600
  
  # Optional - customize IAM user
  user_name       = "azure_ad_role_manager"
  pgp_key         = "keybase:your_keybase_username"
}
```

### Integration Steps

1. Deploy this module to create the necessary AWS resources
2. Configure Azure AD Enterprise Application for AWS
3. Upload the SAML metadata document from Azure AD to AWS
4. Configure role mappings in Azure AD to match the roles created by this module
5. Test the SSO integration by signing in through Azure AD

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

| Name | Type |
|------|------|
| [aws_iam_policy.role_reading_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_user.role_reading_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.reading_user_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_access_key.read_user_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_saml_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [aws_iam_role.role_admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.admin_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role.role_sysadmins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.sysadmins_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role.role_read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.read_only_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.thinkstack_azure_ad_assume_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| policy_name | Name of the policy | `string` | `"azure_ad_sso_user_role_policy"` | no |
| policy_description | Description of the policy | `string` | `"This policy will allow to fetch the roles from AWS accounts."` | no |
| user_force_destroy | When destroying this user, destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices | `string` | `false` | no |
| user_name | The user's name for the role reading user | `string` | `"azure_ad_role_manager"` | no |
| user_path | Path in which to create the user | `string` | `"/"` | no |
| user_permissions_boundary | The ARN of the policy that is used to set the permissions boundary for the user | `string` | `null` | no |
| pgp_key | Either a base-64 encoded PGP public key, or a keybase username in the form keybase:some_person_that_exists | `string` | `"keybase:thinkstack"` | no |
| saml_name | The name of the provider to create | `string` | `"thinkstack_azure_ad"` | no |
| saml_metadata_document | An XML document generated by an identity provider that supports SAML 2.0 | `string` | n/a | yes |
| role_admins_description | The description of the admin role | `string` | `"ThinkStack Azure AD SSO - Admins role"` | no |
| role_admins_force_detach_policies | Specifies to force detaching any policies the role has before destroying it | `string` | `false` | no |
| role_admins_max_session_duration | The maximum session duration (in seconds) for the admin role | `string` | `7200` | no |
| role_admins_name | The friendly IAM role name for admins | `string` | `"thinkstack_admins"` | no |
| role_admins_permissions_boundary | The ARN of the policy that is used to set the permissions boundary for the admin role | `string` | `null` | no |
| admin_policy_arn | The ARN of the policy to apply to the admin role | `string` | `"arn:aws:iam::aws:policy/AdministratorAccess"` | no |
| role_sysadmins_description | The description of the sysadmin role | `string` | `"ThinkStack Azure AD SSO - Sysadmins role"` | no |
| role_sysadmins_force_detach_policies | Specifies to force detaching any policies the role has before destroying it | `string` | `false` | no |
| role_sysadmins_max_session_duration | The maximum session duration (in seconds) for the sysadmin role | `string` | `7200` | no |
| role_sysadmins_name | The friendly IAM role name for sysadmins | `string` | `"thinkstack_sysadmins"` | no |
| role_sysadmins_permissions_boundary | The ARN of the policy that is used to set the permissions boundary for the sysadmin role | `string` | `null` | no |
| sysadmins_policy_arn | The ARN of the policy to apply to the sysadmin role | `string` | `"arn:aws:iam::aws:policy/job-function/SystemAdministrator"` | no |
| role_read_only_description | The description of the read-only role | `string` | `"ThinkStack Azure AD SSO - Read only role"` | no |
| role_read_only_force_detach_policies | Specifies to force detaching any policies the role has before destroying it | `string` | `false` | no |
| role_read_only_max_session_duration | The maximum session duration (in seconds) for the read-only role | `string` | `7200` | no |
| role_read_only_name | The friendly IAM role name for read-only access | `string` | `"thinkstack_read_only"` | no |
| role_read_only_permissions_boundary | The ARN of the policy that is used to set the permissions boundary for the read-only role | `string` | `null` | no |
| read_only_policy_arn | The ARN of the policy to apply to the read-only role | `string` | `"arn:aws:iam::aws:policy/ReadOnlyAccess"` | no |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- OUTPUTS -->
## Outputs

| Name | Description |
|------|-------------|
| policy_id | The ID of the role reading policy |
| policy_arn | The ARN of the role reading policy |
| policy_name | The name of the role reading policy |
| reading_user_arn | The ARN of the role reading user |
| reading_user_unique_id | The unique ID of the role reading user |
| encrypted_secret | The encrypted secret of the role reading user's access key |
| read_user_id | The ID of the role reading user's access key |
| identity_provider_arn | The ARN of the SAML identity provider |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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

* [Wesley Bey](https://github.com/beywesley)
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
