variable "apply_immediately" {
  type        = string
  description = "(Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default isfalse."
  default     = false
}

variable "auto_minor_version_upgrade" {
  type        = string
  description = "(Optional) Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default true."
  default     = true
}

variable "availability_zone" {
  type        = string
  description = "(Optional, Computed) The EC2 Availability Zone that the DB instance is created in. See docs about the details."
  default     = ""
}

variable "number" {
  type        = string
  description = "The number of resources to create"
}

variable "cluster_identifier" {
  type        = string
  description = "(Required) The identifier of the aws_rds_cluster in which to launch this instance."
}

variable "db_subnet_group_name" {
  type        = string
  description = "(Required if publicly_accessible = false, Optional otherwise) A DB subnet group to associate with this DB instance. NOTE: This must match the db_subnet_group_name of the attached aws_rds_cluster."
}

variable "db_parameter_group_name" {
  type        = string
  description = "(Optional) The name of the DB parameter group to associate with this instance."
}

variable "engine" {
  type        = string
  description = "(Optional) The name of the database engine to be used for the RDS instance. Defaults to aurora. Valid Values: aurora, aurora-mysql, aurora-postgresql. For information on the difference between the available Aurora MySQL engines see Comparison between Aurora MySQL 1 and Aurora MySQL 2 in the Amazon RDS User Guide."
  default     = ""
}

variable "engine_version" {
  type        = string
  description = "(Optional) The database engine version."
  default     = ""
}

variable "identifier" {
  type        = string
  description = "(Optional, Forces new resource) The indentifier for the RDS instance, if omitted, Terraform will assign a random, unique identifier."
  default     = ""
}

variable "instance_class" {
  type        = string
  description = "(Required) The instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora currently supports the below instance classes. Please see AWS Documentation for complete details. db.t2.small db.t2.medium db.r3.large db.r3.xlarge db.r3.2xlarge db.r3.4xlarge db.r3.8xlarge db.r4.large db.r4.xlarge db.r4.2xlarge db.r4.4xlarge db.r4.8xlarge db.r4.16xlarge"
}

variable "monitoring_interval" {
  type        = string
  description = "(Optional) The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  default     = 0
}

variable "monitoring_role_arn" {
  type        = string
  description = "(Optional) The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. You can find more information on the AWS Documentation what IAM permissions are needed to allow Enhanced Monitoring for RDS Instances."
  default     = ""
}

variable "performance_insights_enabled" {
  type        = string
  description = "(Optional) Specifies whether Performance Insights is enabled or not."
  default     = true
}

variable "performance_insights_kms_key_id" {
  type        = string
  description = "(Optional) The ARN for the KMS key to encrypt Performance Insights data. When specifying performance_insights_kms_key_id, performance_insights_enabled needs to be set to true."
  default     = ""
}

variable "promotion_tier" {
  type        = string
  description = "(Optional) Default 0. Failover Priority setting on instance level. The reader who has lower tier has higher priority to get promoter to writer."
  default     = 0
}

variable "publicly_accessible" {
  type        = string
  description = "(Optional) Bool to control if instance is publicly accessible. Default false. See the documentation on Creating DB Instances for more details on controlling this property."
  default     = false
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the instance."
  default     = {}
}
