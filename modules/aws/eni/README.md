## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| description | (Required) A description for the network interface. | `string` | n/a | yes |
| device\_index | (Required) Integer to define the devices index. | `number` | n/a | yes |
| instance | (Required) ID of the instance to attach to. | `string` | n/a | yes |
| private\_ips | (Optional) List of private IPs to assign to the ENI. | `list` | `[]` | no |
| private\_ips\_count | (Optional) Number of secondary private IPs to assign to the ENI. The total number of private IPs will be 1 + private_ips_count, as a primary private IP will be assiged to an ENI by default. | `number` | `1` | no |
| security\_groups | (Required) List of security group IDs to assign to the ENI. | `list` | n/a | yes |
| source\_dest\_check | (Optional) Whether to enable source destination checking for the ENI. Default true. | `bool` | `true` | no |
| subnet\_id | (Required) Subnet ID to create the ENI in. | `string` | n/a | yes |
| tags | (Optional) A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| attachment | n/a |
| description | n/a |
| private\_ips | n/a |
| security\_groups | n/a |
| source\_dest\_check | n/a |
| subnet\_id | n/a |
| tags | n/a |
