terraform {
  required_version = ">= 0.12.0"
}

resource "aws_network_interface" "eni" {
  attachment        = var.attachment
  private_ips       = var.private_ips
  private_ips_count = var.private_ips_count
  security_groups   = var.security_groups
  source_dest_check = var.source_dest_check
  subnet_id         = var.subnet_id
  tags              = var.tags
}

resource "aws_network_interface_attachment" "eni_attach" {
  device_index         = var.device_index
  instance_id          = var.instance_id
  network_interface_id = aws_network_interface.eni.id
}
