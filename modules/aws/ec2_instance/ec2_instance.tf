######
# EC2 instance Module
######
resource "aws_instance" "ec2" {
  ami                                  = "${var.ami}"
  associate_public_ip_address          = "${var.associate_public_ip_address}"
  availability_zone                    = "${var.availability_zone}"
  count                                = "${var.count}"
  disable_api_termination              = "${var.disable_api_termination}"
  ebs_optimized                        = "${var.ebs_optimized}"
  ephemeral_block_device               = "${var.ephemeral_block_device}"
  iam_instance_profile                 = "${var.iam_instance_profile}"
  instance_initiated_shutdown_behavior = "${var.instance_initiated_shutdown_behavior}"
  instance_type                        = "${var.instance_type}"
  ipv6_address_count                   = "${var.ipv6_address_count}"
  ipv6_addresses                       = "${var.ipv6_addresses}"
  key_name                             = "${var.key_name}"
  monitoring                           = "${var.monitoring}"
  placement_group                      = "${var.placement_group}"
  private_ip                           = "${var.private_ip}"
  root_block_device                    = {
    delete_on_termination = "${var.root_delete_on_termination}"
    # iops                  = "${var.root_iops}"
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
  }
  # ebs_block_device     = "${var.ebs_block_device}"
  source_dest_check      = "${var.source_dest_check}"
  subnet_id              = "${var.subnet_id}"
  tags                   = "${merge(var.tags, map("Name", format("%s%d", var.name, count.index + 1)))}"
  tenancy                = "${var.tenancy}"
  user_data              = "${var.user_data}"
  volume_tags            = "${merge(var.volume_tags, map("Name", format("%s%d", var.name, count.index + 1)))}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]

  lifecycle {
    ignore_changes  = ["volume_tags"]
  }
}
