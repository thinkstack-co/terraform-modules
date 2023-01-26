# Usage


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_conditional_access_policy.example](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/conditional_access_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_enforced_restrictions_enabled"></a> [application\_enforced\_restrictions\_enabled](#input\_application\_enforced\_restrictions\_enabled) | (Optional) Whether or not application enforced restrictions are enabled. Defaults to false. | `bool` | `false` | no |
| <a name="input_built_in_controls"></a> [built\_in\_controls](#input\_built\_in\_controls) | (Required) List of built-in controls required by the policy. Possible values are: block, mfa, approvedApplication, compliantApplication, compliantDevice, domainJoinedDevice, passwordChange or unknownFutureValue. | `list(string)` | `null` | no |
| <a name="input_client_app_types"></a> [client\_app\_types](#input\_client\_app\_types) | (Required) A list of client application types included in the policy. Possible values are: all, browser, mobileAppsAndDesktopClients, exchangeActiveSync, easSupported and other. | `list(string)` | n/a | yes |
| <a name="input_cloud_app_security_policy"></a> [cloud\_app\_security\_policy](#input\_cloud\_app\_security\_policy) | (Optional) Enables cloud app security and specifies the cloud app security policy to use. Possible values are: blockDownloads, mcasConfigured, monitorOnly or unknownFutureValue. | `string` | n/a | yes |
| <a name="input_custom_authentication_factors"></a> [custom\_authentication\_factors](#input\_custom\_authentication\_factors) | (Optional) List of custom controls IDs required by the policy. | `list(string)` | `null` | no |
| <a name="input_device_filter_mode"></a> [device\_filter\_mode](#input\_device\_filter\_mode) | (Optional) Whether to include in, or exclude from, matching devices from the policy. Supported values are include or exclude. | `string` | `null` | no |
| <a name="input_device_filter_rule"></a> [device\_filter\_rule](#input\_device\_filter\_rule) | (Required) Condition filter to match devices. For more information, see official documentation. | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | (Required) The friendly name for this Conditional Access Policy. | `string` | n/a | yes |
| <a name="input_excluded_applications"></a> [excluded\_applications](#input\_excluded\_applications) | (Optional) A list of application IDs explicitly excluded from the policy. Can also be set to Office365. | `list(string)` | `null` | no |
| <a name="input_excluded_groups"></a> [excluded\_groups](#input\_excluded\_groups) | (Optional) A list of group IDs excluded from scope of policy. | `list(string)` | `null` | no |
| <a name="input_excluded_locations"></a> [excluded\_locations](#input\_excluded\_locations) | (Optional) A list of location IDs excluded from scope of policy. Can also be set to AllTrusted. | `list(string)` | `null` | no |
| <a name="input_excluded_platforms"></a> [excluded\_platforms](#input\_excluded\_platforms) | (Optional) A list of platforms explicitly excluded from the policy. Possible values are: all, android, iOS, linux, macOS, windows, windowsPhone or unknownFutureValue. | `list(string)` | n/a | yes |
| <a name="input_excluded_roles"></a> [excluded\_roles](#input\_excluded\_roles) | (Optional) A list of role IDs excluded from scope of policy. | `list(string)` | `null` | no |
| <a name="input_excluded_users"></a> [excluded\_users](#input\_excluded\_users) | (Optional) A list of user IDs excluded from scope of policy and/or GuestsOrExternalUsers. | `list(string)` | `null` | no |
| <a name="input_included_applications"></a> [included\_applications](#input\_included\_applications) | (Optional) A list of application IDs the policy applies to, unless explicitly excluded (in excluded\_applications). Can also be set to All, None or Office365. Cannot be specified with included\_user\_actions. One of included\_applications or included\_user\_actions must be specified. | `list(string)` | `null` | no |
| <a name="input_included_groups"></a> [included\_groups](#input\_included\_groups) | (Optional) A list of group IDs in scope of policy unless explicitly excluded. | `list(string)` | `null` | no |
| <a name="input_included_locations"></a> [included\_locations](#input\_included\_locations) | (Required) A list of location IDs in scope of policy unless explicitly excluded. Can also be set to All, or AllTrusted. | `list(string)` | `null` | no |
| <a name="input_included_platforms"></a> [included\_platforms](#input\_included\_platforms) | (Required) A list of platforms the policy applies to, unless explicitly excluded. Possible values are: all, android, iOS, linux, macOS, windows, windowsPhone or unknownFutureValue. | `list(string)` | n/a | yes |
| <a name="input_included_roles"></a> [included\_roles](#input\_included\_roles) | (Optional) A list of role IDs in scope of policy unless explicitly excluded. | `list(string)` | `null` | no |
| <a name="input_included_user_actions"></a> [included\_user\_actions](#input\_included\_user\_actions) | (Optional) A list of user actions to include. Supported values are urn:user:registerdevice and urn:user:registersecurityinfo. Cannot be specified with included\_applications. One of included\_applications or included\_user\_actions must be specified. | `list(string)` | `null` | no |
| <a name="input_included_users"></a> [included\_users](#input\_included\_users) | (Optional) A list of user IDs in scope of policy unless explicitly excluded, or None or All or GuestsOrExternalUsers. | `list(string)` | `null` | no |
| <a name="input_operator"></a> [operator](#input\_operator) | (Required) Defines the relationship of the grant controls. Possible values are: AND, OR. | `string` | n/a | yes |
| <a name="input_persistent_browser_mode"></a> [persistent\_browser\_mode](#input\_persistent\_browser\_mode) | (Optional) Session control to define whether to persist cookies or not. Possible values are: always or never. | `string` | `null` | no |
| <a name="input_sign_in_frequency"></a> [sign\_in\_frequency](#input\_sign\_in\_frequency) | (Optional) Number of days or hours to enforce sign-in frequency. Required when sign\_in\_frequency\_period is specified. Due to an API issue, removing this property forces a new resource to be created. | `number` | `null` | no |
| <a name="input_sign_in_frequency_period"></a> [sign\_in\_frequency\_period](#input\_sign\_in\_frequency\_period) | (Optional) The time period to enforce sign-in frequency. Possible values are: hours or days. Required when sign\_in\_frequency\_period is specified. Due to an API issue, removing this property forces a new resource to be created. | `string` | `null` | no |
| <a name="input_sign_in_risk_levels"></a> [sign\_in\_risk\_levels](#input\_sign\_in\_risk\_levels) | (Optional) A list of sign-in risk levels included in the policy. Possible values are: low, medium, high, hidden, none, unknownFutureValue. | `list(string)` | `null` | no |
| <a name="input_state"></a> [state](#input\_state) | (Required) Specifies the state of the policy object. Possible values are: enabled, disabled and enabledForReportingButNotEnforced | `string` | n/a | yes |
| <a name="input_terms_of_use"></a> [terms\_of\_use](#input\_terms\_of\_use) | (Optional) List of terms of use IDs required by the policy. | `list(string)` | `null` | no |
| <a name="input_user_risk_levels"></a> [user\_risk\_levels](#input\_user\_risk\_levels) | (Optional) A list of user risk levels included in the policy. Possible values are: low, medium, high, hidden, none, unknownFutureValue. | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->