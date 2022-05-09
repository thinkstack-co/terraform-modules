# AWS Organization Account Module
This module generates and manages an AWS Organization Account

# Usage

    module "client_prod_infrastructure" {
        source    = "github.com/thinkstack-co/terraform-modules//modules/aws/organizations_account"
        
        name      = "client_prod_infrastructure"
        email     = "aws_environments+client@thinkstack.co"
        parent_id = var.clients_parent_id
    }

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
| [aws_organizations_account.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_close_on_deletion"></a> [close\_on\_deletion](#input\_close\_on\_deletion) | (Optional) If true, a deletion event will close the account. Otherwise, it will only remove from the organization. | `bool` | `false` | no |
| <a name="input_email"></a> [email](#input\_email) | (Required) The email address of the owner to assign to the new member account. This email address must not already be associated with another AWS account. | `string` | n/a | yes |
| <a name="input_iam_user_access_to_billing"></a> [iam\_user\_access\_to\_billing](#input\_iam\_user\_access\_to\_billing) | (Optional) If set to ALLOW, the new account enables IAM users to access account billing information if they have the required permissions. If set to DENY, then only the root user of the new account can access account billing information. | `string` | `"ALLOW"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) A friendly name for the member account. | `string` | n/a | yes |
| <a name="input_parent_id"></a> [parent\_id](#input\_parent\_id) | (Optional) Parent Organizational Unit ID or Root ID for the account. Defaults to the Organization default Root ID. A configuration must be present for this argument to perform drift detection. | `string` | `null` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | (Optional) The name of an IAM role that Organizations automatically preconfigures in the new member account. This role trusts the master account, allowing users in the master account to assume the role, as permitted by the master account administrator. The role has administrator permissions in the new member account. The Organizations API provides no method for reading this information after account creation, so Terraform cannot perform drift detection on its value and will always show a difference for a configured value after import unless ignore\_changes is used. | `string` | `"ThinkStackOrganizationAccountAccessRole"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | n/a |
<!-- END_TF_DOCS -->