terraform {
  required_version = ">= 0.12.0"
}
resource "aws_dx_bgp_peer" "peer" {
  virtual_interface_id = var.interface_id
  address_family       = var.address_family
  bgp_asn              = var.bgp_asn
  amazon_address       = var.amazon_address
  bgp_auth_key         = var.bgp_auth_key 
  customer_address     = var.customer_address
}