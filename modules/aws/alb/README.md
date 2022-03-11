Application Load Balancer Module
=================

This module sets up an Application Load Balancer with the parameters specified.


# Usage
        module "app_server" {
        source                 = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance"
            
        name  
        
        tags                   = {
            terraform   = "yes"
            created_by  = "terraform"
            environment = "prod"
            role        = "app_server"
            backup      = "true"
            hourly_retention    = "7"
        }
    }

    module "app_server_d_drive" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/ebs_volume"

        availability_zone   = module.vpc.availability_zone[0]
        size                = "50"
        device_name         = "xvdb"
        instance_id         = module.app_server.id[0]
        tags                = {
            Name        = "app_server"
            os_drive    = "d"
            device_name = "xvdb"
            terraform   = "yes"
            created_by  = "terraform"
            environment = "prod"
            role        = "app_server"
            backup      = "true"
        }
    }

# Variables
## Required
    access_logs_bucket
    name
    security_groups
    subnets

## Optional
    access_logs_enabled
    access_logs_prefix
    enable_cross_zone_load_balancing
    enable_deletion_protection
    enable_http2
    idle_timeout
    internal
    ip_address_type
    load_balancer_type
    number


# Outputs
    n/a
