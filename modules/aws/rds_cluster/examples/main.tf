module "aurora_db" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/rds_cluster?ref=v0.13.10"

  availability_zones              = ["us-west-2a", "us-west-2b"]
  cluster_identifier              = "dbidentity"
  database_name                   = "db_name"
  db_subnet_group_name            = module.db_subnet_group.id[0]
  db_cluster_parameter_group_name = module.db_parameter_group.id[0]
  engine                          = "aurora"
  engine_mode                     = "provisioned"
  engine_version                  = "5.6.10a"
  master_password                 = var.db_master_password
  master_username                 = var.db_master_username
  port                            = "3306"
  preferred_backup_window         = "05:00-07:00"
  preferred_maintenance_window    = "Sun:09:00-Sun:09:30"
  vpc_security_group_ids          = [module.db_sg.id]
}
