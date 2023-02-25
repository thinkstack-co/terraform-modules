
# Route53 Zone
Utilized to create a Route53 Domain Zone

## Usage
    module "route53_zone" {
      source  = "github.com/thinkstack-co/terraform-modules//modules/aws/route53/zone"
      
      comment = "ThinkStack primary domain"
      name    = "thinkstack.co"
      
      tags    = {
        terraform   = "yes"
        created_by  = "Zachary Hill"
        environment = "prod"
        role        = "external dns"
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
| [aws_route53_zone.zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_comment"></a> [comment](#input\_comment) | (Optional) A comment for the hosted zone. Defaults to 'Managed by Terraform'. | `string` | `"Managed by Terraform"` | no |
| <a name="input_delegation_set_id"></a> [delegation\_set\_id](#input\_delegation\_set\_id) | (Optional) The ID of the reusable delegation set whose NS records you want to assign to the hosted zone. Conflicts with vpc as delegation sets can only be used for public zones. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) This is the name of the hosted zone. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to assign to the zone. | `map` | <pre>{<br>  "terraform": true<br>}</pre> | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | (Optional) Configuration block(s) specifying VPC(s) to associate with a private hosted zone. Conflicts with the delegation\_set\_id argument in this resource and any aws\_route53\_zone\_association resource specifying the same zone ID. Detailed below. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | n/a |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | n/a |
<!-- END_TF_DOCS -->