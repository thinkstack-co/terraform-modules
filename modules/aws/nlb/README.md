
# Network Load Balancer
Utilized to create an Network Load Balancer

# Usage
    module "nlb" {
      source          = "github.com/thinkstack-co/terraform-modules//modules/aws/nlb"
      
      name            = "app_network_lb"
      subnets         = "${module.vpn.private_subnet_ids}"
      
      tags            = {
        terraform   = "yes"
        created_by  = "Zachary Hill"
        environment = "prod"
        project     = "app_dev"
        role        = "network_load_balancer"
      }
    }

# Variables
## Required
    name
    subnets

## Optional
    enable_deletion_protection
    enable_cross_zone_load_balancing
    internal
    ip_address_type
    load_balancer_type
    tags

# Outputs
    dns_name
    id
