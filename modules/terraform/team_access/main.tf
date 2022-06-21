resource "tfe_team_access" "this" {
  
  team_id      = var.team_id
  workspace_id = var.workspace_id
  access       = var.access
}
