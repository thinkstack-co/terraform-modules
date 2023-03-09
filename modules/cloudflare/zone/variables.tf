variable "account_id" {
  type        = string
  description = "(Required) Account ID to manage the zone resource in."
}

variable "jump_start" {
  type        = bool
  description = "(Optional) Whether to scan for DNS records on creation. Ignored after zone is created."
  default     = false
}

variable "paused" {
  type        = bool
  description = "(Optional)(Boolean) Whether this zone is paused (traffic bypasses Cloudflare). Defaults to false."
  default     = false
}

variable "plan" {
  type        = string
  description = "(Optional)The name of the commercial plan to apply to the zone. Available values: free, lite, pro, pro_plus, business, enterprise, partners_free, partners_pro, partners_business, partners_enterprise."
  default     = "free"
  validation {
    condition     = can(regex("free|lite|pro|pro_plus|business|enterprise|partners_free|partners_pro|partners_business|partners_enterprise", var.plan))
    error_message = "The plan must be one of the following: free, lite, pro, pro_plus, business, enterprise, partners_free, partners_pro, partners_business, partners_enterprise."
  }
}

variable "type" {
  type        = string
  description = "(Optional) A full zone implies that DNS is hosted with Cloudflare. A partial zone is typically a partner-hosted zone or a CNAME setup. Available values: full, partial. Defaults to full."
  default     = "full"
  validation {
    condition     = can(regex("full|partial", var.type))
    error_message = "The type must be one of the following: full, partial."
  }
}

variable "zone" {
  type        = string
  description = "(Required) The DNS zone name which will be added. Modifying this attribute will force creation of a new resource."
}
