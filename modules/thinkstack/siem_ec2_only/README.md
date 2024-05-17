<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_instance.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_sg_id"></a> [additional\_sg\_id](#input\_additional\_sg\_id) | ID of additional security group to be added | `any` | n/a | yes |
| <a name="input_ami"></a> [ami](#input\_ami) | ID of AMI to use for the instance | `string` | n/a | yes |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | If true, the EC2 instance will have associated public IP address | `bool` | `false` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The AZ to start the instance in | `string` | n/a | yes |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | (Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection. | `bool` | `true` | no |
| <a name="input_flow_cloudwatch_name_prefix"></a> [flow\_cloudwatch\_name\_prefix](#input\_flow\_cloudwatch\_name\_prefix) | (Optional, Forces new resource) Creates a unique name beginning with the specified prefix. | `string` | `"flow_logs_"` | no |
| <a name="input_flow_cloudwatch_retention_in_days"></a> [flow\_cloudwatch\_retention\_in\_days](#input\_flow\_cloudwatch\_retention\_in\_days) | (Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `365` | no |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | (Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled. | `string` | `"enabled"` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | (Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional. | `string` | `"required"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | `string` | `"siem-ssm-service-role"` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | (Optional, Forces new resource) The name of the role. If omitted, Terraform will assign a random, unique name. | `string` | `"siem-ssm-service-role"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances to launch | `number` | `1` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | (Optional) Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances. See Shutdown Behavior for more information. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior | `string` | `"stop"` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | A tenancy option for instances launched into the VPC | `string` | `"default"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance to start | `string` | `"t3a.medium"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The key name to use for the instance | `string` | n/a | yes |
| <a name="input_log_volume_device_name"></a> [log\_volume\_device\_name](#input\_log\_volume\_device\_name) | (Required) The device name to expose to the instance (for example, /dev/sdh or xvdh). See Device Naming on Linux Instances and Device Naming on Windows Instances for more information. | `string` | `"/dev/sdf"` | no |
| <a name="input_log_volume_size"></a> [log\_volume\_size](#input\_log\_volume\_size) | (Optional) The size of the drive in GiBs. | `string` | `300` | no |
| <a name="input_log_volume_type"></a> [log\_volume\_type](#input\_log\_volume\_type) | (Optional) The type of volume. Can be standard, gp2, or io1. (Default: standard) | `string` | `"gp3"` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | should be false if you do not want to auto-assign public IP on launch | `bool` | `false` | no |
| <a name="input_mgmt_cidr_blocks"></a> [mgmt\_cidr\_blocks](#input\_mgmt\_cidr\_blocks) | (Requirerd) Security group allowed cidr blocks which will allow sending traffic to the SIEM collector | `list(any)` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier | `string` | `"siem_chronicle"` | no |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | The Placement Group to start the instance in | `string` | `""` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address to associate with the instance in a VPC | `string` | `"10.77.1.70"` | no |
| <a name="input_private_subnets_list"></a> [private\_subnets\_list](#input\_private\_subnets\_list) | A list of private subnets inside the VPC. | `list(string)` | <pre>[<br>  "10.77.1.64/26",<br>  "10.77.1.192/26"<br>]</pre> | no |
| <a name="input_root_delete_on_termination"></a> [root\_delete\_on\_termination](#input\_root\_delete\_on\_termination) | (Optional) Whether the volume should be destroyed on instance termination (Default: true) | `string` | `true` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | (Optional) The size of the volume in gigabytes. | `string` | `"100"` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | (Optional) The type of volume. Can be standard, gp2, or io1. (Default: standard) | `string` | `"gp3"` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | Description of the security group | `string` | `"SIEM Collector Security Group"` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name of the security group used for SIEM | `string` | `"siem_collector_sg"` | no |
| <a name="input_sg_cidr_blocks"></a> [sg\_cidr\_blocks](#input\_sg\_cidr\_blocks) | (Requirerd) Security group allowed cidr blocks which will allow sending traffic to the SIEM collector | `list(any)` | n/a | yes |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. | `bool` | `true` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The VPC Subnet ID to launch in | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | <pre>{<br>  "backup": "true",<br>  "created_by": "Your Name",<br>  "environment": "prod",<br>  "project": "SIEM Implementation",<br>  "service": "soc",<br>  "team": "Security Team",<br>  "terraform": "true",<br>  "used_by": "ThinkStack"<br>}</pre> | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user\_data\_base64 instead. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The CIDR block for the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | List of IDs of instances |
| <a name="output_primary_network_interface_id"></a> [primary\_network\_interface\_id](#output\_primary\_network\_interface\_id) | List of IDs of the primary network interface of instances |
| <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns) | List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | List of private IP addresses assigned to the instances |
| <a name="output_public_dns"></a> [public\_dns](#output\_public\_dns) | List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | List of public IP addresses assigned to the instances, if applicable. |
<!-- END_TF_DOCS -->