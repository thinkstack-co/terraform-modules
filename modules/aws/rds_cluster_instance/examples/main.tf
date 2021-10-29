module "craftcms_db_instances" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/rds_cluster_instance"

  count                        = 2
  cluster_identifier           = module.cluster.id[0]
  db_subnet_group_name         = module.db_subnet_group.id
  db_parameter_group_name      = module.db_parameter_group.id[0]
  engine                       = "aurora"
  identifier                   = "db"
  instance_class               = "db.t2.medium"
  performance_insights_enabled = false
  tags = {
    terraform   = "yes"
    created_by  = "Zachary Hill"
    environment = "prod"
  }
}
