resource "aws_launch_configuration" "this" {
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_options {
    core_count = 1
    threads_per_core = 1
  }

  credit_specification {
    cpu_credits = "standard"
  }

  default_version = var.default_version
  description     = var.description
  disable_api_stop = var.disable_api_stop
  disable_api_termination = var.disable_api_termination
  ebs_optimized = var.ebs_optimized

  iam_instance_profile {
    arn = var.iam_instance_profile_arn
    name = var.iam_instance_profile_name
  }
  
  image_id = var.image_id
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type = var.instance_type
  key_name = var.key_name
  name_prefix = var.name_prefix



}