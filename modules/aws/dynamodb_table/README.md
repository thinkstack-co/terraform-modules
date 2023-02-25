# Usage
    module "aws_prod_dynamodb" {
      source              = "github.com/thinkstack-co/terraform-modules//modules/aws/dynamodb_table"
      
      
      tags                = {
        terraform        = "true"
        created_by       = "YOUR NAME"
        environment      = "prod"
      }
    }


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attribute"></a> [attribute](#input\_attribute) | (Required) List of nested attribute definitions. Only required for hash\_key and range\_key attributes. Each attribute has two properties: name - (Required) The name of the attribute. type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data | `list` | n/a | yes |
| <a name="input_enable_point_in_time_recovery"></a> [enable\_point\_in\_time\_recovery](#input\_enable\_point\_in\_time\_recovery) | (Optional) Whether to enable point-in-time recovery. It can take 10 minutes to enable for new tables. If the point\_in\_time\_recovery block is not provided, this defaults to false. | `bool` | `true` | no |
| <a name="input_global_secondary_index"></a> [global\_secondary\_index](#input\_global\_secondary\_index) | (Optional) Describe a GSO for the table; subject to the normal limits on the number of GSIs, projected attributes, etc. | `map` | `{}` | no |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | (Required, Forces new resource) The attribute to use as the hash (partition) key. Must also be defined as an attribute, see below. | `string` | n/a | yes |
| <a name="input_local_secondary_index"></a> [local\_secondary\_index](#input\_local\_secondary\_index) | (Optional, Forces new resource) Describe an LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource. | `map` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the table, this needs to be unique within a region. | `string` | n/a | yes |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | (Optional, Forces new resource) The attribute to use as the range (sort) key. Must also be defined as an attribute, see below. | `string` | n/a | yes |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | (Required) The number of read units for this table | `string` | n/a | yes |
| <a name="input_server_side_encryption"></a> [server\_side\_encryption](#input\_server\_side\_encryption) | (Optional) Encrypt at rest options. | `map` | <pre>{<br>  "enabled": true<br>}</pre> | no |
| <a name="input_stream_enabled"></a> [stream\_enabled](#input\_stream\_enabled) | (Optional) Indicates whether Streams are to be enabled (true) or disabled (false). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to populate on the created table. | `map` | `{}` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | (Optional) Defines ttl, has two properties, and can only be specified once: enabled - (Required) Indicates whether ttl is enabled (true) or disabled (false). attribute\_name - (Required) The name of the table attribute to store the TTL timestamp in. | `map` | `{}` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | (Required) The number of write units for this table | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | n/a |
| <a name="output_stream_label"></a> [stream\_label](#output\_stream\_label) | n/a |
<!-- END_TF_DOCS -->