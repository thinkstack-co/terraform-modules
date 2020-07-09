
# Route53 Zone
Utilized to create a Route53 Domain Zone

# Usage
    module "route53_zone" {
      source  = "github.com/thinkstack-co/terraform-modules//modules/aws/route53_zone"
      
      comment = "ThinkStack primary domain"
      name    = "thinkstack.co"
      
      tags    = {
        terraform   = "yes"
        created_by  = "Zachary Hill"
        environment = "prod"
        role        = "external dns"
      }
    }

# Variables
## Required
    name

## Optional
    comment
    delegation_set_id
    tags

# Outputs
    name_servers
    zone_id
