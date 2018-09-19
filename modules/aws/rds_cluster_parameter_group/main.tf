resource "aws_rds_cluster_parameter_group" "group" {
  description = "${var.description}"
  family      = "${var.family}"
  name        = "${var.name}"
  parameter   = "${var.parameter}"
  tags        = "${var.tags}"
}
