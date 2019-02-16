EC2 Instance Module
=================

This module sets up an EC2 instance with the parameters specified. This module has root block devices modifiable


# Usage
    module "aws_prod_server1" {
      source            = "github.com/thinkstack-co/terraform-modules//modules/aws/ec2_instance"
      
      ami               = ""
      availability_zone = "${module.vpc.availability_zone[0]}"
      count             = 1
      dmz_subnet_id     = "${module.vpc.dmz_subnet_ids}"
      ebs_optimized     = true
      instance_type     = "c4.large"
      key_name          = "${module.keypair.key_name}"
      monitoring        = true
      lan0_private_ips  = ["10.11.1.20"]
      mgmt0_private_ips = ["10.11.21.20"]
      mgmt_subnet_id    = "${module.vpc.mgmt_subnet_ids}"
      name              = "aws_prod_silverpeak"
      private_subnet_id = "${module.vpc.private_subnet_ids}"
      region            = "us-east-1"
      root_volume_type  = "gp2"
      root_volume_size  = "100"
      
      tags              = {
        terraform        = "yes"
        created_by       = "Zachary Hill"
        environment      = "prod"
        role             = "silverpeak_sdwan"
        backup           = "true"
        hourly_retention = "7"
      }
      wan0_private_ips  = ["10.11.101.20"]
      vpc_id            = "${module.vpc.vpc_id}"
    }

# Variables
## Required
    ami
    region

## Optional

# Outputs
    n/a
