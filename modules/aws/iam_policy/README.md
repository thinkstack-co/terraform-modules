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
| description | (Optional, Forces new resource) Description of the IAM policy. | `string` | n/a | yes |
| name | (Optional, Forces new resource) The name of the policy. If omitted, Terraform will assign a random, unique name. | `string` | n/a | yes |
| path | (Optional, default '/') Path in which to create the policy. See IAM Identifiers for more information. | `string` | `"/"` | no |
| policy | (Required) The policy document. This is a JSON formatted string. The heredoc syntax, file function, or the aws\_iam\_policy\_document data source are all helpful here. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| arn | n/a |
| id | n/a |