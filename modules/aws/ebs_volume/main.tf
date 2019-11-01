terraform {
  required_version = ">= 0.12.0"
}

resource "aws_ebs_volume" "vol" {
  availability_zone = var.availability_zone
  encrypted         = var.encrypted
  # iops              = var.iops
  size              = var.size
  snapshot_id       = var.snapshot_id
  type              = var.type
  tags              = var.tags
}

resource "aws_volume_attachment" "vol_attach" {
  device_name = var.device_name
  instance_id = var.instance_id
  volume_id   = aws_ebs_volume.vol.id
}
