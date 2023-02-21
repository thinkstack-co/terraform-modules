# Usage
### Example TXT record
    
    module "domain_txt" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/route53/simple_record"

        zone_id = module.example_com_zone.zone_id
        name    = "example.com"
        type    = "TXT"
        ttl     = 300
        records = [
            "v=spf1 include:_spf.google.com ~all",
            "google-site-verification=h-218181818181818181818181818fdsa",
            "v=DKIM1; k=rsa; p=fdjkslafjlkdsajoifjiofjdlskafjlkdsajklfdsoiafdsafdsafdsa/stf0Ga4z2XaZG7detZ+beakt9hF5I7hBarjspZuIwVNb+VnDJ2t21wlxnswHt5huiAxg52g+99x890fd09sa0fdsafdsa8f09dsa809fd80s9a/fdsafdsafdsafdsafdsafdsafdsa\"\"EtbJup2cDxlYAH8/HiLq+bhLIKnzwhsiu16k91DDJYAXjmOm2o3MRD9AVtVWIyRb59Qhi9FOlySNOezxxM+WPCXTzPqPs78jshMcMLZbLTrNFWkNcdrLCD79RdUN+DdXDBj4cemdjxs4Ul4J5IkwwIDAQAB",
            "v=DKIM1; k=rsa; p=dfsa098fd809saf809dsa809fdhjsafhfdjsiafidosa/GASDFJUKALJKffdsa0+xEObmrCjxcG2VtNHiwZ+6sD0PGC2ldjAPIVaYtKJmoJaO+Dt/fds89a0f809dsa809fd809saf890dsa908fdsa/eJCh\"\"lZQzIOmNzp0CRJDSPy9+jOYqMpVyeThzWnIALam0Z6M8nJ/ue6ezygRBR70AbG/fd90sa890fds809af809dsa809f8d90safdsa/AC0nU5QmoKvd40qzMm0CA0ycXt5hb5iDR+T1Kx8ps9KPXQIDAQAB",
        ]
    }

### Example A record
    
    module "test" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/route53/simple_record"

        zone_id = module.example_com_zone.zone_id
        name    = "test.example.com"
        type    = "A"
        ttl     = 300
        records = [
            "1.1.1.1"
        ]
    }


### Example CNAME record
    
    module "mail" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/route53/simple_record"

        zone_id = module.example_com_zone.zone_id
        name    = "mail.example.com"
        type    = "CNAME"
        ttl     = 300
        records = [
            "ghs.googlehosted.com."
        ]
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
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_health_check_id"></a> [health\_check\_id](#input\_health\_check\_id) | (Optional) The health check the record should be associated with. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the record. | `string` | n/a | yes |
| <a name="input_records"></a> [records](#input\_records) | (Required for non-alias records) A string list of records. To specify a single record value longer than 255 characters such as a TXT record for DKIM, add "" inside the Terraform configuration string. | `list(string)` | n/a | yes |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | (Optional, Required for non-alias records) The TTL of the record in seconds. | `number` | `300` | no |
| <a name="input_type"></a> [type](#input\_type) | (Required) The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT. | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | (Required) The ID of the hosted zone to contain this record. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->