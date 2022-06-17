# Usage

    module "example_team" {
        source            = "github.com/thinkstack-co/terraform-modules//modules/terraform/team"

        name              = "example_team"
        organization      = var.example_organization
    }


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [tfe_team.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_manage_modules"></a> [manage\_modules](#input\_manage\_modules) | (Optional) Allow members to publish and delete modules in the organization's private registry. | `bool` | `false` | no |
| <a name="input_manage_policies"></a> [manage\_policies](#input\_manage\_policies) | (Optional) Allows members to create, edit, and delete the organization's Sentinel policies. | `bool` | `false` | no |
| <a name="input_manage_policy_overrides"></a> [manage\_policy\_overrides](#input\_manage\_policy\_overrides) | (Optional) Allows members to override soft-mandatory policy checks. | `bool` | `false` | no |
| <a name="input_manage_providers"></a> [manage\_providers](#input\_manage\_providers) | (Optional) Allow members to publish and delete providers in the organization's private registry. | `bool` | `false` | no |
| <a name="input_manage_vcs_settings"></a> [manage\_vcs\_settings](#input\_manage\_vcs\_settings) | (Optional) Allows members to manage the organization's VCS Providers and SSH keys. | `bool` | `false` | no |
| <a name="input_manage_workspaces"></a> [manage\_workspaces](#input\_manage\_workspaces) | (Optional) Allows members to create and administrate all workspaces within the organization. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the team. | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | (Required) Name of the organization. | `string` | n/a | yes |
| <a name="input_sso_team_id"></a> [sso\_team\_id](#input\_sso\_team\_id) | (Optional) Unique Identifier to control team membership via SAML. Defaults to null | `string` | `null` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | (Optional) The visibility of the team ('secret' or 'organization'). Defaults to 'secret'. | `string` | `"secret"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
<!-- END_TF_DOCS -->