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
| [aws_iam_role.ssm_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ssm_ec2_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssm_managed_instance_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_ssm_maintenance_window.maintenance_window_start](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window) | resource |
| [aws_ssm_maintenance_window.maintenance_window_stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window) | resource |
| [aws_ssm_maintenance_window_target.target_start](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target) | resource |
| [aws_ssm_maintenance_window_target.target_stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target) | resource |
| [aws_ssm_maintenance_window_task.start_ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |
| [aws_ssm_maintenance_window_task.stop_ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | ARN of the IAM role to associate with the maintenance window tasks | `string` | n/a | yes |
| <a name="input_mw_allow_unassociated_targets_start"></a> [mw\_allow\_unassociated\_targets\_start](#input\_mw\_allow\_unassociated\_targets\_start) | Indicates whether targets must be registered with the Maintenance Window before tasks can be defined for starting. | `bool` | `true` | no |
| <a name="input_mw_allow_unassociated_targets_stop"></a> [mw\_allow\_unassociated\_targets\_stop](#input\_mw\_allow\_unassociated\_targets\_stop) | Indicates whether targets must be registered with the Maintenance Window before tasks can be defined. | `bool` | `true` | no |
| <a name="input_mw_cutoff"></a> [mw\_cutoff](#input\_mw\_cutoff) | The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution. | `number` | `1` | no |
| <a name="input_mw_description_start"></a> [mw\_description\_start](#input\_mw\_description\_start) | Description for the maintenance window for starting instances. | `string` | `"Maintenance window to start EC2 instances."` | no |
| <a name="input_mw_description_stop"></a> [mw\_description\_stop](#input\_mw\_description\_stop) | Description for the maintenance window for stopping instances. | `string` | `"Maintenance window to stop EC2 instances."` | no |
| <a name="input_mw_duration"></a> [mw\_duration](#input\_mw\_duration) | The duration of the Maintenance Window in hours. | `number` | `4` | no |
| <a name="input_mw_enabled_start"></a> [mw\_enabled\_start](#input\_mw\_enabled\_start) | Indicates whether the maintenance window for starting is enabled. | `bool` | `true` | no |
| <a name="input_mw_enabled_stop"></a> [mw\_enabled\_stop](#input\_mw\_enabled\_stop) | Indicates whether the maintenance window for stopping is enabled. | `bool` | `true` | no |
| <a name="input_mw_end_date_start"></a> [mw\_end\_date\_start](#input\_mw\_end\_date\_start) | The end date of the maintenance window for starting in the form YYYY-MM-DD. This can be left empty if there's no end date. | `string` | `""` | no |
| <a name="input_mw_end_date_stop"></a> [mw\_end\_date\_stop](#input\_mw\_end\_date\_stop) | The end date of the maintenance window for stopping in the form YYYY-MM-DD. This can be left empty if there's no end date. | `string` | `""` | no |
| <a name="input_mw_name"></a> [mw\_name](#input\_mw\_name) | The name of the maintenance window. | `string` | `"MyMaintenanceWindow"` | no |
| <a name="input_mw_schedule_offset_start"></a> [mw\_schedule\_offset\_start](#input\_mw\_schedule\_offset\_start) | The number of days to wait after the date and time specified by a CRON format to run the maintenance window for starting. | `number` | `0` | no |
| <a name="input_mw_schedule_offset_stop"></a> [mw\_schedule\_offset\_stop](#input\_mw\_schedule\_offset\_stop) | The number of days to wait after the date and time specified by a CRON format to run the maintenance window for stopping. | `number` | `0` | no |
| <a name="input_mw_schedule_start"></a> [mw\_schedule\_start](#input\_mw\_schedule\_start) | The schedule for when to start the EC2 instances, using cron or rate expressions. | `string` | `"cron(0 6 ? * MON-FRI *)"` | no |
| <a name="input_mw_schedule_stop"></a> [mw\_schedule\_stop](#input\_mw\_schedule\_stop) | The schedule for when to stop the EC2 instances, using cron or rate expressions. | `string` | `"cron(0 22 ? * MON-FRI *)"` | no |
| <a name="input_mw_schedule_timezone"></a> [mw\_schedule\_timezone](#input\_mw\_schedule\_timezone) | The time zone to use for the maintenance window. E.g., 'America/New\_York'. | `string` | `"UTC"` | no |
| <a name="input_mw_start_date_start"></a> [mw\_start\_date\_start](#input\_mw\_start\_date\_start) | The start date of the maintenance window for starting in the form YYYY-MM-DD. This can be left empty if immediate start is desired. | `string` | `""` | no |
| <a name="input_mw_start_date_stop"></a> [mw\_start\_date\_stop](#input\_mw\_start\_date\_stop) | The start date of the maintenance window for stopping in the form YYYY-MM-DD. This can be left empty if immediate start is desired. | `string` | `""` | no |
| <a name="input_mw_tags"></a> [mw\_tags](#input\_mw\_tags) | Tags to apply to the Maintenance Window. | `map(string)` | `{}` | no |
| <a name="input_start_max_concurrency"></a> [start\_max\_concurrency](#input\_start\_max\_concurrency) | The maximum number of instances to start concurrently. | `string` | `"1"` | no |
| <a name="input_start_max_errors"></a> [start\_max\_errors](#input\_start\_max\_errors) | The maximum number of errors allowed before stopping the start automation. | `string` | `"1"` | no |
| <a name="input_start_order"></a> [start\_order](#input\_start\_order) | Order in which EC2 instances should be started. | `list(string)` | `[]` | no |
| <a name="input_stop_max_concurrency"></a> [stop\_max\_concurrency](#input\_stop\_max\_concurrency) | The maximum number of instances to stop concurrently. | `string` | `"1"` | no |
| <a name="input_stop_max_errors"></a> [stop\_max\_errors](#input\_stop\_max\_errors) | The maximum number of errors allowed before stopping the automation. | `string` | `"1"` | no |
| <a name="input_stop_order"></a> [stop\_order](#input\_stop\_order) | Order in which EC2 instances should be stopped. | `list(string)` | `[]` | no |
| <a name="input_target_details"></a> [target\_details](#input\_target\_details) | The targets (e.g., instances) for the maintenance window. It's a list of maps with 'key' and 'values'. | `list(map(string))` | `[]` | no |
| <a name="input_target_name_start"></a> [target\_name\_start](#input\_target\_name\_start) | The name of the maintenance window target for starting instances. | `string` | `"StartTarget"` | no |
| <a name="input_target_name_stop"></a> [target\_name\_stop](#input\_target\_name\_stop) | The name of the maintenance window target for stopping instances. | `string` | `"StopTarget"` | no |
| <a name="input_target_resource_type"></a> [target\_resource\_type](#input\_target\_resource\_type) | The type of resource you can specify when registering a target. Only 'INSTANCE' is currently supported. | `string` | `"INSTANCE"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_maintenance_window_id"></a> [maintenance\_window\_id](#output\_maintenance\_window\_id) | The ID of the maintenance window. |
| <a name="output_maintenance_window_target_id"></a> [maintenance\_window\_target\_id](#output\_maintenance\_window\_target\_id) | The ID of the maintenance window target. |
<!-- END_TF_DOCS -->