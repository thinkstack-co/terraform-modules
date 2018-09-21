resource "aws_security_group" "fortigate_fw_sg" {
    name    = "${var.sg_name}"
    description = "Security group applied to all fortigate firewalls"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }

    tags            = "${merge(var.tags, map("Name", format("%s", var.sg_name)))}"
}

resource "aws_eip" "external_ip" {
  vpc   = true
  count = "${var.count}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip_association" "fw_external_ip" {
    count                   = "${var.count}"
    allocation_id           = "${element(aws_eip.external_ip.*.id, count.index)}"
    network_interface_id    = "${element(aws_network_interface.fw_public_nic.*.id, count.index)}"
}

resource "aws_network_interface" "fw_public_nic" {
    count               = "${var.count}"
    description         = "${var.public_nic_description}"
    private_ips         = "${var.wan_private_ips}"
    security_groups     = ["${aws_security_group.fortigate_fw_sg.id}"]
    source_dest_check   = "${var.source_dest_check}"
    subnet_id           = "${element(var.public_subnet_id, count.index)}"
    tags                = "${merge(var.tags, map("Name", format("%s%d_public", var.instance_name_prefix, count.index + 1)))}"
}

resource "aws_network_interface" "fw_private_nic" {
    count               = "${var.count}"
    description         = "${var.private_nic_description}"
    private_ips         = ["${element(var.lan_private_ips, count.index)}"]
    security_groups     = ["${aws_security_group.fortigate_fw_sg.id}"]
    source_dest_check   = "${var.source_dest_check}"
    subnet_id           = "${element(var.private_subnet_id, count.index)}"
    tags                = "${merge(var.tags, map("Name", format("%s%d_private", var.instance_name_prefix, count.index + 1)))}"

    attachment {
        instance        = "${element(aws_instance.ec2_instance.*.id, count.index)}"
        device_index    = 1
    }
}

resource "aws_network_interface" "fw_dmz_nic" {
    count               = "${var.enable_dmz ? var.count : 0}"
    description         = "${var.dmz_nic_description}"
    private_ips         = ["${element(var.dmz_private_ips, count.index)}"]
    security_groups     = ["${aws_security_group.fortigate_fw_sg.id}"]
    source_dest_check   = "${var.source_dest_check}"
    subnet_id           = "${element(var.dmz_subnet_id, count.index)}"
    tags                = "${merge(var.tags, map("Name", format("%s%d_dmz", var.instance_name_prefix, count.index + 1)))}"

    attachment {
        instance        = "${element(aws_instance.ec2_instance.*.id, count.index)}"
        device_index    = 2
    }
}

resource "aws_instance" "ec2_instance" {
    ami           = "${var.ami_id}"
    count         = "${var.count}"
    ebs_optimized = "${var.ebs_optimized}"
    instance_type = "${var.instance_type}"
    key_name      = "${var.key_name}"
    monitoring    = "${var.monitoring}"
    volume_tags   = "${merge(var.tags, map("Name", format("%s%d", var.instance_name_prefix, count.index + 1)))}"
    tags          = "${merge(var.tags, map("Name", format("%s%d", var.instance_name_prefix, count.index + 1)))}"

    network_interface {
        network_interface_id = "${aws_network_interface.fw_public_nic.id}"
        device_index         = 0
    }

    root_block_device {
        volume_type = "${var.root_volume_type}"
        volume_size = "${var.root_volume_size}"
    }
    ebs_block_device {
        device_name = "${var.ebs_device_name}"
        volume_type = "${var.ebs_volume_type}"
        volume_size = "${var.ebs_volume_size}"
        encrypted   = "${var.ebs_volume_encrypted}"
    }
}
