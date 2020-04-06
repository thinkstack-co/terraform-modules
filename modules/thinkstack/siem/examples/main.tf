################################################################################################################################
# SIEM Modules
################################################################################################################################

module "siem" {
  source                = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/siem?ref=dev_v0_12_module_upgrade"
  
  ami                   = var.centos_ami[var.aws_region]
  created_by            = "Zachary Hill"
  public_key            = "ssh-rsa IAMFAKE2478147921389jhkfdjskafdjklsfajdjslafdjksafljdsajkfdsjklafjdshhr32bn=="
  region                = var.aws_region
  sg_cidr_blocks        = ["192.168.1.0/24", "10.1.1.0/24", "10.11.0.0/16"]
  
  customer_gw_name      = ["hq_edge"]
  vpn_peer_ip_address   = ["1.1.1.1"]
  vpn_route_cidr_blocks = ["192.168.1.0/24"]
  
  enable_vpc_peering    = true
  peer_vpc_ids          = ["vpc-insertiddhere"]
  peer_vpc_subnet       = "10.11.0.0/16"
  
  tags                  = {
      created_by  = "Zachary Hill"
      terraform   = "true"
      environment = "prod"
      project     = "SIEM Implementation"
      team        = "Security Team"
      used_by     = "ThinkStack"
  }
}
