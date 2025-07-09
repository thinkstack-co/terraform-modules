variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "dr_region" {
  description = "DR region for cross-region backup copies"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project, used for naming resources"
  type        = string
  default     = "weekly-backup-example"
}

variable "enable_dr" {
  description = "Whether to enable DR vaults and cross-region copies"
  type        = bool
  default     = false
}

variable "enable_vault_lock" {
  description = "Whether to enable vault lock for compliance"
  type        = bool
  default     = false
}

variable "create_example_resources" {
  description = "Whether to create example resources (EC2, EBS, EFS) to demonstrate backups"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    terraform   = "true"
    created_by  = "terraform"
    environment = "example"
    backup_type = "weekly"
  }
}