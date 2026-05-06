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

| Name                                                                                                                      | Type     |
| ------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |

## Inputs

| Name                                                                              | Description                                                                                                                                                                                    | Type           | Default     | Required |
| --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ----------- | :------: |
| <a name="input_condition_field"></a> [condition_field](#input_condition_field)    | The name of the field. It must be 'path-pattern' for path-based routing or 'host-header' for host-based routing.                                                                               | `string`       | n/a         |   yes    |
| <a name="input_condition_values"></a> [condition_values](#input_condition_values) | The path patterns to match. A maximum of 1 can be defined.                                                                                                                                     | `list(string)` | n/a         |   yes    |
| <a name="input_listener_arn"></a> [listener_arn](#input_listener_arn)             | The ARN of the listener to attach the rule.                                                                                                                                                    | `string`       | n/a         |   yes    |
| <a name="input_priority"></a> [priority](#input_priority)                         | The priority for the rule between 1 and 50000. If unset, the next available priority after the current highest rule will be used. A listener can't have multiple rules with the same priority. | `number`       | `null`      |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                     | A mapping of tags to assign to the resource                                                                                                                                                    | `map(string)`  | `{}`        |    no    |
| <a name="input_target_group_arn"></a> [target_group_arn](#input_target_group_arn) | The ARN of the Target Group to which to route traffic.                                                                                                                                         | `string`       | n/a         |   yes    |
| <a name="input_type"></a> [type](#input_type)                                     | (Required) Type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc.                                                             | `string`       | `"forward"` |    no    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
