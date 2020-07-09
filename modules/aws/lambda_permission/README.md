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
| action | The AWS lambda action you want to allow | `string` | `"lambda:InvokeFunction"` | no |
| function\_name | Name of the lambda function | `string` | n/a | yes |
| principal | The principal which is receiving this permission | `string` | `"events.amazonaws.com"` | no |
| source\_arn | arn of the resource to allow permission to run the lambda function | `string` | n/a | yes |
| statement\_id | A unique statement identifier | `any` | n/a | yes |

## Outputs

No output.
