terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}

resource "aws_launch_template" "this" {
  ebs_optimized                        = var.ebs_optimized
  image_id                             = var.image_id
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  kernel_id                            = var.kernel_id
  key_name                             = var.key_name
  name_prefix                          = var.name_prefix
  tags                                 = var.tags
  user_data                            = var.user_data
  update_default_version               = var.update_default_version

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name

      ebs {
        delete_on_termination = block_device_mappings.value.ebs.delete_on_termination
        encrypted             = block_device_mappings.value.ebs.encrypted
        iops                  = block_device_mappings.value.ebs.iops
        kms_key_id            = block_device_mappings.value.ebs.kms_key_id
        snapshot_id           = block_device_mappings.value.ebs.snapshot_id
        throughput            = block_device_mappings.value.ebs.throughput
        volume_size           = block_device_mappings.value.ebs.volume_size
        volume_type           = block_device_mappings.value.ebs.volume_type
      }
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_specification
    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference
      capacity_reservation_target {
        capacity_reservation_id = capacity_reservation_specification.value.capacity_reservation_target.capacity_reservation_id
      }
    }
  }

  dynamic "credit_specification" {
    for_each = var.credit_specification
    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  dynamic "enclave_options" {
    for_each = var.enclave_options
    content {
      enabled = enclave_options.value.enabled
    }
  }

  dynamic "hibernation_options" {
    for_each = var.hibernation_options
    content {
      configured = hibernation_options.value.configured
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile
    content {
      arn  = iam_instance_profile.value.arn
      name = iam_instance_profile.value.name
    }
  }

  dynamic "license_specification" {
    for_each = var.license_specification
    content {
      license_configuration_arn = license_specification.value.license_configuration_arn
    }
  }

  dynamic "maintenance_options" {
    for_each = var.maintenance_options
    content {
      maintenance_window                  = maintenance_options.value.maintenance_window
      terminate_instances_with_expiration = maintenance_options.value.terminate_instances_with_expiration
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options
    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      http_tokens                 = metadata_options.value.http_tokens
      instance_metadata_tags      = metadata_options.value.instance_metadata_tags
    }
  }

  dynamic "monitoring" {
    for_each = var.monitoring
    content {
      enabled = monitoring.value.enabled
    }
  }

  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_carrier_ip_address = network_interfaces.value.associate_carrier_ip_address
      associate_public_ip_address  = network_interfaces.value.associate_public_ip_address
      delete_on_termination        = network_interfaces.value.delete_on_termination
      description                  = network_interfaces.value.description
      device_index                 = network_interfaces.value.device_index
      interface_type               = network_interfaces.value.interface_type
      network_interface_id         = network_interfaces.value.network_interface_id
      network_card_index           = network_interfaces.value.network_card_index
      private_ip_address           = network_interfaces.value.private_ip_address
      security_groups              = network_interfaces.value.security_groups
      subnet_id                    = network_interfaces.value.subnet_id
    }
  }

  dynamic "placement" {
    for_each = var.placement
    content {
      affinity          = placement.value.affinity
      availability_zone = placement.value.availability_zone
      group_name        = placement.value.group_name
      host_id           = placement.value.host_id
      spread_domain     = placement.value.spread_domain
      tenancy           = placement.value.tenancy
      partition_number  = placement.value.partition_number
    }
  }

  dynamic "tag_specifications" {
    for_each = var.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type
      tags = tag_specifications.value.tags
    }
  }
}