###########################
# KMS Variables
###########################

variable "key_customer_master_key_spec" {
  description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide."
  default     = "SYMMETRIC_DEFAULT"
  type        = string
  validation {
    condition     = can(regex("^(SYMMETRIC_DEFAULT|RSA_2048|RSA_3072|RSA_4096|ECC_NIST_P256|ECC_NIST_P384|ECC_NIST_P521|ECC_SECG_P256K1)$", var.key_customer_master_key_spec))
    error_message = "The value must be one of SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1."
  }
}

variable "key_description" {
  description = "(Optional) The description of the key as viewed in AWS console."
  default     = "CloudTrail kms key used to encrypt audit logs"
  type        = string
}

variable "key_deletion_window_in_days" {
  description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
  default     = 30
  type        = number
  validation {
    condition     = can(regex("^[7-9]|[1-2][0-9]|30$", var.key_deletion_window_in_days))
    error_message = "The value must be between 7 and 30 days."
  }
}

variable "key_enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  default     = true
  type        = bool
  validation {
    condition     = can(regex("^(true|false)$", var.key_enable_key_rotation))
    error_message = "The value must be true or false."
  }
}

variable "key_usage" {
  description = "(Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
  default     = "ENCRYPT_DECRYPT"
  type        = string
}

variable "key_is_enabled" {
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true
  type        = bool
  validation {
    condition     = can(regex("^(true|false)$", var.key_is_enabled))
    error_message = "The value must be true or false."
  }
}

variable "key_name_prefix" {
  description = "(Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/)."
  default     = "alias/rds_key_"
  type        = string
}

###########################
# RDS Variables
###########################

variable "apply_immediately" {
  description = "(Optional) Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Default is false. See Amazon RDS Documentation for more information."
  default     = false
}

variable "availability_zones" {
  type        = list(any)
  description = "(Optional) A list of EC2 Availability Zones that instances in the DB cluster can be created in"
}

variable "backup_retention_period" {
  description = "(Optional) The days to retain backups for. Default 1"
  default     = 30
}

variable "cluster_identifier" {
  type        = string
  description = "(Optional, Forces new resources) The cluster identifier. If omitted, Terraform will assign a random, unique identifier."
}

variable "database_name" {
  type        = string
  description = "(Optional) Name for an automatically created database on cluster creation. There are different naming restrictions per database engine: RDS Naming Constraints"
}

variable "db_subnet_group_name" {
  type        = string
  description = "(Optional) A DB subnet group to associate with this DB instance. NOTE: This must match the db_subnet_group_name specified on every aws_rds_cluster_instance in the cluster."
}

variable "db_cluster_parameter_group_name" {
  type        = string
  description = "(Optional) A cluster parameter group to associate with the cluster."
}

variable "engine" {
  type        = string
  description = "(Optional) The name of the database engine to be used for this DB cluster. Defaults to aurora."
}

variable "engine_mode" {
  type        = string
  description = "(Optional) The database engine mode. Valid values: provisioned, serverless. Defaults to: provisioned. See the RDS User Guide for limitations when using serverless."
}

variable "engine_version" {
  type        = string
  description = "(Optional) The database engine version."
}

/*variable "final_snapshot_identifier" {
  type        = string
  description = "(Optional) The name of your final DB snapshot when this DB cluster is deleted. If omitted, no final snapshot will be made."
  default     = []
}*/

variable "iam_roles" {
  type        = list(any)
  description = "(Optional) A List of ARNs for the IAM roles to associate to the RDS Cluster."
  default     = []
}

variable "iam_database_authentication_enabled" {
  description = "(Optional) Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled."
  default     = false
}

variable "kms_key_id" {
  type        = string
  description = "(Optional) The ARN for the KMS encryption key. When specifying kms_key_id, storage_encrypted needs to be set to true."
  default     = ""
}

variable "master_password" {
  type        = string
  description = "(Required unless a snapshot_identifier is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the RDS Naming Constraints"
}

variable "master_username" {
  type        = string
  description = "(Required unless a snapshot_identifier is provided) Username for the master DB user. Please refer to the RDS Naming Constraints"
}

variable "port" {
  type        = string
  description = "(Optional) The port on which the DB accepts connections"
}

variable "preferred_backup_window" {
  type        = string
  description = "(Optional) The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC Default: A 30-minute window selected at random from an 8-hour block of time per region. e.g. 04:00-09:00"
}

variable "preferred_maintenance_window" {
  type        = string
  description = "(Optional) The weekly time range during which system maintenance can occur, in (UTC) e.g. wed:04:00-wed:04:30"
}

variable "scaling_configuration" {
  type        = list(any)
  description = "(Optional) Nested attribute with scaling properties. Only valid when engine_mode is set to serverless. More details below."
  default     = []
}

variable "skip_final_snapshot" {
  type        = string
  description = "(Optional) Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false."
  default     = false
}

variable "snapshot_identifier" {
  type        = string
  description = "(Optional) Specifies whether or not to create this cluster from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  default     = ""
}

variable "storage_encrypted" {
  description = "(Optional) Specifies whether the DB cluster is encrypted. The default is false if not specified."
  default     = true
}

variable "vpc_security_group_ids" {
  type        = list(any)
  description = "(Optional) List of VPC security groups to associate with the Cluster"
  default     = []
}
