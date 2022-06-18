# Terraform Workspace Module
This module generates and manages a terraform cloud workspace

# Usage

    module "client_prod_security" {
        source           = "github.com/thinkstack-co/terraform-modules//modules/terraform/workspace"
        
        identifier        = "github-repo/client_prod_security"
        name              = "client_prod_security"
        oauth_token_id    = var.github_oauth_token_id
        organization      = var.organization
        terraform_version = "~>1.2.0"
        permission_map    = var.workspace_permissions_mapping
    }

    variable "thinkstack_workspace_permissions_mapping" {
        description = "Map of permissions to set with each terraform workspace."
        type        = map
        default     = {
            "all_admin"      = {"id" = "team-fjkdlsafjska2411", "access" = "admin"}
            "cloud_read"     = {"id" = "team-fndsabfak2010144", "access" = "read"}
            "cloud_write"    = {"id" = "team-fdjkslajflkn4591", "access" = "write"}
            "security_read"  = {"id" = "team-fdsahfkdsnalka40", "access" = "read"}
            "security_write" = {"id" = "team-fjdkslajfdsa0140", "access" = "write"}
        }
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
| [tfe_workspace.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_pool_id"></a> [agent\_pool\_id](#input\_agent\_pool\_id) | (Optional) The ID of an agent pool to assign to the workspace. Requires execution\_mode to be set to agent. This value must not be provided if execution\_mode is set to any other value or if operations is provided. | `string` | `null` | no |
| <a name="input_allow_destroy_plan"></a> [allow\_destroy\_plan](#input\_allow\_destroy\_plan) | (Optional) Whether destroy plans can be queued on the workspace. | `bool` | `false` | no |
| <a name="input_auto_apply"></a> [auto\_apply](#input\_auto\_apply) | (Optional) Whether to automatically apply changes when a Terraform plan is successful. Defaults to false. | `bool` | `false` | no |
| <a name="input_branch"></a> [branch](#input\_branch) | (Optional) The repository branch that Terraform will execute from. This defaults to the repository's default branch (e.g. main). | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) A description for the workspace. | `string` | `null` | no |
| <a name="input_execution_mode"></a> [execution\_mode](#input\_execution\_mode) | (Optional) Which execution mode to use. Using Terraform Cloud, valid values are remote, local oragent. Defaults to remote. Using Terraform Enterprise, only remoteand local execution modes are valid. When set to local, the workspace will be used for state storage only. This value must not be provided if operations is provided. | `string` | `"remote"` | no |
| <a name="input_file_triggers_enabled"></a> [file\_triggers\_enabled](#input\_file\_triggers\_enabled) | (Optional) Whether to filter runs based on the changed files in a VCS push. Defaults to false. If enabled, the working directory and trigger prefixes describe a set of paths which must contain changes for a VCS push to trigger a run. If disabled, any push will trigger a run. | `bool` | `false` | no |
| <a name="input_global_remote_state"></a> [global\_remote\_state](#input\_global\_remote\_state) | (Optional) Whether the workspace allows all workspaces in the organization to access its state data during runs. If false, then only specifically approved workspaces can access its state (remote\_state\_consumer\_ids). | `bool` | `false` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | (Required) A reference to your VCS repository in the format <organization>/<repository> where <organization> and <repository> refer to the organization and repository in your VCS provider. The format for Azure DevOps is //\_git/. | `string` | n/a | yes |
| <a name="input_ingress_submodules"></a> [ingress\_submodules](#input\_ingress\_submodules) | (Optional) Whether submodules should be fetched when cloning the VCS repository. Defaults to false. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the workspace. | `string` | n/a | yes |
| <a name="input_oauth_token_id"></a> [oauth\_token\_id](#input\_oauth\_token\_id) | (Required) The VCS Connection (OAuth Connection + Token) to use. This ID can be obtained from a tfe\_oauth\_client resource. | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | (Required) Name of the organization. | `string` | n/a | yes |
| <a name="input_permission_map"></a> [permission\_map](#input\_permission\_map) | (Required) The permissions map which maps the team\_id to the permission access level. Exampe: 'terraform\_all\_admin = {id = team-fdsa5122q6rwYXP, access = admin}' | `map` | n/a | yes |
| <a name="input_queue_all_runs"></a> [queue\_all\_runs](#input\_queue\_all\_runs) | (Optional) Whether the workspace should start automatically performing runs immediately after its creation. Defaults to true. When set to false, runs triggered by a webhook (such as a commit in VCS) will not be queued until at least one run has been manually queued. Note: This default differs from the Terraform Cloud API default, which is false. The provider uses true as any workspace provisioned with false would need to then have a run manually queued out-of-band before accepting webhooks. | `bool` | `true` | no |
| <a name="input_remote_state_consumer_ids"></a> [remote\_state\_consumer\_ids](#input\_remote\_state\_consumer\_ids) | (Optional) The set of workspace IDs set as explicit remote state consumers for the given workspace. | `list(string)` | `null` | no |
| <a name="input_speculative_enabled"></a> [speculative\_enabled](#input\_speculative\_enabled) | (Optional) Whether this workspace allows speculative plans. Defaults to true. Setting this to false prevents Terraform Cloud or the Terraform Enterprise instance from running plans on pull requests, which can improve security if the VCS repository is public or includes untrusted contributors. | `bool` | `true` | no |
| <a name="input_ssh_key_id"></a> [ssh\_key\_id](#input\_ssh\_key\_id) | (Optional) The ID of an SSH key to assign to the workspace. | `string` | `null` | no |
| <a name="input_structured_run_output_enabled"></a> [structured\_run\_output\_enabled](#input\_structured\_run\_output\_enabled) | (Optional) Whether this workspace should show output from Terraform runs using the enhanced UI when available. Defaults to true. Setting this to false ensures that all runs in this workspace will display their output as text logs. | `bool` | `true` | no |
| <a name="input_tag_names"></a> [tag\_names](#input\_tag\_names) | (Optional) A list of tag names for this workspace. Note that tags must only contain letters, numbers or colons. | `list(string)` | `null` | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | (Optional) The version of Terraform to use for this workspace. This can be either an exact version or a version constraint (like ~> 1.0.0); if you specify a constraint, the workspace will always use the newest release that meets that constraint. Defaults to the latest available version. | `string` | `"~>1.2.0"` | no |
| <a name="input_trigger_prefixes"></a> [trigger\_prefixes](#input\_trigger\_prefixes) | (Optional) List of repository-root-relative paths which describe all locations to be tracked for changes. | `list(string)` | `null` | no |
| <a name="input_working_directory"></a> [working\_directory](#input\_working\_directory) | (Optional) A relative path that Terraform will execute within. Defaults to the root of your repository. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
<!-- END_TF_DOCS -->