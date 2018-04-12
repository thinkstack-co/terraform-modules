Directory Services ADConnector Module
=====================================

This module sets up the ADConnector within AWS Directory Services. This can later be used to domain join instances.

# Usage
    module "ad_connector" {
        source = ""

        alias       = "ad.corp.com"
        customer_dns_ips = ["10.11.1.100", "10.11.2.100"]
        customer_username = "svc_aws_adconnector"
        description = "ad.corp.com adconnector"
        name        = "ad.corp.com"
        password    = "UseAVariableForPasswords"
        size        = "Small"
        subnet_ids  = ["${module.vpc.private_subnet.id}"]
        tags        = {
            created_by = "Zachary Hill"
            terraform = "true"
        }
        type        = "ADConnector"
        vpc_id      = "${module.vpc.id}"
    }

# Variables
## Required
    customer_dns_ips
    customer_username
    name
    password
    size
    subnet_ids
    vpc_id

# Outputs
    id
