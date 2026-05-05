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

| Name                                                                                                                | Type     |
| ------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_lb_listener.listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |

## Inputs

| Name                                                                                 | Description                                                                                                                                                                                                           | Type                                                                  | Default     | Required |
| ------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ----------- | :------: |
| <a name="input_action_type"></a> [action_type](#input_action_type)                   | (Required) Type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc.                                                                                    | `string`                                                              | `"forward"` |    no    |
| <a name="input_load_balancer_arn"></a> [load_balancer_arn](#input_load_balancer_arn) | (Required, Forces New Resource) ARN of the load balancer.                                                                                                                                                             | `string`                                                              | n/a         |   yes    |
| <a name="input_port"></a> [port](#input_port)                                        | (Optional) Port on which the load balancer is listening. Not valid for Gateway Load Balancers.                                                                                                                        | `number`                                                              | `80`        |    no    |
| <a name="input_protocol"></a> [protocol](#input_protocol)                            | For Network Load Balancers, valid values are TCP, TLS, UDP, and TCP_UDP. Not valid to use UDP or TCP_UDP if dual-stack mode is enabled.                                                                               | `string`                                                              | `"TCP"`     |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                        | A mapping of tags to assign to the resource                                                                                                                                                                           | `map(string)`                                                         | `{}`        |    no    |
| <a name="input_target_group_arn"></a> [target_group_arn](#input_target_group_arn)    | (Optional) The ARN of the Target Group to which to route traffic. Specify only if type is forward and you want to route to a single target group. To route to one or more target groups, use a forward block instead. | `string`                                                              | `null`      |    no    |
| <a name="input_target_groups"></a> [target_groups](#input_target_groups)             | List of target groups                                                                                                                                                                                                 | <pre>list(object({<br> arn = string<br> weight = number<br> }))</pre> | `[]`        |    no    |

## Outputs

| Name                                                                                                              | Description                                                     |
| ----------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| <a name="output_listener_arn"></a> [listener_arn](#output_listener_arn)                                           | The ARN of the Listener                                         |
| <a name="output_listener_load_balancer_arn"></a> [listener_load_balancer_arn](#output_listener_load_balancer_arn) | The ARN of the Load Balancer to which this listener is attached |

<!-- END_TF_DOCS -->
