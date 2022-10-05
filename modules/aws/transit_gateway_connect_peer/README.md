# Usage
    module "transit_gateway_sdwan_connect_peer" {
        source                        = "github.com/thinkstack-co/terraform-modules//modules/aws/transit_gateway_connect_peer"

        bgp_asn                       = 64513
        inside_cidr_blocks            = 169.254.6.0/29
        name                          = "sdwan_peer"
        peer_address                  = 10.100.1.10
        transit_gateway_address       = 10.255.1.11
        transit_gateway_attachment_id = module.transit_gateway_sdwan_connect.id
    }
