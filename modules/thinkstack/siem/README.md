ThinkStack SIEM Module
=====================================

This module sets up all of the necesarry components for the ThinkStack SIEM security platform.

# Usage
    module "siem" {
        source                = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/siem?ref=dev_v0_12_module_upgrade"

        ami                   = var.centos_ami[var.aws_region]
        created_by            = "Zachary Hill"
        public_key            = "ssh-rsa IAMFAKE2478147921389jhkfdjskafdjklsfajdjslafdjksafljdsajkfdsjklafjdshhr32bn=="
        sg_cidr_blocks        = ["192.168.1.0/24", "10.1.1.0/24", "10.11.0.0/16"]

        customer_gw_name      = ["hq_edge"]
        vpn_peer_ip_address   = ["1.1.1.1"]
        vpn_route_cidr_blocks = ["192.168.1.0/24"]

        enable_vpc_peering    = true
        peer_vpc_ids          = ["vpc-insertiddhere"]
        peer_vpc_subnet       = "10.11.0.0/16"

        tags       = {
            created_by  = "Zachary Hill"
            terraform   = "true"
            environment = "prod"
            project     = "SIEM Implementation"
            team        = "Security Team"
            used_by     = "ThinkStack"
        }
    }

# Variables
## Required
    ami
    created_by
    customer_gw_name
    enable_vpc_peering
    public_key
    sg_cidr_blocks
    vpn_peer_ip_address
    vpn_route_cidr_blocks

## Optional
    associate_public_ip_address
    azs
    bgp_asn
    disable_api_termination
    ebs_optimized
    enable_dns_hostnames
    enable_dns_support
    enable_nat_gateway
    enable_vpc_peering
    encrypted
    iam_instance_profile
    iam_role_name
    instance_count
    instance_initiated_shutdown_behavior
    instance_type
    instance_tenancy
    ipv6_address_count
    ipv6_addresses
    key_name_prefix
    log_volume_device_name
    log_volume_size
    log_volume_type
    map_public_ip_on_launch
    monitoring
    name
    placement_group
    pricate_ip
    private_propagating_vgws
    private_subnets_list
    public_propagating_vgws
    public_subnets_list
    root_delete_on_termination
    root_volume_size
    root_volume_type
    security_group_description
    security_group_name
    single_nat_gateway
    source_dest_check
    static_routes_only
    tags
    tenancy
    vpc_cidr
    vpn_type
    allow_remote_vpc_dns_resolution
    auto_accept
    peer_owner_id
    peer_region
    peer_vpc_ids
    Peer_vpc_subnet

# Outputs
    private_subnet_ids
