# Usage
    module "destination_name_transit_gateway_route" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/transit_gateway_route"

        # Destination Name Comment
        destination_cidr_block         = "192.168.0.0/16"
        transit_gateway_attachment_id  = module.transit_gateway_attachment.id
        transit_gateway_route_table_id = module.transit_gateway.propagation_default_route_table_id
    }

# Requirements

No requirements.

# Providers

| Name | Version |
|------|---------|
| aws | n/a |

# Inputs
    blackhole
    destination_cidr_block
    transit_gateway_attachment_id
    transit_gateway_route_table_id

    ## Required
        destination_cidr_block
        transit_gateway_route_table_id

    ## Optional
        blackhole
        transit_gateway_attachment_id

    
# Outputs
    n/a