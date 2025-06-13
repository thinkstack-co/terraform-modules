variable "listener_arn" {
  type        = string
  description = "The ARN of the listener to attach the rule."
}

variable "priority" {
  type        = number
  description = "The priority for the rule between 1 and 50000. If unset, the next available priority after the current highest rule will be used. A listener can't have multiple rules with the same priority."
  default     = null
}

variable "target_group_arn" {
  type        = string
  description = "The ARN of the Target Group to which to route traffic."
}

variable "condition_field" {
  type        = string
  description = "The name of the field. It must be 'path-pattern' for path-based routing or 'host-header' for host-based routing."
}

variable "condition_values" {
  type        = list(string)
  description = "The path patterns to match. A maximum of 1 can be defined."
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "type" {
  type        = string
  description = "(Required) Type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc."
  default     = "forward"
}

variable "conditions" {
  description = "A list of listener rule conditions. Each item is an object with a single key (the condition type) and a value (the values for that condition). Example: [{ host_header = [\"example.com\"] }, { path_pattern = [\"/foo*\"] }]"
  type = list(object({
    host_header  = optional(list(string))
    path_pattern = optional(list(string))
    http_header = optional(object({
      http_header_name = string
      values           = list(string)
    }))
    http_request_method = optional(list(string))
    query_string = optional(list(object({
      key   = optional(string)
      value = string
    })))
    source_ip = optional(list(string))
    # Add more supported condition types as needed
  }))
  default = []
  validation {
    condition = alltrue([
      for cond in var.conditions : length(keys(cond)) > 0
    ])
    error_message = "Each condition object must have at least one non-null property."
  }
}