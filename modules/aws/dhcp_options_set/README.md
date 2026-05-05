<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.0.0 |

## Providers

| Name                                             | Version  |
| ------------------------------------------------ | -------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                | Type     |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_vpc_dhcp_options.dc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options)                         | resource |
| [aws_vpc_dhcp_options_association.dc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |

## Inputs

| Name                                                                                       | Description                                                 | Type           | Default                                                                                                                                                                                     | Required |
| ------------------------------------------------------------------------------------------ | ----------------------------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_domain_name"></a> [domain_name](#input_domain_name)                         | Define the domain name for the DHCP Options Set             | `string`       | `null`                                                                                                                                                                                      |    no    |
| <a name="input_domain_name_servers"></a> [domain_name_servers](#input_domain_name_servers) | List of IP addresses for the DNS servers                    | `list(string)` | <pre>[<br> "10.11.1.100",<br> "10.11.2.100"<br>]</pre>                                                                                                                                      |    no    |
| <a name="input_enable_dhcp_options"></a> [enable_dhcp_options](#input_enable_dhcp_options) | (Optional) boolean to determine if DHCP options are enabled | `bool`         | `true`                                                                                                                                                                                      |    no    |
| <a name="input_ntp_servers"></a> [ntp_servers](#input_ntp_servers)                         | List of IP addresses for the NTP servers                    | `list(string)` | <pre>[<br> "10.11.1.100",<br> "10.11.2.100"<br>]</pre>                                                                                                                                      |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                              | (Optional) A mapping of tags to assign to the object.       | `map`          | <pre>{<br> "Name": "prod_dhcp_options_set",<br> "created_by": "ThinkStack",<br> "description": "DHCP Option Set for the VPC",<br> "environment": "prod",<br> "terraform": "true"<br>}</pre> |    no    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                        | ID of the VPC to attach the DHCP Options Set to             | `string`       | `null`                                                                                                                                                                                      |    no    |

## Outputs

| Name                                                                             | Description |
| -------------------------------------------------------------------------------- | ----------- |
| <a name="output_dhcp_options_id"></a> [dhcp_options_id](#output_dhcp_options_id) | n/a         |

<!-- END_TF_DOCS -->
