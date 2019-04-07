
# Application Load Balancer
Utilized to create an Application Load Balancer

# Usage
    module "alb" {
      source          = "github.com/thinkstack-co/terraform-modules//modules/aws/alb"
      
      name            = "app_lb"
      internal        = false
      security_groups = ["${module.alb_sg.id}"]
      subnets         = "${module.vpn.private_subnet_ids}"
      
      tags            = {
        terraform   = "yes"
        created_by  = "Zachary Hill"
        environment = "prod"
        project     = "app_dev"
        role        = "application_load_balancer"
      }
    }

# Variables
## Required
    name
    security_groups
    subnets

## Optional
    access_logs_bucket
    access_logs_enabled
    access_logs_prefiix
    enable_deletion_protection
    enable_http2
    idle_timeout
    internal
    ip_address_type
    load_balancer_type
    tags

# Outputs
    dns_name
    id
