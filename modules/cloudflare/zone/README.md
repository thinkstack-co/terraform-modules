# Usage

    module "example_com_zone" {
        source     = "github.com/thinkstack-co/terraform-modules//modules/cloudflare/zone"

        account_id = "f037e56e89293a057740de681ac9abbe"
        zone       = "example.com"
    }

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_zone.example](https://registry.terraform.io/providers/hashicorp/cloudflare/latest/docs/resources/zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Required) Account ID to manage the zone resource in. | `string` | n/a | yes |
| <a name="input_jump_start"></a> [jump\_start](#input\_jump\_start) | (Optional) Whether to scan for DNS records on creation. Ignored after zone is created. | `bool` | `false` | no |
| <a name="input_paused"></a> [paused](#input\_paused) | (Optional)(Boolean) Whether this zone is paused (traffic bypasses Cloudflare). Defaults to false. | `bool` | `false` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | (Optional)The name of the commercial plan to apply to the zone. Available values: free, lite, pro, pro\_plus, business, enterprise, partners\_free, partners\_pro, partners\_business, partners\_enterprise. | `string` | `"free"` | no |
| <a name="input_type"></a> [type](#input\_type) | (Optional) A full zone implies that DNS is hosted with Cloudflare. A partial zone is typically a partner-hosted zone or a CNAME setup. Available values: full, partial. Defaults to full. | `string` | `"full"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | (Required) The DNS zone name which will be added. Modifying this attribute will force creation of a new resource. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->