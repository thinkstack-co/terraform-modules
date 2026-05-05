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

### Simple Example

This example create a geographic IP address block filter that blocks access from

```
module geo_ip_login_filter {
  source                = "github.com/thinkstack-co/terraform-modules//modules/azuread/conditional_access"
  display_name          = "Geo-IP Login Filter"
  state                 = "enabled"
  client_app_types      = ["all"]
  included_applications = ["all"]
  included_users        = ["all"]
  excluded_users        = ["traveling_employees"]
  included_locations    = ["Blocked Countries"]
  excluded_locations    = ["HQ", "AWS-us-east-1", "United States"]
  built_in_controls     = ["block"]
  operator              = ["AND"]
}
```

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0  |
| <a name="requirement_azuread"></a> [azuread](#requirement_azuread)       | >= 2.36.0 |

## Providers

| Name                                                         | Version   |
| ------------------------------------------------------------ | --------- |
| <a name="provider_azuread"></a> [azuread](#provider_azuread) | >= 2.36.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                   | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| [azuread_conditional_access_policy.example](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/conditional_access_policy) | resource |

## Inputs

| Name                                                                                                                                                         | Description                                                                                                                                                                                                                                                                            | Type           | Default | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_application_enforced_restrictions_enabled"></a> [application_enforced_restrictions_enabled](#input_application_enforced_restrictions_enabled) | (Optional) Whether or not application enforced restrictions are enabled. Defaults to false.                                                                                                                                                                                            | `bool`         | `false` |    no    |
| <a name="input_built_in_controls"></a> [built_in_controls](#input_built_in_controls)                                                                         | (Required) List of built-in controls required by the policy. Possible values are: block, mfa, approvedApplication, compliantApplication, compliantDevice, domainJoinedDevice, passwordChange or unknownFutureValue.                                                                    | `list(string)` | `null`  |    no    |
| <a name="input_client_app_types"></a> [client_app_types](#input_client_app_types)                                                                            | (Required) A list of client application types included in the policy. Possible values are: all, browser, mobileAppsAndDesktopClients, exchangeActiveSync, easSupported and other.                                                                                                      | `list(string)` | n/a     |   yes    |
| <a name="input_cloud_app_security_policy"></a> [cloud_app_security_policy](#input_cloud_app_security_policy)                                                 | (Optional) Enables cloud app security and specifies the cloud app security policy to use. Possible values are: blockDownloads, mcasConfigured, monitorOnly or unknownFutureValue.                                                                                                      | `string`       | `null`  |    no    |
| <a name="input_custom_authentication_factors"></a> [custom_authentication_factors](#input_custom_authentication_factors)                                     | (Optional) List of custom controls IDs required by the policy.                                                                                                                                                                                                                         | `list(string)` | `null`  |    no    |
| <a name="input_device_filter_mode"></a> [device_filter_mode](#input_device_filter_mode)                                                                      | (Optional) Whether to include in, or exclude from, matching devices from the policy. Supported values are include or exclude.                                                                                                                                                          | `string`       | `null`  |    no    |
| <a name="input_device_filter_rule"></a> [device_filter_rule](#input_device_filter_rule)                                                                      | (Required) Condition filter to match devices. For more information, see official documentation.                                                                                                                                                                                        | `string`       | `null`  |    no    |
| <a name="input_display_name"></a> [display_name](#input_display_name)                                                                                        | (Required) The friendly name for this Conditional Access Policy.                                                                                                                                                                                                                       | `string`       | n/a     |   yes    |
| <a name="input_excluded_applications"></a> [excluded_applications](#input_excluded_applications)                                                             | (Optional) A list of application IDs explicitly excluded from the policy. Can also be set to Office365.                                                                                                                                                                                | `list(string)` | `null`  |    no    |
| <a name="input_excluded_groups"></a> [excluded_groups](#input_excluded_groups)                                                                               | (Optional) A list of group IDs excluded from scope of policy.                                                                                                                                                                                                                          | `list(string)` | `null`  |    no    |
| <a name="input_excluded_locations"></a> [excluded_locations](#input_excluded_locations)                                                                      | (Optional) A list of location IDs excluded from scope of policy. Can also be set to AllTrusted.                                                                                                                                                                                        | `list(string)` | `null`  |    no    |
| <a name="input_excluded_platforms"></a> [excluded_platforms](#input_excluded_platforms)                                                                      | (Optional) A list of platforms explicitly excluded from the policy. Possible values are: all, android, iOS, linux, macOS, windows, windowsPhone or unknownFutureValue.                                                                                                                 | `list(string)` | n/a     |   yes    |
| <a name="input_excluded_roles"></a> [excluded_roles](#input_excluded_roles)                                                                                  | (Optional) A list of role IDs excluded from scope of policy.                                                                                                                                                                                                                           | `list(string)` | `null`  |    no    |
| <a name="input_excluded_users"></a> [excluded_users](#input_excluded_users)                                                                                  | (Optional) A list of user IDs excluded from scope of policy and/or GuestsOrExternalUsers.                                                                                                                                                                                              | `list(string)` | `null`  |    no    |
| <a name="input_included_applications"></a> [included_applications](#input_included_applications)                                                             | (Optional) A list of application IDs the policy applies to, unless explicitly excluded (in excluded_applications). Can also be set to All, None or Office365. Cannot be specified with included_user_actions. One of included_applications or included_user_actions must be specified. | `list(string)` | `null`  |    no    |
| <a name="input_included_groups"></a> [included_groups](#input_included_groups)                                                                               | (Optional) A list of group IDs in scope of policy unless explicitly excluded.                                                                                                                                                                                                          | `list(string)` | `null`  |    no    |
| <a name="input_included_locations"></a> [included_locations](#input_included_locations)                                                                      | (Required) A list of location IDs in scope of policy unless explicitly excluded. Can also be set to All, or AllTrusted.                                                                                                                                                                | `list(string)` | `null`  |    no    |
| <a name="input_included_platforms"></a> [included_platforms](#input_included_platforms)                                                                      | (Required) A list of platforms the policy applies to, unless explicitly excluded. Possible values are: all, android, iOS, linux, macOS, windows, windowsPhone or unknownFutureValue.                                                                                                   | `list(string)` | n/a     |   yes    |
| <a name="input_included_roles"></a> [included_roles](#input_included_roles)                                                                                  | (Optional) A list of role IDs in scope of policy unless explicitly excluded.                                                                                                                                                                                                           | `list(string)` | `null`  |    no    |
| <a name="input_included_user_actions"></a> [included_user_actions](#input_included_user_actions)                                                             | (Optional) A list of user actions to include. Supported values are urn:user:registerdevice and urn:user:registersecurityinfo. Cannot be specified with included_applications. One of included_applications or included_user_actions must be specified.                                 | `list(string)` | `null`  |    no    |
| <a name="input_included_users"></a> [included_users](#input_included_users)                                                                                  | (Optional) A list of user IDs in scope of policy unless explicitly excluded, or None or All or GuestsOrExternalUsers.                                                                                                                                                                  | `list(string)` | `null`  |    no    |
| <a name="input_operator"></a> [operator](#input_operator)                                                                                                    | (Required) Defines the relationship of the grant controls. Possible values are: AND, OR.                                                                                                                                                                                               | `string`       | n/a     |   yes    |
| <a name="input_persistent_browser_mode"></a> [persistent_browser_mode](#input_persistent_browser_mode)                                                       | (Optional) Session control to define whether to persist cookies or not. Possible values are: always or never.                                                                                                                                                                          | `string`       | `null`  |    no    |
| <a name="input_sign_in_frequency"></a> [sign_in_frequency](#input_sign_in_frequency)                                                                         | (Optional) Number of days or hours to enforce sign-in frequency. Required when sign_in_frequency_period is specified. Due to an API issue, removing this property forces a new resource to be created.                                                                                 | `number`       | `null`  |    no    |
| <a name="input_sign_in_frequency_period"></a> [sign_in_frequency_period](#input_sign_in_frequency_period)                                                    | (Optional) The time period to enforce sign-in frequency. Possible values are: hours or days. Required when sign_in_frequency_period is specified. Due to an API issue, removing this property forces a new resource to be created.                                                     | `string`       | `null`  |    no    |
| <a name="input_sign_in_risk_levels"></a> [sign_in_risk_levels](#input_sign_in_risk_levels)                                                                   | (Optional) A list of sign-in risk levels included in the policy. Possible values are: low, medium, high, hidden, none, unknownFutureValue.                                                                                                                                             | `list(string)` | `null`  |    no    |
| <a name="input_state"></a> [state](#input_state)                                                                                                             | (Required) Specifies the state of the policy object. Possible values are: enabled, disabled and enabledForReportingButNotEnforced                                                                                                                                                      | `string`       | n/a     |   yes    |
| <a name="input_terms_of_use"></a> [terms_of_use](#input_terms_of_use)                                                                                        | (Optional) List of terms of use IDs required by the policy.                                                                                                                                                                                                                            | `list(string)` | `null`  |    no    |
| <a name="input_user_risk_levels"></a> [user_risk_levels](#input_user_risk_levels)                                                                            | (Optional) A list of user risk levels included in the policy. Possible values are: low, medium, high, hidden, none, unknownFutureValue.                                                                                                                                                | `list(string)` | n/a     |   yes    |

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
