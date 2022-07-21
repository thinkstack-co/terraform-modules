# variable "template" {
#   description = "value"
#   type        = 
#   default     = 
# }

variable "enable_deletion_protection" {
  description = "(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = bool
  default     = false
}

variable "internal" {
  description = "(Optional) If true, the LB will be internal."
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "(Optional) The type of load balancer to create. Possible values are application, gateway, or network. The default value is application."
  type        = string
  default     = "network"
}

variable "name" {
  description = "(Optional) The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map
  default     = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
  }
}

variable "subnet_1_id" {
  description = "(Required) The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone."
  type        = string
}

variable "allocation_1_id" {
  description = "(Optional) The allocation ID of the Elastic IP address."
  type        = string
  default     = null
}

variable "subnet_2_id" {
  description = "(Optional) The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone."
  type        = string
  default     = null
}

variable "allocation_2_id" {
  description = "(Optional) The allocation ID of the Elastic IP address."
  type        = string
  default     = null
}

variable "subnet_3_id" {
  description = "(Optional) The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone."
  type        = string
  default     = null
}

variable "allocation_3_id" {
  description = "(Optional) The allocation ID of the Elastic IP address."
  type        = string
  default     = null
}