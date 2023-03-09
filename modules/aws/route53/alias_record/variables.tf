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

variable "alias_name" {
  type        = string
  description = "(Optional, Required for alias record) DNS domain name for a CloudFront distribution, S3 bucket, ELB, or another resource record set in this hosted zone."
  default     = null
}

variable "alias_zone_id" {
  type        = string
  description = "(Optional, Required for alias record) Hosted zone ID for a CloudFront distribution, S3 bucket, ELB, or Route 53 hosted zone. See resource_elb.zone_id for example."
  default     = null
}

variable "alias_evaluate_target_health" {
  type        = bool
  description = "(Optional, Required for alias record) Set to true if you want Route 53 to determine whether to respond to DNS queries using this resource record set by checking the health of the resource record set. Some resources have special requirements, see related part of documentation."
  default     = null
}

variable "weighted_routing_policy_weight" {
  type        = number
  description = "(Optional, Required for weighted routing) A numeric value indicating the relative weight of the record. See http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-weighted."
  default     = null
}

variable "latency_routing_policy_region" {
  type        = string
  description = "(Optional, Required for latency routing) An AWS region from which to measure latency. See http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-latency"
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

variable "failover_routing_policy_type" {
  type        = string
  description = "(Optional, Required for failover routing) PRIMARY or SECONDARY. A PRIMARY record will be served if its healthcheck is passing, otherwise the SECONDARY will be served. See http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-configuring-options.html#dns-failover-failover-rrsets"
  default     = null
}
