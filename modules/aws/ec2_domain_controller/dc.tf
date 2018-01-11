resource "aws_instance" "ec2_instance" {
    ami                                  = "${var.ami}"
    # This is redundant with the subnet_id option set. The subnet_id already defines an availability zone
    # availability_zone                    = "${element(var.availability_zone, count.index)}"
    count                                = "${var.count}"
    disable_api_termination              = "${var.disable_api_termination}"
    ebs_optimized                        = "${var.ebs_optimized}"
    iam_instance_profile                 = "${var.iam_instance_profile}"
    instance_initiated_shutdown_behavior = "${var.instance_initiated_shutdown_behavior}"
    instance_type                        = "${var.instance_type}"
    key_name                             = "${var.key_name}"
    monitoring                           = "${var.monitoring}"
    placement_group                      = "${var.placement_group}"
    private_ip                           = "${element(var.private_ip, count.index)}"
    root_block_device                    = {
        delete_on_termination = "${var.root_delete_on_termination}"
        # iops                = "${var.root_iops}"
        volume_size           = "${var.root_volume_size}"
        volume_type           = "${var.root_volume_type}"
    }
    source_dest_check      = "${var.source_dest_check}"
    subnet_id              = "${element(var.subnet_id, count.index)}"
    tenancy                = "${var.tenancy}"
    tags                   = "${merge(var.tags, map("Name", format("%s-%01d", var.name, count.index + 1)))}"
    user_data              = "${var.user_data}"
    volume_tags            = "${merge(var.tags, map("Name", format("%s-%01d", var.name, count.index + 1)))}"
    vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
}

resource "aws_vpc_dhcp_options" "dc_dns" {
    domain_name_servers = ["${aws_instance.ec2_instance.*.private_ip}"]
    domain_name         = "${var.domain_name}"
    tags                = "${merge(var.tags, map("Name", format("%s-dhcp-options", var.name)))}"
}

resource "aws_vpc_dhcp_options_association" "dc_dns" {
    dhcp_options_id = "${aws_vpc_dhcp_options.dc_dns.id}"
    vpc_id          = "${var.vpc_id}"
}
