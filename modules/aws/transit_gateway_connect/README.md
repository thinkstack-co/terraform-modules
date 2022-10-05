# Usage
    module "transit_gateway_sdwan_connect" {
        source                  = "github.com/thinkstack-co/terraform-modules//modules/aws/transit_gateway_connect"

        name                    = "tgw_sdwan_connect"
        transport_attachment_id = "module.prod_vpc_attachment.id"
        transit_gateway_id      = "module.transit_gateway.id"
    }
