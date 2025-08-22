terraform {
  required_version = ">= 1.0.0"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = ">=0.42.0"
    }
  }
}

##############################
# Terraform Team
##############################
resource "tfe_team" "this" {
  name         = var.name
  organization = var.organization
  visibility   = var.visibility
  sso_team_id  = var.sso_team_id
  organization_access {
    manage_policies         = var.manage_policies
    manage_policy_overrides = var.manage_policy_overrides
    manage_workspaces       = var.manage_workspaces
    manage_vcs_settings     = var.manage_vcs_settings
    manage_providers        = var.manage_providers
    manage_modules          = var.manage_modules
    manage_run_tasks        = var.manage_run_tasks
    manage_projects         = var.manage_projects
    manage_membership       = var.manage_membership
    read_workspaces         = var.read_workspaces
    read_projects           = var.read_projects
  }
}
