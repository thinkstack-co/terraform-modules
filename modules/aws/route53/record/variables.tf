variable "zone_id" {
    type = string
    description = "(Required) The ID of the hosted zone to contain this record."
}

variable "name" {
    type = string
    description = "(Required) The name of the record."
}

variable "type" {
    type = string
    description = "(Required) The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT."
}

variable "ttl" {
    type = number
    description = "(Required for non-alias records) The TTL of the record."
}

variable "records" {
    type = list(string)
    description = "(Required for non-alias records) A string list of records. To specify a single record value longer than 255 characters such as a TXT record for DKIM, add \"\" inside the Terraform configuration string."
}

variable "set_identifier" {
    type = string
    description = "(Optional) Unique identifier to differentiate records with routing policies from one another. Required if using failover, geolocation, latency, multivalue_answer, or weighted routing policies documented below."
}

variable "health_check_id" {
    type = string
    description = "(Optional) The health check the record should be associated with."
}

variable "alias_name" {
    type = string
    description = "(Required) DNS domain name for a CloudFront distribution, S3 bucket, ELB, or another resource record set in this hosted zone."
}

variable "alias_zone_id" {
    type = string
    description = "(Required) Hosted zone ID for a CloudFront distribution, S3 bucket, ELB, or Route 53 hosted zone. See resource_elb.zone_id for example."
}

variable "alias_evaluate_target_health" {
    type = bool
    description = "(Required) Set to true if you want Route 53 to determine whether to respond to DNS queries using this resource record set by checking the health of the resource record set. Some resources have special requirements, see related part of documentation."
}

variable "weighted_routing_policy_weight" {
    type = number
    description = "(Required) A numeric value indicating the relative weight of the record. See http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-weighted."
}

variable "latency_routing_policy_region" {
    type = string
    description = "(Required) An AWS region from which to measure latency. See http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-latency"
}

variable "geolocation_routing_policy_continent" {
    type = string
    description = "A two-letter continent code. See http://docs.aws.amazon.com/Route53/latest/APIReference/API_GetGeoLocation.html for code details. Either continent or country must be specified."
}

variable "geolocation_routing_policy_country" {
    type = string
    description = "A two-character country code or * to indicate a default resource record set."
}

variable "geolocation_routing_policy_subdivision" {
    type = string
    description = "(Optional) A subdivision code for a country."
}

variable "failover_routing_policy_type" {
    type = string
    description = "(Required) PRIMARY or SECONDARY. A PRIMARY record will be served if its healthcheck is passing, otherwise the SECONDARY will be served. See http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover-configuring-options.html#dns-failover-failover-rrsets"
}

variable "multivalue_answer_routing_policy_enabled" {
    type = bool
    description = "(Optional) Set to true to indicate a multivalue answer routing policy. Conflicts with any other routing policy."
}
