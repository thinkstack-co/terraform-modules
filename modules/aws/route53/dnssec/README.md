## Usage
    module "example_com_dnssec" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/route53/dnssec"

        hosted_zone_id = module.example_com_zone.zone_id
        name           = "example_com_signing_key"
        tags           = {
            terraform   = "true"
            created_by  = "YOUR NAME"
            environment = "prod"
            role        = "dns"
            }
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
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.dnssec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_route53_hosted_zone_dnssec.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_hosted_zone_dnssec) | resource |
| [aws_route53_key_signing_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_key_signing_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_customer_master_key_spec"></a> [customer\_master\_key\_spec](#input\_customer\_master\_key\_spec) | (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC\_DEFAULT, RSA\_2048, RSA\_3072, RSA\_4096, HMAC\_256, ECC\_NIST\_P256, ECC\_NIST\_P384, ECC\_NIST\_P521, or ECC\_SECG\_P256K1. Defaults to SYMMETRIC\_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide. | `string` | `"ECC_NIST_P256"` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | (Optional) The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive. If you do not specify a value, it defaults to 30. If the KMS key is a multi-Region primary key with replicas, the waiting period begins when the last of its replica keys is deleted. Otherwise, the waiting period begins immediately. | `number` | `7` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the key as viewed in AWS console. | `string` | `"KMS key used in Route53 zone DNSSEC"` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | (Optional) Specifies whether key rotation is enabled. Defaults to false. | `bool` | `false` | no |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | (Required) Identifier of the Route 53 Hosted Zone. | `string` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) Specifies whether the key is enabled. Defaults to true. | `bool` | `true` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | (Optional) Specifies the intended use of the key. Valid values: ENCRYPT\_DECRYPT, SIGN\_VERIFY, or GENERATE\_VERIFY\_MAC. Defaults to ENCRYPT\_DECRYPT. | `string` | `"SIGN_VERIFY"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the key-signing key (KSK). Must be unique for each key-singing key in the same hosted zone. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/). | `string` | `"alias/dnssec_"` | no |
| <a name="input_signing_status"></a> [signing\_status](#input\_signing\_status) | (Optional) Hosted Zone signing status. Valid values: SIGNING, NOT\_SIGNING. Defaults to SIGNING. | `string` | `"SIGNING"` | no |
| <a name="input_status"></a> [status](#input\_status) | (Optional) Status of the key-signing key (KSK). Valid values: ACTIVE, INACTIVE. Defaults to ACTIVE. | `string` | `"ACTIVE"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to assign to the object. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map` | <pre>{<br>  "terraform": "true"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_digest_algorithm_mnemonic"></a> [digest\_algorithm\_mnemonic](#output\_digest\_algorithm\_mnemonic) | n/a |
| <a name="output_digest_algorithm_type"></a> [digest\_algorithm\_type](#output\_digest\_algorithm\_type) | n/a |
| <a name="output_digest_value"></a> [digest\_value](#output\_digest\_value) | n/a |
| <a name="output_dnskey_record"></a> [dnskey\_record](#output\_dnskey\_record) | n/a |
| <a name="output_ds_record"></a> [ds\_record](#output\_ds\_record) | n/a |
| <a name="output_flag"></a> [flag](#output\_flag) | n/a |
| <a name="output_key_tag"></a> [key\_tag](#output\_key\_tag) | n/a |
| <a name="output_public_key"></a> [public\_key](#output\_public\_key) | n/a |
| <a name="output_signing_algorithm_mnemonic"></a> [signing\_algorithm\_mnemonic](#output\_signing\_algorithm\_mnemonic) | n/a |
| <a name="output_signing_algorithm_type"></a> [signing\_algorithm\_type](#output\_signing\_algorithm\_type) | n/a |
<!-- END_TF_DOCS -->