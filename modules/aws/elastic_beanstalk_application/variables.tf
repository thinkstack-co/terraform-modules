variable "delete_source_from_s3" {
  type        = string
  description = "(Optional) Set to true to delete a version's source bundle from S3 when the application version is deleted."
}

variable "description" {
  type        = string
  description = "(Optional) Short description of the application"
  default     = ""
}

variable "max_age_in_days" {
  type        = string
  description = "(Optional) The number of days to retain an application version."
}

variable "max_count" {
  type        = string
  description = "(Optional) The maximum number of application versions to retain."
}

variable "name" {
  type        = string
  description = "(Required) The name of the application, must be unique within your account"
}

variable "service_role" {
  type        = string
  description = "(Required) The ARN of an IAM service role under which the application version is deleted. Elastic Beanstalk must have permission to assume this role."
}
