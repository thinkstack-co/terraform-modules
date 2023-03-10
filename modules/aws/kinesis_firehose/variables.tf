#################################
# Kinesis Firehose
#################################
variable "firehose_name" {
  description = "(Required) A name to identify the stream. This is unique to the AWS account and region the Stream is created in."
  type        = string
}

variable "firehose_destination" {
  description = "(Optional) This is the destination to where the data is delivered. The only options are s3 (Deprecated, use extended_s3 instead), extended_s3, redshift, elasticsearch, splunk, and http_endpoint."
  type        = string
  default     = "extended_s3"
}

variable "firehose_server_side_encryption_enabled" {
  description = "(Optional) Encrypt at rest options. Server-side encryption should not be enabled when a kinesis stream is configured as the source of the firehose delivery stream."
  type        = bool
  default     = true
}

variable "firehose_key_type" {
  description = "(Optional) Type of encryption key. Default is AWS_OWNED_CMK. Valid values are AWS_OWNED_CMK and CUSTOMER_MANAGED_CMK"
  type        = string
  default     = "AWS_OWNED_CMK"
}

variable "firehose_key_arn" {
  description = "(Optional) Amazon Resource Name (ARN) of the encryption key. Required when key_type is CUSTOMER_MANAGED_CMK."
  type        = string
  default     = ""
}

variable "firehose_prefix" {
  description = "(Optional) The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket"
  type        = string
  default     = ""
}

variable "firehose_buffer_size" {
  description = "(Optional) Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher."
  type        = number
  default     = 5
}

variable "firehose_buffer_interval" {
  description = "(Optional) Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. The default value is 300."
  type        = number
  default     = 300
}

variable "firehose_compression_format" {
  description = "(Optional) The compression format. If no value is specified, the default is UNCOMPRESSED. Other supported values are GZIP, ZIP, Snappy, & HADOOP_SNAPPY."
  type        = string
  default     = "UNCOMPRESSED"
}

variable "firehose_error_output_prefix" {
  description = "(Optional) Prefix added to failed records before writing them to S3. Not currently supported for redshift destination. This prefix appears immediately following the bucket name. For information about how to specify this prefix, see Custom Prefixes for Amazon S3 Objects."
  type        = string
  default     = ""
}

variable "firehose_kms_key_arn" {
  description = "(Optional) Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used."
  type        = string
  default     = ""
}

#################################
# S3
#################################

variable "s3_acl" {
  description = "(Optional) The canned ACL to apply. Defaults to private."
  type        = string
  default     = "private"
}

variable "s3_bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  type        = string
  default     = "kinesis-firehose-"
}

variable "s3_policy" {
  type        = string
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
  default     = ""
}

variable "s3_lifecycle_id" {
  description = "(Optional) Unique identifier for the rule. Must be less than or equal to 255 characters in length."
  type        = string
  default     = "delete_after_7_days"
}

variable "s3_lifecycle_prefix" {
  description = "(Optional) Object key prefix identifying one or more objects to which the rule applies."
  type        = string
  default     = ""
}

variable "s3_lifecycle_enabled" {
  description = "(Required) Specifies lifecycle rule status."
  type        = bool
  default     = true
}

variable "s3_lifecycle_expiration_days" {
  description = "(Optional) Specifies the number of days after object creation when the specific rule action takes effect."
  type        = number
  default     = 7
}

###########################
# IAM Policy
###########################

variable "iam_policy_description" {
  description = "(Optional, Forces new resource) Description of the IAM policy."
  type        = string
  default     = "Used with kinesis firehose send data to a dedicated S3 bucket"
}

variable "iam_policy_name_prefix" {
  description = "(Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name."
  type        = string
  default     = "kinesis_firehose_policy_"
}

variable "iam_policy_path" {
  description = "(Optional, default '/') Path in which to create the policy. See IAM Identifiers for more information."
  type        = string
  default     = "/"
}

###########################
# IAM Role
###########################

variable "iam_role_assume_role_policy" {
  type        = string
  description = "(Required) The policy that grants an entity permission to assume the role."
  default     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

variable "iam_role_description" {
  description = "(Optional) The description of the role."
  type        = string
  default     = "Role utilized for Kinesis Firehose to read and write to it's own dedicated S3 bucket"
}

variable "iam_role_force_detach_policies" {
  description = "(Optional) Specifies to force detaching any policies the role has before destroying it. Defaults to false."
  type        = bool
  default     = false
}

variable "iam_role_max_session_duration" {
  description = "(Optional) The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
  type        = number
  default     = 3600
}

variable "iam_role_name_prefix" {
  description = "(Required, Forces new resource) Creates a unique friendly name beginning with the specified prefix. Conflicts with name."
  type        = string
  default     = "kinesis_firehose_role_"
}

variable "iam_role_permissions_boundary" {
  description = "(Optional) The ARN of the policy that is used to set the permissions boundary for the role."
  type        = string
  default     = ""
}


###############################################################
# General Use Variables
###############################################################

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the object."
  type        = map(any)
  default = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
    priority    = "low"
  }
}
