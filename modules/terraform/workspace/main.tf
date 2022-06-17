##############################
# Terraform Workspace
##############################

resource "tfe_workspace" "this" {
  agent_pool_id                 = var.agent_pool_id
  allow_destroy_plan            = var.allow_destroy_plan
  auto_apply                    = var.auto_apply
  description                   = var.description
  execution_mode                = var.execution_mode
  file_triggers_enabled         = var.file_triggers_enabled
  global_remote_state           = var.global_remote_state
  name                          = var.name
  organization                  = var.organization
  queue_all_runs                = var.queue_all_runs
  remote_state_consumer_ids     = var.remote_state_consumer_ids
  speculative_enabled           = var.speculative_enabled
  ssh_key_id                    = var.ssh_key_id
  structured_run_output_enabled = var.structured_run_output_enabled
  terraform_version             = var.terraform_version
  trigger_prefixes              = var.trigger_prefixes
  tag_names                     = var.tag_names
  working_directory             = var.working_directory
  vcs_repo {
    identifier                  = var.identifier
    branch                      = var.branch
    ingress_submodules          = var.ingress_submodules
    oauth_token_id              = var.oauth_token_id
  }
}

##############################
# Terraform Team Access/Permissions
##############################

resource "tfe_team_access" "this" {

  for_each = var.permission_map
  
  team_id      = each.value.id
  workspace_id = tfe_workspace.this.id
  access       = each.value.access
}
