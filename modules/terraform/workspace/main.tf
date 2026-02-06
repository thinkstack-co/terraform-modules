terraform {
  required_version = ">= 1.0.0"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = ">=0.61.0"
    }
  }
}

##############################
# Terraform Workspace
##############################

resource "tfe_workspace" "this" {
  allow_destroy_plan            = var.allow_destroy_plan
  auto_apply                    = var.auto_apply
  assessments_enabled           = var.assessments_enabled
  description                   = var.description
  file_triggers_enabled         = var.file_triggers_enabled
  name                          = var.name
  organization                  = var.organization
  queue_all_runs                = var.queue_all_runs
  speculative_enabled           = var.speculative_enabled
  ssh_key_id                    = var.ssh_key_id
  structured_run_output_enabled = var.structured_run_output_enabled
  terraform_version             = var.default_terraform_version
  trigger_prefixes              = var.trigger_prefixes
  tag_names                     = var.tag_names
  working_directory             = var.working_directory
  vcs_repo {
    identifier         = var.identifier
    branch             = var.branch
    ingress_submodules = var.ingress_submodules
    oauth_token_id     = var.oauth_token_id
  }
}

##############################
# Workspace Settings
##############################

# Manages execution mode, agent pool, and remote state settings
resource "tfe_workspace_settings" "this" {
  workspace_id              = tfe_workspace.this.id
  agent_pool_id             = var.agent_pool_id
  execution_mode            = var.execution_mode
  global_remote_state       = var.global_remote_state
  remote_state_consumer_ids = var.remote_state_consumer_ids
}

##############################
# Parallelism Configuration
##############################

# Sets the parallelism flag for terraform plan operations
resource "tfe_variable" "parallelism_plan" {
  count        = var.parallelism != null ? 1 : 0
  key          = "TF_CLI_ARGS_plan"
  value        = "-parallelism=${var.parallelism}"
  category     = "env"
  workspace_id = tfe_workspace.this.id
  description  = "Sets the number of concurrent operations during plan"
}

# Sets the parallelism flag for terraform apply operations
resource "tfe_variable" "parallelism_apply" {
  count        = var.parallelism != null ? 1 : 0
  key          = "TF_CLI_ARGS_apply"
  value        = "-parallelism=${var.parallelism}"
  category     = "env"
  workspace_id = tfe_workspace.this.id
  description  = "Sets the number of concurrent operations during apply"
}

##############################
# Terraform Team Access/Permissions
##############################

resource "tfe_team_access" "this" {
  for_each     = var.permission_map
  team_id      = each.value.id
  workspace_id = tfe_workspace.this.id
  access       = each.value.access
}
