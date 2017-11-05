resource "aws_security_group" "domain_controller_sg" {
    name    = "${var.sg_name}"
    description = "Security group applied to all domain controllers"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }

    tags            = "${var.tags}"
}
