Directory Services MicrosoftAD Module
=====================================

This module sets up the MicrosoftAD within AWS Directory Services. This can later be used to domain join instances or run your entire domain off of. This includes a Microsoft Active Directory which requires AD management software in order to manage.

# Usage
    module "ad_connector" {
    source              = "github.com/thinkstack-co/terraform-modules//modules/aws/directory_service_microsoftad?ref=v0.17.0"

    alias               = "ad.corp.com"
    description         = "ad.corp.com adconnector"
    edition             = "Standard"
    enable_sso          = false
    name                = "ad.corp.com"
    password            = var.ad_connector_password
    short_name          = "CORP"
    size                = "Small"
    subnet_ids          = [module.vpc.private_subnet.ids]
    tags                = {
        created_by  = "Zachary Hill"
        environment = "prod"
        terraform   = "true"
    }
    type                = "MicrosoftAD"
    vpc_id              = module.vpc.id
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
