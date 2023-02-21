terraform {
  required_version = ">= 0.12.0"
}

resource "aws_instance" "ec2_instance" {
  ami                    = var.ami_id
  count                  = var.number_of_instances
  ebs_optimized          = var.ebs_optimized
  subnet_id              = var.subnet_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = var.user_data
  private_ip             = var.private_ip
  vpc_security_group_ids = var.security_group_ids
  volume_tags            = merge(var.tags, ({ "Name" = format("%s%01d", var.instance_name_prefix, count.index + 1) }))
  tags                   = merge(var.tags, ({ "Name" = format("%s%01d", var.instance_name_prefix, count.index + 1) }))
  /*    root_block_device {
        volume_type = var.root_volume_type
        volume_size = var.root_volume_size
        }
    ebs_block_device {
        device_name = var.ebs_device_name
        volume_type = var.ebs_volume_type
        volume_size = var.ebs_volume_size
        }*/

  lifecycle {
    ignore_changes = [ami, user_data]
  }

}
