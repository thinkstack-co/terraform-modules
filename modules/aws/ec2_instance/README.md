EC2 Instance Module
=================

This module sets up an EC2 instance with the parameters specified. This module has root block devices modifiable


# Usage
        module "app_server" {
        source                 = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance"
            
        name                   = "app_server"
        ami                    = "ami-ffffffff"
        count                  = 1
        availability_zone      = module.vpc.availability_zone[0]
        subnet_id              = module.vpc.private_subnet_ids[0]
        instance_type          = "t2.large"
        key_name               = module.keypair.key_name
        vpc_security_group_ids = module.app_server_sg.id
        region                 = "us-east-1"
        root_volume_type       = "gp2"
        root_volume_size       = "100"

        volume_tags            = {
            os_drive    = "c"
            device_name = "/dev/sda1"
            terraform   = "yes"
            created_by  = "terraform"
            environment = "prod"
            role        = "app_server"
            backup      = "true"
        }
        
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
    ami
    region

## Optional

# Outputs
    n/a
