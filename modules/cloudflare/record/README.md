# Usage

    module "www.example.com" {
        source     = "github.com/thinkstack-co/terraform-modules//modules/cloudflare/record"

        zone_id = module.zone.id
        name    = "www"
        value   = "192.0.2.1"
        type    = "A"
        ttl     = 3600
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
| [cloudflare_record.this](https://registry.terraform.io/providers/hashicorp/cloudflare/latest/docs/resources/record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_overwrite"></a> [allow\_overwrite](#input\_allow\_overwrite) | (Optional) Allow creation of this record in Terraform to overwrite an existing record, if any. This does not affect the ability to update the record in Terraform and does not prevent other resources within Terraform or manual changes outside Terraform from overwriting this record. This configuration is not recommended for most environments. Defaults to false. | `bool` | `false` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | (Optional) Comments or notes about the DNS record. This field has no effect on DNS responses. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the DNS record. This can be a subdomain (www), an apex domain (@), or a wildcard (*.). | `string` | n/a | yes |
| <a name="input_priority"></a> [priority](#input\_priority) | (Optional) The priority of the target host. Lower values are preferred. This is only used for MX and SRV records. Defaults to 0. | `number` | `0` | no |
| <a name="input_proxied"></a> [proxied](#input\_proxied) | (Optional) Whether the record is receiving the performance and security benefits of Cloudflare. Defaults to false. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A list of tags to assign to the record. Tags are used for filtering and organizing resources in the Cloudflare dashboard. | `list(string)` | `[]` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | (Optional) The Time To Live (TTL) of the record, in seconds. Defaults to 1. | `number` | `1` | no |
| <a name="input_type"></a> [type](#input\_type) | (Required)The type of the record. Available values: A, AAAA, CAA, CNAME, TXT, SRV, LOC, MX, NS, SPF, CERT, DNSKEY, DS, NAPTR, SMIMEA, SSHFP, TLSA, URI, PTR, HTTPS. | `string` | n/a | yes |
| <a name="input_value"></a> [value](#input\_value) | (Required) The value of the record. This can be a domain name, IP address, or other value depending on the type of record. | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | (Required) The ID of the zone to which the record belongs. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->