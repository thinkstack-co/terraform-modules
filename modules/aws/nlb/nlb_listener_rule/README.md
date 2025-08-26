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
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_condition_field"></a> [condition\_field](#input\_condition\_field) | The name of the field. It must be 'path-pattern' for path-based routing or 'host-header' for host-based routing. | `string` | n/a | yes |
| <a name="input_condition_values"></a> [condition\_values](#input\_condition\_values) | The path patterns to match. A maximum of 1 can be defined. | `list(string)` | n/a | yes |
| <a name="input_listener_arn"></a> [listener\_arn](#input\_listener\_arn) | The ARN of the listener to attach the rule. | `string` | n/a | yes |
| <a name="input_priority"></a> [priority](#input\_priority) | The priority for the rule between 1 and 50000. If unset, the next available priority after the current highest rule will be used. A listener can't have multiple rules with the same priority. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | The ARN of the Target Group to which to route traffic. | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | (Required) Type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc. | `string` | `"forward"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
