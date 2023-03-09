variable "ebs_optimized" {
    type        = bool
    description = "(Optional) If true, the launched EC2 instance will be EBS-optimized. Default is true"
    default     = true
    validation {
        condition = can(regex("^(true|false)$", var.ebs_optimized))
        error_message = "ebs_optimized must be either true or false"
    }
}

variable "image_id" {
    type        = string
    description = "(Required) The AMI from which to launch the instance."
    validation {
      condition = can(regex("^ami-[0-9a-f]{17}$", var.image_id))
    error_message = "image_id must be a valid AMI ID"
    }
}

variable "instance_initiated_shutdown_behavior" {
    type        = string
    description = "(Optional) Shutdown behavior for the instance. Can be stop or terminate. Default is stop."
    default     = "stop"
    validation {
        condition = can(regex("^(stop|terminate)$", var.instance_initiated_shutdown_behavior))
        error_message = "instance_initiated_shutdown_behavior must be either stop or terminate"
    }
}

variable "instance_type" {
    type        = string
    description = "(Required) The type of the instance. If present then instance_requirements cannot be present."
}

variable "kernel_id" {
    type        = string
    description = "(Optional) The ID of the kernel."
    default     = null
    validation {
        condition = can(regex("^aki-[0-9a-f]{17}$", var.kernel_id)) || var.kernel_id == null
        error_message = "kernel_id must be a valid kernel ID"
    }
}

variable "key_name" {
    type        = string
    description = "(Optional) The key name that should be used for the instance."
    default     = null
}

variable "name_prefix" {
    type        = string
    description = "(Required) Creates a unique name for the launch template beginning with the specified prefix. Conflicts with name."
}

variable "tags" {
    type        = map(string)
    description = "(Optional) A map of tags to assign to the launch template. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
    default     = {
        terraform = "true"
    }
}

variable "user_data" {
    type        = string
    description = "(Optional) The Base64-encoded user data to provide when launching the instance."
    default     = null
}

variable "update_default_version" {
    type        = bool
    description = "(Optional) Whether to update Default Version each update. Conflicts with default_version. Default is false."
    default     = true
    validation {
        condition = can(regex("^(true|false)$", var.update_default_version))
        error_message = "update_default_version must be either true or false"
    }
}

variable "vpc_security_group_ids" {
    type        = list(string)
    description = "(Optional) A list of security group IDs to associate with. Conflicts with network_interfaces.security_groups"
    default     = []
}

variable "block_device_mappings" {
    type        = list(object({
        device_name = string
        ebs = object({
            delete_on_termination = bool
            encrypted             = bool
            iops                  = number
            kms_key_id            = string
            snapshot_id           = string
            throughput            = number
            volume_size           = number
            volume_type           = string
        })
    }))
    description = "(Optional) Customize EBS volumes attached to the instance."
    default     = []
}


variable "credit_specification" {
    type        = object({
        cpu_credits = string
    })
    description = "(Optional) Customize the credit specification of the instance. See Credit Specification below for more details."
    default     = {
        cpu_credits = "standard"
    }
}

variable "enclave_options" {
    type        = object({
        enabled = bool
    })
    description = "(Optional) Customize the Enclave Options of the instance. See Enclave Options below for more details."
    default     = {
        enabled = false
    }
}

variable "hibernation_options" {
    type        = object({
        configured = bool
    })
    description = "(Optional) Customize the Hibernation Options of the instance. See Hibernation Options below for more details."
    default     = {
        configured = false
    }
}

variable "iam_instance_profile" {
    type        = object({
        arn = string
        name = string
    })
    description = "(Optional) Customize the IAM Instance Profile of the instance. See IAM Instance Profile below for more details."
    default     = {
        arn = null
        name = null
    }
}

variable "license_specification" {
    type        = list(object({
        license_configuration_arn = string
    }))
    description = "(Optional) Customize the License Specification of the instance. See License Specification below for more details."
    default     = null
}

variable "auto_recovery" {
    type        = string
    description = "(Optional) Disables the automatic recovery behavior of your instance or sets it to default. Can be 'default' or 'disabled'. See Recover your instance for more details."
    default     = "default"
}

variable "metadata_options" {
    type        = object({
        http_endpoint               = string
        http_put_response_hop_limit = number
        http_tokens                 = string
    })
    description = "(Optional) Customize the Metadata Options of the instance. See Metadata Options below for more details."
    default     = {
        http_endpoint               = "enabled"
        http_put_response_hop_limit = 1
        http_tokens                 = "required"
        instance_metadata_tags      = "enabled"
    }
}

variable "monitoring_enabled" {
    type        = bool
    description = "(Optional) If true, the launched EC2 instance will have detailed monitoring enabled. Default is true."
    default     = true
    validation {
        condition = can(regex("^(true|false)$", var.monitoring_enabled))
        error_message = "monitoring_enabled must be either true or false"
    }
}

variable "network_interfaces" {
    type        = list(object({
        associate_carrier_ip_address = bool
        associate_public_ip_address  = bool
        delete_on_termination        = bool
        description                  = string
        device_index                 = number
        ipv6_address_count           = number
        ipv6_addresses               = list(string)
        network_interface_id         = string
        private_ip_address           = string
        security_groups              = list(string)
        subnet_id                    = string
    }))
    description = "(Optional) Customize the Network Interfaces of the instance. See Network Interfaces below for more details."
    default     = null
}

variable "placement" {
    type        = object({
        affinity          = string
        availability_zone = string
        group_name        = string
        host_id           = string
        spread_domain     = string
        tenancy           = string
    })
    description = "(Optional) Customize the Placement of the instance. See Placement below for more details."
    default     = null
}

variable "tag_specifications" {
    type        = list(object({
        resource_type = string
        tags          = map(string)
    }))
    description = "(Optional) Customize the Tag Specifications of the instance. See Tag Specifications below for more details."
    default     = [{
        resource_type = "instance"
        tags          = {
            terraform       = "true"
            environment     = "prod"
            launch_template = "true"
        }
    },
    {
        resource_type = "volume"
        tags          = {
            terraform       = "true"
            environment     = "prod"
            launch_template = "true"
        }
    }]
}
