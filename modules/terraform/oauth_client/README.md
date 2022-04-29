<!-- BEGIN_TF_DOCS -->
# Terraform OAuth Module
This module generates and manages a terraform cloud oauth id with your version control system

# Usage

    module "prod_oauth" {
        source           = "github.com/thinkstack-co/terraform-modules//modules/terraform/oauth_client"
        
        name             = "my-github-oauth-client"
        organization     = "my-org-name"
        api_url          = "https://api.github.com"
        http_url         = "https://github.com"
        oauth_token      = "my-vcs-provider-token"
        service_provider = "github"
    }
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [tfe_oauth_client.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/oauth_client) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_url"></a> [api\_url](#input\_api\_url) | (Required) The base URL of your VCS provider's API (e.g. https://api.github.com or https://ghe.example.com/api/v3). | `string` | n/a | yes |
| <a name="input_http_url"></a> [http\_url](#input\_http\_url) | (Required) The homepage of your VCS provider (e.g. https://github.com or https://ghe.example.com). | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Display name for the OAuth Client. Defaults to the service\_provider if not supplied. | `string` | n/a | yes |
| <a name="input_oauth_token"></a> [oauth\_token](#input\_oauth\_token) | (Required) The token string you were given by your VCS provider, e.g. ghp\_xxxxxxxxxxxxxxx for a GitHub personal access token. For more information on how to generate this token string for your VCS provider, see the Create an OAuth Client documentation. | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | (Required) Name of the Terraform organization. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_oauth_token_id"></a> [oauth\_token\_id](#output\_oauth\_token\_id) | n/a |
<!-- END_TF_DOCS -->