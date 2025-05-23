variable "zone_id" {
  type        = string
  description = "(Required) The ID of the hosted zone to contain this record."
}

variable "name" {
  type        = string
  description = "(Required) The name of the record."
}

variable "type" {
  type        = string
  description = "(Required) The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT."
  validation {
    condition     = contains(["A", "AAAA", "CAA", "CNAME", "DS", "MX", "NAPTR", "NS", "PTR", "SOA", "SPF", "SRV", "TXT"], var.type)
    error_message = "The value must be one of A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV or TXT."
  }
}

variable "ttl" {
  type        = number
  description = "(Optional, Required for non-alias records) The TTL of the record in seconds."
  default     = 300
}

variable "records" {
  type        = list(string)
  description = "(Required for non-alias records) A string list of records. To specify a single record value longer than 255 characters such as a TXT record for DKIM, add \"\" inside the Terraform configuration string."
}

variable "set_identifier" {
  type        = string
  description = "(Optional) Unique identifier to differentiate records with routing policies from one another. Required if using failover, geolocation, latency, multivalue_answer, or weighted routing policies documented below."
  default     = null
}

variable "health_check_id" {
  type        = string
  description = "(Optional) The health check the record should be associated with."
  default     = null
}

variable "geolocation_routing_policy_continent" {
  type        = string
  description = "(Optional) A two-letter continent code. See http://docs.aws.amazon.com/Route53/latest/APIReference/API_GetGeoLocation.html for code details. Either continent or country must be specified."
  default     = null
}

variable "geolocation_routing_policy_country" {
  type        = string
  description = "(Optional) A two-character country code or * to indicate a default resource record set."
  default     = null
}

variable "geolocation_routing_policy_subdivision" {
  type        = string
  description = "(Optional) A subdivision code for a country."
  default     = null
}

# Removed all unused variables flagged by tflint
