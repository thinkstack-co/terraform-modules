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
| force\_destroy | (Optional, default false) When destroying this user, destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices. Without force\_destroy a user with non-Terraform-managed access keys and login profile will fail to be destroyed. | `string` | n/a | yes |
| name | (Required) The user's name. The name must consist of upper and lowercase alphanumeric characters with no spaces. You can also include any of the following characters: =,.@-\_.. User names are not distinguished by case. For example, you cannot create users named both 'TESTUSER' and 'testuser'. | `string` | n/a | yes |
| path | (Optional, default '/') Path in which to create the user. | `string` | n/a | yes |
| permissions\_boundary | (Optional) The ARN of the policy that is used to set the permissions boundary for the user. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| arn | n/a |
| unique\_id | n/a |