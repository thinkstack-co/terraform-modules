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
  vpc_security_group_ids               = var.vpc_security_group_ids

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

  dynamic "credit_specification" {
    for_each = var.credit_specification
    content {
      cpu_credits = credit_specification.value
    }
  }

  dynamic "enclave_options" {
    for_each = var.enclave_options != null ? var.enclave_options : {}
    content {
      enabled = enclave_options.value.enabled
    }
  }

  dynamic "hibernation_options" {
    for_each = var.hibernation_options != null ? var.hibernation_options : {}
    content {
      configured = hibernation_options.value.configured
    }
  }

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  dynamic "license_specification" {
    for_each = var.license_specification != null ? var.license_specification : []
    content {
      license_configuration_arn = license_specification.value.license_configuration_arn
    }
  }

  maintenance_options {
    auto_recovery = var.auto_recovery
  }

  metadata_options {
    http_endpoint               = var.http_endpoint
    http_put_response_hop_limit = var.http_put_response_hop_limit
    http_protocol_ipv6          = var.http_protocol_ipv6
    http_tokens                 = var.http_tokens
    instance_metadata_tags      = var.instance_metadata_tags
  }

  monitoring {
    enabled = var.monitoring_enabled
  }

  dynamic "network_interfaces" {
    for_each = var.network_interfaces != null ? var.network_interfaces : []
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
    for_each = var.placement != null ? var.placement : {}
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
    for_each = var.tag_specifications != null ? var.tag_specifications : []
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }
}
