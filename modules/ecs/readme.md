| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.13.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | name of your cluster | `string` | n/a | yes |
| container\_insights | whether to launch ecs with container insights enabled | `bool` | `false` | yes |

## Outputs

| Name | Description |
|------|-------------|
| ecs\_cluster\_id | n/a |
| ecs\_cluster\_arn | n/a |
| ecs\_cluster\_name | n/a |