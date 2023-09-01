<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_transfer_server.transfer_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_server) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_allocation_ids"></a> [address\_allocation\_ids](#input\_address\_allocation\_ids) | List of Elastic IP addresses for the VPC endpoint | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The domain used by the Transfer Family server. Choices are: SFTP, FTP, FTPS. Default is SFTP. | `string` | `"SFTP"` | no |
| <a name="input_endpoint_details"></a> [endpoint\_details](#input\_endpoint\_details) | The VPC endpoint settings that are configured for your server | `any` | `null` | no |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | The endpoint type for the Transfer Family server | `string` | `"VPC"` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all user data is deleted when the server is deleted | `bool` | `false` | no |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | Route53 Hosted Zone ID. Only required if using VPC\_ENDPOINT type. | `string` | `null` | no |
| <a name="input_identity_provider_type"></a> [identity\_provider\_type](#input\_identity\_provider\_type) | The mode of authentication for the server. Choices: SERVICE\_MANAGED, API\_GATEWAY. Default is SERVICE\_MANAGED. | `string` | `"SERVICE_MANAGED"` | no |
| <a name="input_invocation_role"></a> [invocation\_role](#input\_invocation\_role) | The Amazon Resource Name (ARN) of the role that allows the server to turn on Amazon CloudWatch logging. | `string` | `null` | no |
| <a name="input_logging_role"></a> [logging\_role](#input\_logging\_role) | A role that allows the server to monitor your user activity | `string` | `null` | no |
| <a name="input_protocols"></a> [protocols](#input\_protocols) | The protocols enabled for your server. Choices: SFTP, FTP, FTPS. Default is [SFTP]. | `list(string)` | <pre>[<br>  "SFTP"<br>]</pre> | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to associate with the Transfer Family server | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs to associate with the Transfer Family server | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | <pre>{<br>  "environment": "prod",<br>  "project": "SIEM Implementation",<br>  "team": "Security Team",<br>  "terraform": "true",<br>  "used_by": "ThinkStack"<br>}</pre> | no |
| <a name="input_url"></a> [url](#input\_url) | The endpoint URL of the Transfer Family server | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to associate with the Transfer Family server | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_transfer_server_arn"></a> [transfer\_server\_arn](#output\_transfer\_server\_arn) | The ARN (Amazon Resource Name) of the Transfer Family server. |
| <a name="output_transfer_server_endpoint"></a> [transfer\_server\_endpoint](#output\_transfer\_server\_endpoint) | The endpoint URL of the Transfer Family server. |
| <a name="output_transfer_server_host_key_fingerprint"></a> [transfer\_server\_host\_key\_fingerprint](#output\_transfer\_server\_host\_key\_fingerprint) | The service-assigned ID of the Transfer Family server. |
| <a name="output_transfer_server_id"></a> [transfer\_server\_id](#output\_transfer\_server\_id) | The ID of the Transfer Family server. |
| <a name="output_transfer_server_logging_role"></a> [transfer\_server\_logging\_role](#output\_transfer\_server\_logging\_role) | A role in AWS Identity and Access Management that allows the server to monitor user activity. |
| <a name="output_transfer_server_tags"></a> [transfer\_server\_tags](#output\_transfer\_server\_tags) | The key-value pair that are assigned to the Transfer Family server. |
<!-- END_TF_DOCS -->