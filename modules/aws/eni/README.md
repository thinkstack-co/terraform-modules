## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attachment | Attachment block for assigning the eni to an instance | `list` | `[]` | no |
| device\_index | eni index to attach the eni to on the instance | `any` | n/a | yes |
| instance\_id | instance ID to attach to the eni | `any` | n/a | yes |
| private\_ips | Private IP to assign to the eni | `list` | `[]` | no |
| private\_ips\_count | Number of private IPs to assign to the eni | `number` | `1` | no |
| security\_groups | Security groups to assign to the eni | `list` | `[]` | no |
| source\_dest\_check | Whether to enable source destination checking for the eni | `bool` | `true` | no |
| subnet\_id | Subnet ID to create the eni in | `string` | n/a | yes |
| tags | tags to assign to the eni | `map` | n/a | yes |

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
