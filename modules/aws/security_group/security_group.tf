resource "aws_security_group" "sg" {
    description = "${var.description}"
    name        = "${var.name}"
    tags        = "${merge(var.tags, map("Name", format("%s", var.name)))}"
    vpc_id      = "${var.vpc_id}"
}
