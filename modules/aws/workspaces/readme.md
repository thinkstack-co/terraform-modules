## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bundle\_id | the default bundle ID to use when creating an AWS workspace | `string` | `"wsb-9jvhtb24f"` | yes |
| root\_volume\_size | the size of the root volume for the workspace | `string` | `"80"` | yes |
| user\_volume\_size | the size of the user volume for the workspace | `string` | `"50"` | yes |
| running\_mode\_type | the running mode of the workspace | `string` | `"AUTO_STOP"` | yes |
| auto\_stop\_timeout | the auto stop configuration time out of auto stop instances | `string` | 60 | no |
| directory\_id | the directory id of the workspaces directory; needs to be taken from the customer environment and passed through | `string` | n/a | yes |
| user\_name | the user name of the user for the workspace | `string` | n/a | yes |
| compute\_type | the compute type of the amazon workspace | `string` | PERFORMANCE | yes |

## Outputs

| Name | Description |
|------|-------------|
| id | n/a |
| ip\_address | n/a |
| computer\_name | n/a |
| state | n/a |