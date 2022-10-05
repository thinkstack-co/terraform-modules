# Usage
    module "transit_gateway_fw_connect_peer" {
        source                        = "github.com/thinkstack-co/terraform-modules//modules/aws/transit_gateway_connect_peer"

        bgp_asn                       = 64513
        inside_cidr_blocks            = 
        name                          = "sdwan_peer"
        peer_address                  = 
        transit_gateway_address       = 
        transit_gateway_attachment_id = 
    }
