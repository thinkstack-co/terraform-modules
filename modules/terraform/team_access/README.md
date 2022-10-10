# Usage
## Simple
    module "example_team_access" {
        source       = "github.com/thinkstack-co/terraform-modules//modules/terraform/team_access"

        team_id      = module.team.id
        workspace_id = module.workspace.id
        access       = "read"
    }

## Complex for_each
    module "example_team_access" {
        source       = "github.com/thinkstack-co/terraform-modules//modules/terraform/team_access"
        
        for_each     = var.permissions_mapping
        team_id      = each.value.id
        workspace_id = module.workspace.id
        access       = each.value.access
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
| [tfe_team_access.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_access) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access"></a> [access](#input\_access) | (Required) Type of fixed access to grant. Valid values are admin, read, plan, or write. To use custom permissions, use a permissions block instead. This value must not be provided if permissions is provided. | `string` | n/a | yes |
| <a name="input_team_id"></a> [team\_id](#input\_team\_id) | (Required) ID of the team to add to the workspace. | `string` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | (Required) ID of the workspace to which the team will be added. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
<!-- END_TF_DOCS -->
