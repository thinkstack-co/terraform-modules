variable "role_name" {
  description = "The name of the IAM role that AWS Backup uses to authenticate when backing up the target resource"
  type        = string
  default     = "aws-backup-service-role"
}

variable "enable_tag_based_selection" {
  description = "Whether to create and attach a policy that allows AWS Backup to select resources based on tags"
  type        = bool
  default     = true
}

variable "additional_policy_arns" {
  description = "List of additional policy ARNs to attach to the backup role"
  type        = list(string)
  default     = []
}

variable "enable_s3_backup" {
  description = "Whether to attach the S3 backup policy to the role"
  type        = bool
  default     = false
}

variable "enable_resource_discovery" {
  description = "Whether to create a policy for resource discovery (recommended for tag-based selection)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to the IAM role"
  type        = map(string)
  default     = {}
}