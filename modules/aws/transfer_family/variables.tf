variable "address_allocation_ids" {
  description = "List of Elastic IP addresses for the VPC endpoint"
  type        = list(string)
  default     = [""]
}

variable "domain" {
  description = "The domain used by the Transfer Family server. Valid values are: S3 and EFS. The default value is S3."
  type        = string
  default     = "S3"
}

variable "endpoint_details" {
  description = "The VPC endpoint settings that are configured for your server"
  type        = any # This can be complex, you might need to structure the input or use a map.
  default     = null
}

variable "endpoint_type" {
  description = "The endpoint type for the Transfer Family server"
  default     = "VPC"
}

variable "force_destroy" {
  description = "A boolean that indicates all user data is deleted when the server is deleted"
  type        = bool
  default     = false
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID. Only required if using VPC_ENDPOINT type."
  type        = string
  default     = null
}

variable "identity_provider_type" {
  description = "The mode of authentication for the server. Choices: SERVICE_MANAGED, API_GATEWAY. Default is SERVICE_MANAGED."
  type        = string
  default     = "SERVICE_MANAGED"
}

variable "invocation_role" {
  description = "The Amazon Resource Name (ARN) of the role that allows the server to turn on Amazon CloudWatch logging."
  type        = string
  default     = null
}

variable "logging_role" {
  description = "A role that allows the server to monitor your user activity"
  type        = string
  default     = null
}

variable "protocols" {
  description = "The protocols enabled for your server. Choices: SFTP, FTP, FTPS. Default is [SFTP]."
  type        = list(string)
  default     = ["SFTP"]
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the Transfer Family server"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the Transfer Family server"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default = {
    terraform   = "true"
    environment = "prod"
    project     = "SIEM Implementation"
    team        = "Security Team"
    used_by     = "ThinkStack"
  }
}

variable "url" {
  description = "The endpoint URL of the Transfer Family server"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID to associate with the Transfer Family server"
  type        = string
  default     = null
}
