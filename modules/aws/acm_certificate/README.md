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
| domain\_name | (Required) A domain name for which the certificate should be issued | `string` | n/a | yes |
| subject\_alternative\_names | (Optional) A list of domains that should be SANs in the issued certificate | `list` | `[]` | no |
| tags | (Optional) A mapping of tags to assign to the resource. | `map` | `{}` | no |
| validation\_method | (Required) Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certificates that were imported into ACM and then into Terraform. | `string` | `"DNS"` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | n/a |
| id | n/a |