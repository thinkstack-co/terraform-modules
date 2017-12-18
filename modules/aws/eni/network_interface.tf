resource "aws_network_interface" "eni" {
  subnet_id           = "${var.subnet_id}"
  private_ips         = "${var.private_ips}"
  private_ips_count   = "${var.private_ips_count}"
  security_groups     = "${var.security_groups}"
  attachment          = "${var.attachment}"
  source_dest_check   = "${var.source_dest_check}"
  tags                = "${var.tags}"
}

resource "aws_network_interface_attachment" "eni_attach" {
  instance_id          = "${var.instance_id}"
  network_interface_id = "${aws_network_interface.eni.id}"
  device_index         = "${var.device_index}"
}
