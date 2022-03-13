module "db_parameter_group" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/db_parameter_group?ref=v0.13.10"

  description = "aurora 5.6 parameter group"
  family      = "aurora5.6"
  name        = "aurora-mysql-5-6"
  tags = {
    terraform   = "yes"
    created_by  = "Zachary Hill"
    environment = "prod"
  }
}
