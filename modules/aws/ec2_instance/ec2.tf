resource "aws_security_group" "domain_controller_sg" {
    name    = "domain_controller_sg"
    description = "Security group applied to all domain controllers"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 445
        to_port     = 445
        protocol    = "udp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 445
        to_port     = 445
        protocol    = "tcp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 138
        to_port     = 138
        protocol    = "udp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 464
        to_port     = 464
        protocol    = "udp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 464
        to_port     = 464
        protocol    = "tcp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 389
        to_port     = 389
        protocol    = "udp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 389
        to_port     = 389
        protocol    = "tcp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 53
        to_port     = 53
        protocol    = "tcp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 123
        to_port     = 123
        protocol    = "udp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 3268
        to_port     = 3269
        protocol    = "tcp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 88
        to_port     = 88
        protocol    = "tcp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 88
        to_port     = 88
        protocol    = "udp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 67
        to_port     = 67
        protocol    = "udp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 135
        to_port     = 135
        protocol    = "tcp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 636
        to_port     = 636
        protocol    = "tcp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 5722
        to_port     = 5722
        protocol    = "tcp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    ingress {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["${var.sg_cidr_blocks}"]
    }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["${var.sg_cidr_blocks}"]
    }

    tags {
        Name    = "${var.security_group_name}"
        terraform   = "yes"
    }
}

resource "aws_instance" "ec2_instance" {
    ami                    = "${var.ami_id}"
    count                  = "${var.number_of_instances}"
    subnet_id              = "${var.subnet_id}"
    instance_type          = "${var.instance_type}"
    key_name               = "${var.key_name}"
    #user_data             = "${file(var.user_data)}"
    vpc_security_group_ids = ["${aws_security_group.domain_controller_sg.id}"]
    root_block_device {
        volume_type = "${var.root_volume_type}"
        volume_size = "${var.root_volume_size}"
        }
    ebs_block_device {
        device_name = "${var.ebs_device_name}"
        volume_type = "${var.ebs_volume_type}"
        volume_size = "${var.ebs_volume_size}"
        }
    tags {
        created_by = "${lookup(var.tags,"created_by")}"
        // Takes the instance_name input variable and adds
        //  the count.index to the name., e.g.
        //  "example-host-web-1"
        Name       = "${var.instance_name}-${count.index + 1}"
        role       = "${var.instance_role}"
        terraform  = "yes"
    }
}
