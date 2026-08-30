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
| [aws_ssm_maintenance_window.maintenance_window](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window) | resource |
| [aws_ssm_maintenance_window_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_target) | resource |
| [aws_ssm_maintenance_window_task.stop_ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_maintenance_window_task) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_max_concurrency"></a> [max\_concurrency](#input\_max\_concurrency) | The maximum number of targets this task can be run for in parallel. | `string` | `"1"` | no |
| <a name="input_max_errors"></a> [max\_errors](#input\_max\_errors) | The maximum number of errors allowed before this task stops being scheduled. | `string` | `"1"` | no |
| <a name="input_mw_allow_unassociated_targets"></a> [mw\_allow\_unassociated\_targets](#input\_mw\_allow\_unassociated\_targets) | Whether targets must be registered with the Maintenance Window before tasks can be defined for those targets. | `bool` | `false` | no |
| <a name="input_mw_cutoff"></a> [mw\_cutoff](#input\_mw\_cutoff) | The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution. | `number` | n/a | yes |
| <a name="input_mw_description"></a> [mw\_description](#input\_mw\_description) | A description for the maintenance window. | `string` | `null` | no |
| <a name="input_mw_duration"></a> [mw\_duration](#input\_mw\_duration) | The duration of the Maintenance Window in hours. | `number` | n/a | yes |
| <a name="input_mw_enabled"></a> [mw\_enabled](#input\_mw\_enabled) | Whether the maintenance window is enabled. | `bool` | `true` | no |
| <a name="input_mw_end_date"></a> [mw\_end\_date](#input\_mw\_end\_date) | Timestamp in ISO-8601 extended format when to no longer run the maintenance window. | `string` | `null` | no |
| <a name="input_mw_name"></a> [mw\_name](#input\_mw\_name) | The name of the maintenance window. | `string` | n/a | yes |
| <a name="input_mw_schedule"></a> [mw\_schedule](#input\_mw\_schedule) | The schedule of the Maintenance Window in the form of a cron or rate expression. | `string` | n/a | yes |
| <a name="input_mw_schedule_offset"></a> [mw\_schedule\_offset](#input\_mw\_schedule\_offset) | The number of days to wait after the date and time specified by a CRON expression before running the maintenance window. | `number` | `null` | no |
| <a name="input_mw_schedule_timezone"></a> [mw\_schedule\_timezone](#input\_mw\_schedule\_timezone) | Timezone for schedule in Internet Assigned Numbers Authority (IANA) Time Zone Database format. | `string` | `null` | no |
| <a name="input_mw_start_date"></a> [mw\_start\_date](#input\_mw\_start\_date) | Timestamp in ISO-8601 extended format when to begin the maintenance window. | `string` | `null` | no |
| <a name="input_mw_tags"></a> [mw\_tags](#input\_mw\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_start_order"></a> [start\_order](#input\_start\_order) | The list of EC2 instance IDs to start in order. | `list(string)` | n/a | yes |
| <a name="input_stop_order"></a> [stop\_order](#input\_stop\_order) | The list of EC2 instance IDs to start in order. | `list(string)` | n/a | yes |
| <a name="input_target_description"></a> [target\_description](#input\_target\_description) | The description of the maintenance window target. | `string` | `null` | no |
| <a name="input_target_details"></a> [target\_details](#input\_target\_details) | The targets to register with the maintenance window. Specify targets using instance IDs, resource group names, or tags that have been applied to instances. | <pre>list(object({<br>    key    = string<br>    values = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_target_name"></a> [target\_name](#input\_target\_name) | (Optional) The name of the maintenance window target. | `string` | `null` | no |
| <a name="input_target_owner_information"></a> [target\_owner\_information](#input\_target\_owner\_information) | User-provided value that will be included in any CloudWatch events raised while running tasks for these targets in this Maintenance Window. | `string` | `null` | no |
| <a name="input_target_resource_type"></a> [target\_resource\_type](#input\_target\_resource\_type) | The type of target being registered with the Maintenance Window. Possible values are INSTANCE and RESOURCE\_GROUP. | `string` | n/a | yes |
| <a name="input_window_id"></a> [window\_id](#input\_window\_id) | The ID of the maintenance window to register the task with. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_maintenance_window_id"></a> [maintenance\_window\_id](#output\_maintenance\_window\_id) | The ID of the maintenance window. |
| <a name="output_maintenance_window_target_id"></a> [maintenance\_window\_target\_id](#output\_maintenance\_window\_target\_id) | The ID of the maintenance window target. |
<!-- END_TF_DOCS -->