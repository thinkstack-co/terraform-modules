resource "aws_network_interface" "eni" {
  description         = "${var.description}"
  subnet_id           = "${var.subnet_id}"
  private_ips         = "${var.private_ips}"
  private_ips_count   = "${var.private_ips_count}"
  security_groups     = "${var.vpc_security_group_ids}"
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
  ami                                  = "${var.ami}"
  # associate_public_ip_address          = "${var.associate_public_ip_address}"
  availability_zone                    = "${var.availability_zone}"
  count                                = "${var.count}"
  disable_api_termination              = "${var.disable_api_termination}"
  ebs_optimized                        = "${var.ebs_optimized}"
  # ebs_block_device                     = "${var.ebs_block_device}"
  # ephemeral_block_device               = "${var.ephemeral_block_device}"
  key_name                             = "${var.key_name}"
  monitoring                           = "${var.monitoring}"
  placement_group                      = "${var.placement_group}"
  tenancy                              = "${var.tenancy}"
  instance_initiated_shutdown_behavior = "${var.instance_initiated_shutdown_behavior}"
  instance_type                        = "${var.instance_type}"
  # subnet_id                            = "${var.subnet_id}"
  # private_ip                           = "${var.private_ip}"
  # source_dest_check                    = "${var.source_dest_check}"
  user_data                            = "${var.user_data}"
  iam_instance_profile                 = "${var.iam_instance_profile}"
  # ipv6_address_count                   = "${var.ipv6_address_count}"
  # ipv6_addresses                       = "${var.ipv6_addresses}"
  tags                                 = "${merge(var.tags, map("Name", format("%s%01d", var.name, count.index + 1)))}"
  volume_tags                          = "${merge(var.tags, map("Name", format("%s%01d", var.name, count.index + 1)))}"
  # root_block_device                    = "${var.root_block_device}"
  

  network_interface {
        network_interface_id    = "${aws_network_interface.eni.id}"
        device_index            = "${var.device_index}"
        delete_on_termination   = "${var.delete_on_termination}"
  }

  # vpc_security_group_ids               = "${var.vpc_security_group_ids}"

  lifecycle {
    ignore_changes  = ["volume_tags"]
  }
}
