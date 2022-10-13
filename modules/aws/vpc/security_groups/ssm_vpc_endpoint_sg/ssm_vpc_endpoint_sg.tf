resource "aws_security_group" "security_group" {
    description = var.description
    name        = var.name
    tags        = var.tags
    vpc_id      = var.vpc_id 

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = var.cidr_blocks
    }  

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "udp"
        cidr_blocks = var.cidr_blocks
    } 

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}
