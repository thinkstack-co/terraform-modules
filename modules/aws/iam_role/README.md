# Usage
    module "iam_role" {
      source           = "github.com/thinkstack-co/terraform-modules//modules/aws/iam_role"
      
      assume_role_policy = ""
      description = "Role used for a test"
      name = "test_role"

# Variables
## Required
    assume_role_policy
    name

## Optional
    description
    force_detatch_policies
    max_session_duration
    permissions_boundary

# Outputs
    n/a
