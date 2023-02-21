# Usage
    module "dev" {
        source                       = "github.com/thinkstack-co/terraform-modules//modules/aws/route53/alias_record"

        zone_id                      = module.example_com_zone.zone_id
        name                         = "dev.example.com"
        type                         = "A"
        alias_name                   = "s3-website-us-east-1.amazonaws.com"
        alias_zone_id                = "ZONE_ID"
        alias_evaluate_target_health = "true"
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
| <a name="input_alias_evaluate_target_health"></a> [alias\_evaluate\_target\_health](#input\_alias\_evaluate\_target\_health) | (Optional, Required for alias record) Set to true if you want Route 53 to determine whether to respond to DNS queries using this resource record set by checking the health of the resource record set. Some resources have special requirements, see related part of documentation. | `bool` | `null` | no |
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | (Optional, Required for alias record) DNS domain name for a CloudFront distribution, S3 bucket, ELB, or another resource record set in this hosted zone. | `string` | `null` | no |
| <a name="input_alias_zone_id"></a> [alias\_zone\_id](#input\_alias\_zone\_id) | (Optional, Required for alias record) Hosted zone ID for a CloudFront distribution, S3 bucket, ELB, or Route 53 hosted zone. See resource\_elb.zone\_id for example. | `string` | `null` | no |
| <a name="input_failover_routing_policy_type"></a> [failover\_routing\_policy\_type](#input\_failover\_routing\_policy\_type) | (Optional, Required for failover routing) PRIMARY or SECONDARY. A PRIMARY record will be served if its healthcheck is passing, otherwise the SECONDARY will be served. See http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-configuring-options.html#dns-failover-failover-rrsets | `string` | `null` | no |
| <a name="input_geolocation_routing_policy_continent"></a> [geolocation\_routing\_policy\_continent](#input\_geolocation\_routing\_policy\_continent) | (Optional) A two-letter continent code. See http://docs.aws.amazon.com/Route53/latest/APIReference/API_GetGeoLocation.html for code details. Either continent or country must be specified. | `string` | `null` | no |
| <a name="input_geolocation_routing_policy_country"></a> [geolocation\_routing\_policy\_country](#input\_geolocation\_routing\_policy\_country) | (Optional) A two-character country code or * to indicate a default resource record set. | `string` | `null` | no |
| <a name="input_geolocation_routing_policy_subdivision"></a> [geolocation\_routing\_policy\_subdivision](#input\_geolocation\_routing\_policy\_subdivision) | (Optional) A subdivision code for a country. | `string` | `null` | no |
| <a name="input_health_check_id"></a> [health\_check\_id](#input\_health\_check\_id) | (Optional) The health check the record should be associated with. | `string` | `null` | no |
| <a name="input_latency_routing_policy_region"></a> [latency\_routing\_policy\_region](#input\_latency\_routing\_policy\_region) | (Optional, Required for latency routing) An AWS region from which to measure latency. See http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-latency | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the record. | `string` | n/a | yes |
| <a name="input_set_identifier"></a> [set\_identifier](#input\_set\_identifier) | (Optional) Unique identifier to differentiate records with routing policies from one another. Required if using failover, geolocation, latency, multivalue\_answer, or weighted routing policies documented below. | `string` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | (Required) The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT. | `string` | n/a | yes |
| <a name="input_weighted_routing_policy_weight"></a> [weighted\_routing\_policy\_weight](#input\_weighted\_routing\_policy\_weight) | (Optional, Required for weighted routing) A numeric value indicating the relative weight of the record. See http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-weighted. | `number` | `null` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | (Required) The ID of the hosted zone to contain this record. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->