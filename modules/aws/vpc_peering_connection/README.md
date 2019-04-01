
# VPC Peering Connection
Utilized to create a VPC Peering Connection

# Usage
    module "vpc_peer" {
      source                          = "github.com/thinkstack-co/terraform-modules//modules/aws/vpc_peering_connection"
      
      allow_remote_vpc_dns_resolution = true
      auto_accept                     = true
      peer_owner_id                   = "11111111"
      peer_region                     = "us-east-1"
      peer_vpc_id                     = "vpc-111111111"
      vpc_id                          = "vpc-222222222"
      
      tags                            = {
        terraform        = "yes"
        created_by       = "Zachary Hill"
        environment      = "prod"
        role             = "vpc_peering_connection"
      }
    }

# Variables
## Required
    peer_vpc_id
    vpc_id
    tags

## Optional
    allow_remote_vpc_dns_resolution
    auto_accept
    peer_owner_id
    peer_region

# Outputs
    accept_status
    id
