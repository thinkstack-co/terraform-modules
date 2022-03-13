# Usage
    module "sdwan_vpc_transit_gateway_attachment" {
        source             = "github.com/thinkstack-co/terraform-modules//modules/aws/transit_gateway_attachment"

        name               = "sdwan_vpc_attachment"
        subnet_ids         = ["subnet-fdsjklafjlkds8421", "subnet-290102034fjkdsa"]
        transit_gateway_id = module.transit_gateway.id
        vpc_id             = "vpc-4289104jk21lsda"
    }

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| appliance\_mdoe\_support | (Optional) Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow. | `string` | `"disable"` | no |
| dns\_support | (Optional) Whether DNS support is enabled. | `string` | `"enable"` | no |
| ipv6\_support | (Optional) Whether IPv6 support is enabled. | `string` | `"disable"` | no |
| name | (Required) The name of the transit gateway attachment | `string` | n/a | yes |
| subnet\_ids | (Required) Identifiers of EC2 Subnets. | `list` | n/a | yes |
| tags | (Optional) Map of tags for the EC2 Transit Gateway. | `map` | <pre>{<br>  "environment": "prod",<br>  "project": "core_infrastructure",<br>  "terraform": "true"<br>}</pre> | no |
| transit\_gateway\_id | (Required) Identifier of EC2 Transit Gateway. | `string` | n/a | no |
| vpc\_id | (Required) Identifier of EC2 VPC. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| id | n/a |
| vpc\_owner\_id | n/a |