
# Interfaces
 - wan0 - Typically behind a firewall NATing the public IP address to a DMZ IP address
 - lan0 - Typically on the private/server subnet
 - mgmt0 - Typically set in a mgmt subnet

# Usage
    module "aws_prod_silverpeak" {
      source            = "github.com/thinkstack-co/terraform-modules//modules/aws/silverpeak"
      
      ami               = "ami-b7f895cf"
      availability_zone = module.vpc.availability_zone[0]
      count             = 1
      dmz_subnet_id     = module.vpc.dmz_subnet_ids
      ebs_optimized     = true
      instance_type     = "c4.large"
      key_name          = module.keypair.key_name
      monitoring        = true
      lan0_private_ips  = ["10.11.1.20"]
      mgmt0_private_ips = ["10.11.21.20"]
      mgmt_subnet_id    = module.vpc.mgmt_subnet_ids
      name              = "aws_prod_silverpeak"
      private_subnet_id = module.vpc.private_subnet_ids
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
      vpc_id            = module.vpc.vpc_id
    }

# Variables
## Required
    ami 

## Optional

# Outputs
    n/a
