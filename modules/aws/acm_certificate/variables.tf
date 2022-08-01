variable "domain_name" {
  type        = string
  description = "(Required) A domain name for which the certificate should be issued"
}

variable "validation_method" {
  type        = string
  description = "(Required) Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certificates that were imported into ACM and then into Terraform."
  default     = "DNS"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "(Optional) A list of domains that should be SANs in the issued certificate"
  default     = null
}

variable "tags" {
  type        = map
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
