variable "allow_overwrite" {
  type        = bool
  description = "(Optional) Allow creation of this record in Terraform to overwrite an existing record, if any. This does not affect the ability to update the record in Terraform and does not prevent other resources within Terraform or manual changes outside Terraform from overwriting this record. This configuration is not recommended for most environments. Defaults to false."
  default     = false
}

variable "comment" {
  type        = string
  description = "(Optional) Comments or notes about the DNS record. This field has no effect on DNS responses."
  default     = null
}

variable "name" {
  type        = string
  description = "(Required) The name of the DNS record. This can be a subdomain (www), an apex domain (@), or a wildcard (*.)."
}

variable "priority" {
  type        = number
  description = "(Optional) The priority of the target host. Lower values are preferred. This is only used for MX and SRV records. Defaults to 0."
  default     = 0
}

variable "proxied" {
  type        = bool
  description = "(Optional) Whether the record is receiving the performance and security benefits of Cloudflare. Defaults to false."
  default     = false
}

variable "tags" {
  type        = list(string)
  description = "(Optional) A list of tags to assign to the record. Tags are used for filtering and organizing resources in the Cloudflare dashboard."
  default     = []
}

variable "ttl" {
  type        = number
  description = "(Optional) The Time To Live (TTL) of the record, in seconds. Defaults to 1."
  default     = 1
}

variable "type" {
  type        = string
  description = "(Required)The type of the record. Available values: A, AAAA, CAA, CNAME, TXT, SRV, LOC, MX, NS, SPF, CERT, DNSKEY, DS, NAPTR, SMIMEA, SSHFP, TLSA, URI, PTR, HTTPS."
  validation {
    condition     = can(regex("^(A|AAAA|CAA|CNAME|TXT|SRV|LOC|MX|NS|SPF|CERT|DNSKEY|DS|NAPTR|SMIMEA|SSHFP|TLSA|URI|PTR|HTTPS)$", var.type))
    error_message = "The type must be one of the following: A, AAAA, CAA, CNAME, TXT, SRV, LOC, MX, NS, SPF, CERT, DNSKEY, DS, NAPTR, SMIMEA, SSHFP, TLSA, URI, PTR, HTTPS."
  }
}

variable "value" {
  type        = string
  description = "(Required) The value of the record. This can be a domain name, IP address, or other value depending on the type of record."
}

variable "zone_id" {
  type        = string
  description = "(Required) The ID of the zone to which the record belongs."
}