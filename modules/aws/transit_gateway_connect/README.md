# Usage
    module "transit_gateway_fw_connect" {
        source                  = "github.com/thinkstack-co/terraform-modules//modules/aws/transit_gateway_connect"

        transport_attachment_id = "module.prod_vpc_attachment.id"
        transit_gateway_id      = "module.transit_gateway.id"
    }
