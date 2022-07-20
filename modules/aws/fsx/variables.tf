###########################
# FSx Instance
###########################

variable "storage_capacity" {
    description = "(Optional) Storage capacity (GiB) of the file system. Minimum of 32 and maximum of 65536. If the storage type is set to HDD the minimum value is 2000. Required when not creating filesystem for a backup."
    default     = "2000"
    type        = string
}

variable "subnet_ids" {
    description = "(Required) A list of IDs for the subnets that the file system will be accessible from. To specify more than a single subnet set deployment_type to MULTI_AZ_1."
}

variable "throughput_capacity" {
    description = "(Required) Throughput (megabytes per second) of the file system in power of 2 increments. Minimum of 8 and maximum of 2048."
    default = "50"
}

variable "backup_id" {
    description = "(Optional) The ID of the source backup to create the filesystem from."
    default = ""
}

variable "active_directory_id" {
    description = "(Optional) The ID for an existing Microsoft Active Directory instance that the file system should join when it's created. Cannot be specified with self_managed_active_directory."
    default = ""
}

variable "aliases" {
    description = "(Optional) An array DNS alias names that you want to associate with the Amazon FSx file system. For more information, see Working with DNS Aliases."
}

variable "automatic_backup_retention_days" {
    description = "(Optional) The number of days to retain automatic backups. Minimum of 0 and maximum of 90. Defaults to 7. Set to 0 to disable."
    default = "7"
}

variable "copy_tags_to_backups" {
    description = "(Optional) A boolean flag indicating whether tags on the file system should be copied to backups. Defaults to true."
    default = true
}

variable "daily_automatic_backup_start_time" {
    description = "(Optional) The preferred time (in HH:MM format) to take daily automatic backups, in the UTC time zone."
    default = "23:59"
}

#replace with an sg module in code
variable "security_group_ids" {
    description = "(Optional) A list of IDs for the security groups that apply to the specified network interfaces created for file system access. These security groups will apply to all network interfaces."
}

variable "skip_final_backup" {
    description = "(Optional) When enabled, will skip the default final backup taken when the file system is deleted. This configuration must be applied separately before attempting to delete the resource to have the desired behavior. Defaults to false."
    default = false
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the object."
  default     = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
  }
}

variable "weekly_maintenance_start_time" {
    description = "(Optional) The preferred start time (in d:HH:MM format) to perform weekly maintenance, in the UTC time zone."
    default    = "1:01:00"
}

variable "deployment_type" {
    description = "(Optional) Specifies the file system deployment type, valid values are MULTI_AZ_1, SINGLE_AZ_1 and SINGLE_AZ_2. Default value is SINGLE_AZ_1."
    default = "SINGLE_AZ_1"
}

variable "preferred_subnet_id" {
    description = "(Optional) Specifies the subnet in which you want the preferred file server to be located. Required for when deployment type is MULTI_AZ_1."
    default = ""
}

variable "storage_type" {
    description = "(Optional) Specifies the storage type, Valid values are SSD and HDD. HDD is supported on SINGLE_AZ_2 and MULTI_AZ_1 Windows file system deployment types. Default value is SSD."
    default = "SSD"
}

###########################
# Self Managed AD Config
###########################

variable "dns_ips" {
    description = "(Required) A list of up to two IP addresses of DNS servers or domain controllers in the self-managed AD directory. The IP addresses need to be either in the same VPC CIDR range as the file system or in the private IP version 4 (IPv4) address ranges as specified in RFC 1918."
    default = ["10.11.1.100", "10.11.2.100"]
}

variable "domain_name" {
    description = "(Required) The fully qualified domain name of the self-managed AD directory. For example, corp.example.com."
}

variable "password" {
    description = "(Required) The password for the service account on your self-managed AD domain that Amazon FSx will use to join to your AD domain."
}

variable "username" {
    description = "(Required) The user name for the service account on your self-managed AD domain that Amazon FSx will use to join to your AD domain."
}

variable "file_system_administrators_group" {
    description = "(Optional) The name of the domain group whose members are granted administrative privileges for the file system. Administrative privileges include taking ownership of files and folders, and setting audit controls (audit ACLs) on files and folders. The group that you specify must already exist in your domain. Defaults to Domain Admins."
    default = "Domain Admins"
}

variable "organizational_unit_distinguished_name" {
    description = "(Optional) The fully qualified distinguished name of the organizational unit within your self-managed AD directory that the Windows File Server instance will join. For example, OU=FSx,DC=yourdomain,DC=corp,DC=com. Only accepts OU as the direct parent of the file system. If none is provided, the FSx file system is created in the default location of your self-managed AD directory. To learn more, see RFC 2253."
}

###########################
# KMS Key
###########################

variable "description" {
    description = "(Optional) The description of the key as viewed in AWS console."
    default     = "CloudWatch kms key used to encrypt flow logs"
    type        = string
}

variable "deletion_window_in_days" {
    description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
    default     = 30
    type        = number
}

variable "enable_key_rotation" {
    description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
    default     = 30
    type        = number 
}

variable "key_usage" {
  description = "(Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
  default     = "ENCRYPT_DECRYPT"
  type        = string
}

variable "is_enabled" {
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true
  type        = string
}

variable "policy" {
    description = "(Optional) A valid policy JSON document. Although this is a key policy, not an IAM policy, an aws_iam_policy_document, in the form that designates a principal, can be used. For more information about building policy documents with Terraform, see the AWS IAM Policy Document Guide."
    default = ""
}

###########################
# Audit Log Config
###########################

#Global
variable "enable_audit_logs" {
    description = "Determines count for cloudwatch log group, IAM policy, and IAM role. Defaults to true and enters a count of 1 to create resources."
    default = true
}

#FSx Configuration block variables.
# variable "audit_log_destination" {
#     description = "(Optional) The Amazon Resource Name (ARN) for the destination of the audit logs. The destination can be any Amazon CloudWatch Logs log group ARN or Amazon Kinesis Data Firehose delivery stream ARN. Can be specified when file_access_audit_log_level and file_share_access_audit_log_level are not set to DISABLED. The name of the Amazon CloudWatch Logs log group must begin with the /aws/fsx prefix. The name of the Amazon Kinesis Data Firehouse delivery stream must begin with the aws-fsx prefix. If you do not provide a destination in audit_log_destionation, Amazon FSx will create and use a log stream in the CloudWatch Logs /aws/fsx/windows log group."  
# }

variable "file_access_audit_log_level" {
    description = "(Optional) Sets which attempt type is logged by Amazon FSx for file and folder accesses. Valid values are SUCCESS_ONLY, FAILURE_ONLY, SUCCESS_AND_FAILURE, and DISABLED. Default value is DISABLED."
    default = "SUCCESS_AND_FAILURE"
}

variable "file_share_access_audit_log_level" {
    description = "(Optional) Sets which attempt type is logged by Amazon FSx for file share accesses. Valid values are SUCCESS_ONLY, FAILURE_ONLY, SUCCESS_AND_FAILURE, and DISABLED. Default value is DISABLED." 
    default = "SUCCESS_AND_FAILURE"
}

#Cloudwatch Log Group

variable "cloudwatch_name_prefix" {
    description = ""
    default     = "fsx_access_logs_"
    type        = string  
}

variable "cloudwatch_retention_in_days" {
    description = "(Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
    default     = 90
    type        = number
}


#IAM
variable "iam_policy_description" {
    description = "(Optional), Forces new resource Description of the IAM policy."
    default = "IAM policy for FSx logs role."
}

variable "iam_policy_name_prefix" {
    description = "(Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name."
    default = "fsx_log_policy_"
}

variable "iam_policy_path" {
    description = "(Optional, default '/') Path in which to create the policy. See IAM Identifiers for more information."
    default = "/"
}
