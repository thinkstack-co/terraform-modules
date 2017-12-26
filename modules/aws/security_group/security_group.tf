resource "aws_security_group" "sg" {
    description = "${var.description}"
    name        = "${var.name}"
    tags        = "${var.tags}"
    vpc_id      = "${var.vpc_id}"
}
