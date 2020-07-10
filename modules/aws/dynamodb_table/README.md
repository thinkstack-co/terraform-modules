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
| attribute | (Required) List of nested attribute definitions. Only required for hash\_key and range\_key attributes. Each attribute has two properties: name - (Required) The name of the attribute. type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data | `list` | n/a | yes |
| global\_secondary\_index | (Optional) Describe a GSO for the table; subject to the normal limits on the number of GSIs, projected attributes, etc. | `map` | `{}` | no |
| hash\_key | (Required, Forces new resource) The attribute to use as the hash (partition) key. Must also be defined as an attribute, see below. | `string` | n/a | yes |
| local\_secondary\_index | (Optional, Forces new resource) Describe an LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource. | `maps` | `{}` | no |
| name | (Required) The name of the table, this needs to be unique within a region. | `string` | n/a | yes |
| point\_in\_time\_recovery | (Optional) Point-in-time recovery options. | `map` | <pre>{<br>  "enabled": false<br>}</pre> | no |
| range\_key | (Optional, Forces new resource) The attribute to use as the range (sort) key. Must also be defined as an attribute, see below. | `string` | n/a | yes |
| read\_capacity | (Required) The number of read units for this table | `string` | n/a | yes |
| server\_side\_encryption | (Optional) Encrypt at rest options. | `map` | <pre>{<br>  "enabled": true<br>}</pre> | no |
| stream\_enabled | (Optional) Indicates whether Streams are to be enabled (true) or disabled (false). | `string` | n/a | yes |
| tags | (Optional) A map of tags to populate on the created table. | `map` | `{}` | no |
| ttl | (Optional) Defines ttl, has two properties, and can only be specified once: enabled - (Required) Indicates whether ttl is enabled (true) or disabled (false). attribute\_name - (Required) The name of the table attribute to store the TTL timestamp in. | `map` | `{}` | no |
| write\_capacity | (Required) The number of write units for this table | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| arn | n/a |
| id | n/a |
| stream\_arn | n/a |
| stream\_label | n/a |