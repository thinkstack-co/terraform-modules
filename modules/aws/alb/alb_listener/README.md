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
| [aws_alb_listener.listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_load_balancer_arn"></a> [load\_balancer\_arn](#input\_load\_balancer\_arn) | (Required) The ARN of the Target Group to which to route traffic. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | (Optional) Port on which the load balancer is listening. Not valid for Gateway Load Balancers. | `number` | `80` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (Optional) The protocol for connections from clients to the load balancer. Valid values are `TCP`, `HTTP`, and `HTTPS`. Defaults to `HTTP`. | `string` | `"HTTP"` | no |
| <a name="input_ssl_certificate"></a> [ssl\_certificate](#input\_ssl\_certificate) | (Optional) The ARN of the default SSL server certificate. Exactly one certificate is required if the protocol is HTTPS. For adding additional SSL certificates, see the `aws_lb_listener_certificate` resource. | `string` | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | (Optional) The name of the SSL Policy for the listener. Required if `protocol` is `HTTPS`. | `string` | n/a | yes |
| <a name="input_stickiness_duration"></a> [stickiness\_duration](#input\_stickiness\_duration) | (Required) Time period, in seconds, during which requests from a client should be routed to the same target group. The range is 1-604800 seconds (7 days). | `number` | `6000` | no |
| <a name="input_stickiness_enabled"></a> [stickiness\_enabled](#input\_stickiness\_enabled) | (Optional) Whether target group stickiness is enabled. Default is false. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | List of target groups | <pre>list(object({<br>    arn    = string<br>    weight = number<br>  }))</pre> | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | (Required) Type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc. | `string` | `"forward"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->