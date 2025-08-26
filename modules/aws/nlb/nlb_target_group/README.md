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
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_health_check_interval_seconds"></a> [health\_check\_interval\_seconds](#input\_health\_check\_interval\_seconds) | The approximate amount of time, in seconds, between health checks of an individual target. The range is 5–300 seconds. The default is 30 seconds if the target type is instance or ip and 35 seconds if the target type is lambda. | `number` | `30` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The destination for health checks on the targets. If the protocol version is HTTP/1.1 or HTTP/2, specify a valid URI (/path?query). The default is /. If the protocol version is gRPC, specify the path of a custom health check method with the format /package.service/method. The default is /AWS.ALB/healthcheck. | `string` | `"/"` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | The port the load balancer uses when performing health checks on targets. The default is to use the port on which each target receives traffic from the load balancer. | `string` | `"traffic-port"` | no |
| <a name="input_health_check_protocol"></a> [health\_check\_protocol](#input\_health\_check\_protocol) | The protocol the load balancer uses when performing health checks on targets. The possible protocols are HTTP and HTTPS. The default is the HTTP protocol. | `string` | `"HTTP"` | no |
| <a name="input_health_check_timeout_seconds"></a> [health\_check\_timeout\_seconds](#input\_health\_check\_timeout\_seconds) | The amount of time, in seconds, during which no response from a target means a failed health check. The range is 2–120 seconds. The default is 5 seconds if the target type is instance or ip and 30 seconds if the target type is lambda. | `number` | `5` | no |
| <a name="input_healthy_threshold_count"></a> [healthy\_threshold\_count](#input\_healthy\_threshold\_count) | The number of consecutive successful health checks required before considering an unhealthy target healthy. The range is 2–10. The default is 5. | `number` | `5` | no |
| <a name="input_matcher"></a> [matcher](#input\_matcher) | The codes to use when checking for a successful response from a target. If the protocol version is HTTP/1.1 or HTTP/2, the possible values are from 200 to 499. You can specify multiple values or a range of values. The default value is 200. If the protocol version is gRPC, the possible values are from 0 to 99. You can specify multiple values or a range of values. The default value is 12. | `string` | `"200"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the target group. If omitted, Terraform will assign a random, unique name. Forces new resource. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | Port on which targets receive traffic, unless overridden when registering a specific target. Required when `target_type` is `instance` or `ip`. Does not apply when `target_type` is `lambda`. | `number` | `80` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (May be required, Forces new resource) Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP\_UDP, TLS, or UDP. Required when target\_type is instance, ip or alb. Does not apply when target\_type is lambda. | `string` | `"TCP"` | no |
| <a name="input_proxy_protocol_v2"></a> [proxy\_protocol\_v2](#input\_proxy\_protocol\_v2) | (Optional) Whether to enable support for proxy protocol v2 on Network Load Balancers. See doc for more information. Default is false. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | The ARN of the target group with which to register targets. | `string` | n/a | yes |
| <a name="input_target_id"></a> [target\_id](#input\_target\_id) | The ID of the target. This is the Instance ID for an instance, or the container ID for an ECS container. If the target type is ip, specify an IP address | `string` | n/a | yes |
| <a name="input_target_type"></a> [target\_type](#input\_target\_type) | Type of target that you must specify when registering targets with this target group. The possible values are `instance` (targets are specified by instance ID) or `ip` (targets are specified by IP address) or `lambda` (targets are specified by lambda arn). Note that you can't specify targets for a target group using both instance IDs and IP addresses. If the target type is `ip`, specify IP addresses from the subnets of the virtual private cloud (VPC) for the target group. You can't specify publicly routable IP addresses.  If the target type is alb, specify the arn of alb. | `string` | `"instance"` | no |
| <a name="input_unhealthy_threshold_count"></a> [unhealthy\_threshold\_count](#input\_unhealthy\_threshold\_count) | The number of consecutive failed health checks required before considering a target unhealthy. The range is 2–10. The default is 2. | `number` | `2` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The identifier of the virtual private cloud (VPC) that the target group belongs to. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | The ARN of the Target Group |
| <a name="output_target_group_attachment_arn"></a> [target\_group\_attachment\_arn](#output\_target\_group\_attachment\_arn) | The ARN of the Target Group to which the attachment is associated |
<!-- END_TF_DOCS -->
