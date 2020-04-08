
# VPC Peering Connection Accepter
Utilized to create a VPC Peering Connection Accepter

# Usage
    module "vpc_peer_accepter" {
      source                          = "github.com/thinkstack-co/terraform-modules//modules/aws/vpc_peering_connection_accepter"
      
      auto_accept                     = false
      vpc_peering_connection_id       = module.vpc_peering_connection.id
      tags                            = {
        terraform        = "yes"
        created_by       = "Zachary Hill"
        environment      = "prod"
        role             = "vpc_peering_connection"
      }
    }

# Variables
## Required
    vpc_peering_connection_id

## Optional
    auto_accept
    tags
    

# Outputs
    id
