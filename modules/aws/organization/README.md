# AWS Organization Module
This module generates and manages an AWS Organization

# Usage

    module "thinkstack_organization" {
        source    = "github.com/thinkstack-co/terraform-modules//modules/aws/organization"
        
        name      = "client_prod_infrastructure"
        email     = "aws_environments+client@thinkstack.co"
        parent_id = var.clients_parent_id
    }
