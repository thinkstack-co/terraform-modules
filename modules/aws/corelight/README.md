# Corelight Collector
Utilized to deploy a corelight collector

# Interfaces
- eth0 - Collecto listener. Send VPC Mirror traffic to this interface
- eth1 - Management

# Usage
    module "aws_prod_corelight" {
      source              = "github.com/thinkstack-co/terraform-modules//modules/aws/corelight"
      
      ami                 = "ami-b7f895cffdsaaafdsa"
      availability_zones  = [module.vpc.availability_zone[0], module.vpc.availability_zone[1]]
      number              = 2
      listener_subnet_ids = module.vpc.private_subnet_ids
      mgmt_subnet_ids     = module.vpc.mgmt_subnet_ids
      name                = "aws_prod_corelight"
      region              = var.aws_region
      user_data           = "customer_id_key"
      vpc_id              = "vpc-222222222"
      vxlan_cidr_blocks   = ["10.44.1.1/32"]
      
      tags                = {
        terraform        = "true"
        created_by       = "Zachary Hill"
        environment      = "prod"
        role             = "corelight network monitor"
      }
    }

# Variables
## Required
    ami
    availability_zones
    listener_subnet_ids
    mgmt_subnet_ids
    region
    user_data
    vpc_id
    vxlan_cidr_blocks

## Optional
    associate_public_ip_address
    disable_api_termination
    ebs_optimized
    enable_deletion_protection
    encrypted
    iam_instance_profile
    internal
    instance_initiated_shutdown_behavior
    instance_type
    key_name
    listener_nic_description
    listener_nic_private_ips
    log_volume_device_name
    log_volume_size
    log_volume_type
    mgmt_cidr_blocks
    mgmt_nic_description
    mgmt_nic_private_ips
    monitoring
    name
    nlb_name
    number
    placement_group
    root_delete_on_termination
    root_volume_size
    root_volume_type
    sg_description
    sg_name
    source_dest_check
    tags
    tenancy

# Outputs
    availability_zone
    id
    private_ip
