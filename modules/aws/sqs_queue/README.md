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
| delay\_seconds | (Optional) The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds. | `string` | `0` | no |
| fifo\_queue | (Optional) Boolean designating a FIFO queue. If not set, it defaults to false making it standard. | `bool` | `false` | no |
| message\_retention\_seconds | (Optional) The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). The default for this attribute is 345600 (4 days). | `number` | `345600` | no |
| name | (Optional) This is the human-readable name of the queue. If omitted, Terraform will assign a random name. | `string` | n/a | yes |
| tags | (Optional) A mapping of tags to assign to the queue. | `map` | `{}` | no |
| visibility\_timeout\_seconds | (Optional) The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). The default for this attribute is 30. For more information about visibility timeout, see AWS docs. | `string` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | n/a |
| id | n/a |