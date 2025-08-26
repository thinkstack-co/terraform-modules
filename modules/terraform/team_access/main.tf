terraform {
  required_version = ">= 1.0.0"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = ">=0.42.0"
    }
  }
}

resource "tfe_team_access" "this" {

  team_id      = var.team_id
  workspace_id = var.workspace_id
  access       = var.access
}
