terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_ebs_volume" "vol" {
  availability_zone    = var.availability_zone
  encrypted            = var.encrypted
  final_snapshot       = var.final_snapshot
  iops                 = var.iops
  kms_key_id           = var.kms_key_id
  multi_attach_enabled = var.multi_attach_enabled
  size                 = var.size
  snapshot_id          = var.snapshot_id
  type                 = var.type
  tags                 = var.tags
  throughput           = var.throughput
}

resource "aws_volume_attachment" "vol_attach" {
  device_name                    = var.device_name
  force_detach                   = var.force_detach
  instance_id                    = var.instance_id
  skip_destroy                   = var.skip_destroy
  stop_instance_before_detaching = var.stop_instance_before_detaching
  volume_id                      = aws_ebs_volume.vol.id
}
