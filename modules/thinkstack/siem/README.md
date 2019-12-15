ThinkStack SIEM Module
=====================================

This module sets up all of the necesarry components for the ThinkStack SIEM security platform.

# Usage
    module "siem" {
    source              = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/siem"
    alias               = "ad.corp.com"
    description         = "ad.corp.com adconnector"
    tags                = {
        created_by  = "Zachary Hill"
        environment = "prod"
        terraform   = "true"
    }
    }


# Variables
## Required
    name
    password
    short_name
    size
    subnet_ids
    vpc_id

# Outputs
    id
