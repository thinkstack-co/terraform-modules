terraform {
  required_version = ">= 0.12.0"
}

resource "aws_rds_cluster" "cluster" {
  apply_immediately               = var.apply_immediately
  availability_zones              = var.availability_zones
  backup_retention_period         = var.backup_retention_period
  cluster_identifier              = var.cluster_identifier
  database_name                   = var.database_name
  db_subnet_group_name            = var.db_subnet_group_name
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  engine                          = var.engine
  engine_mode                     = var.engine_mode
  engine_version                  = var.engine_version
  # final_snapshot_identifier           = var.final_snapshot_identifier
  iam_roles                           = var.iam_roles
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  kms_key_id                          = var.kms_key_id
  master_password                     = var.master_password
  master_username                     = var.master_username
  port                                = var.port
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  # scaling_configuration               = var.scaling_configuration
  skip_final_snapshot    = var.skip_final_snapshot
  snapshot_identifier    = var.snapshot_identifier
  storage_encrypted      = var.storage_encrypted
  vpc_security_group_ids = var.vpc_security_group_ids
}
