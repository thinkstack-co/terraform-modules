resource "aws_network_interface" "eni" {
  subnet_id           = "${var.subnet_id}"
  private_ips_count   = "${var.private_ips_count}"
  security_groups     = ["${var.vpc_security_group_ids}"]
  source_dest_check   = "${var.source_dest_check}"
  tags                = "${var.tags}"

  # Attachment varaible conflicts with the attachment within the aws_instance resource
  # attachment          = "${var.attachment}"

  # Do not need to set the private IPs manually as they will be set automatically via DHCP
  # private_ips         = "${var.private_ips}"

  lifecycle           = {
    prevent_destroy   = true
  }
}

resource "aws_instance" "ec2" {
  count                                = "${var.count}"

  ami                                  = "${var.ami}"
  availability_zone                    = "${var.availability_zone}"
  placement_group                      = "${var.placement_group}"
  tenancy                              = "${var.tenancy}"
  ebs_optimized                        = "${var.ebs_optimized}"
  disable_api_termination              = "${var.disable_api_termination}"
  instance_initiated_shutdown_behavior = "${var.instance_initiated_shutdown_behavior}"
  instance_type                        = "${var.instance_type}"
  key_name                             = "${var.key_name}"
  monitoring                           = "${var.monitoring}"
  # vpc_security_group_ids               = ["${var.vpc_security_group_ids}"]
  # subnet_id                            = "${var.subnet_id}"
  # associate_public_ip_address        = "${var.associate_public_ip_address}"
  # private_ip                           = "${var.private_ip}"
  # source_dest_check                    = "${var.source_dest_check}"
  user_data                            = "${var.user_data}"
  iam_instance_profile                 = "${var.iam_instance_profile}"
  # ipv6_address_count                   = "${var.ipv6_address_count}"
  # ipv6_addresses                       = "${var.ipv6_addresses}"
  tags                                 = "${merge(var.tags, map("Name", format("%s_%01d", var.name, count.index + 1)))}"
  volume_tags                          = "${merge(var.tags, map("Name", format("%s_%01d", var.name, count.index + 1)))}"
  # root_block_device                    = "${var.root_block_device}"
  # ebs_block_device                     = "${var.ebs_block_device}"
  # ephemeral_block_device               = "${var.ephemeral_block_device}"

  network_interface {
        network_interface_id    = "${aws_network_interface.eni.id}"
        device_index            = "${var.device_index}"
        delete_on_termination   = "${var.delete_on_termination}"
  }
}
