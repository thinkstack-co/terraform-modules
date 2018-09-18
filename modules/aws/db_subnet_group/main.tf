resource "aws_db_subnet_group" "group" {
  description = "${var.description}"
  name        = "${var.name}"
  subnet_ids  = "${var.subnet_ids}"
  tags        = "${var.tags}"
}
