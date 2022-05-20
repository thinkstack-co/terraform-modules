# Usage

    module "example_team_access" {
        source       = "github.com/thinkstack-co/terraform-modules//modules/terraform/team_access"

        team_id      = "team-id"
        workspace_id = "workspace-id"
        access       = "read"
    }
