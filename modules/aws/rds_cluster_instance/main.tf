terraform {
  required_version = ">= 0.12.0"
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  apply_immediately               = var.apply_immediately
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  availability_zone               = var.availability_zone
  count                           = var.number
  cluster_identifier              = var.cluster_identifier
  db_subnet_group_name            = var.db_subnet_group_name
  db_parameter_group_name         = var.db_parameter_group_name
  engine                          = var.engine
  engine_version                  = var.engine_version
  identifier                      = format("%s-%d", var.identifier, count.index + 1)
  instance_class                  = var.instance_class
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_role_arn
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  promotion_tier                  = var.promotion_tier
  publicly_accessible             = var.publicly_accessible
  tags                            = var.tags
}
