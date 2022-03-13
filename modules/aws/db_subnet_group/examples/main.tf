module "db_subnet_group" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/db_subnet_group?ref=v0.13.2"

  description = "client_prod_website db subnet group"
  name        = "website_subnet_group"
  subnet_ids  = module.vpc.db_subnet_ids
  tags = {
    terraform   = "yes"
    created_by  = "Zachary Hill"
    environment = "prod"
  }
}
