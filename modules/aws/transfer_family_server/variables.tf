###########################
# IAM Policy Variables
###########################

variable "iam_policy_description" {
    type        = string
    description = "(Optional, Forces new resource) Description of the IAM policy."
    default     = "Used with transfer family to send logs to a CloudWatch log group"
}

variable "iam_policy_name_prefix" {
    type        = string
    description = "(Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name."
    default     = "transfer_family_logging_policy_"
}

variable "iam_policy_path" {
    type = string
    description = "(Optional, default '/') Path in which to create the policy. See IAM Identifiers for more information."
    default = "/"
}

###########################
# IAM Role Variables
###########################

variable "iam_role_description" {
  type        = string
  description = "(Optional) The description of the role."
  default     = "Role utilized for EC2 instances ENI flow logs. This role allows creation of log streams and adding logs to the log streams in cloudwatch"
}

variable "iam_role_force_detach_policies" {
  type        = bool
  description = "(Optional) Specifies to force detaching any policies the role has before destroying it. Defaults to false."
  default     = false
}

variable "iam_role_max_session_duration" {
  type        = number
  description = "(Optional) The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
  default     = 3600
}

variable "iam_role_name_prefix" {
  type        = string
  description = "(Required, Forces new resource) Creates a unique friendly name beginning with the specified prefix. Conflicts with name."
  default     = "transfer_family_logging_role_"
}

variable "iam_role_permissions_boundary" {
  type        = string
  description = "(Optional) The ARN of the policy that is used to set the permissions boundary for the role."
  default     = ""
}

##################################
# Transfer Family Server Variables
##################################

variable "certificate" {
    type        = string
    description = "(Optional) The Amazon Resource Name (ARN) of the AWS Certificate Manager (ACM) certificate. This is required when protocols is set to FTPS"
    default     = null
}

variable "domain" {
    type        = string
    description = "(Optional) The domain of the storage system that is used for file transfers. Valid values are: S3 and EFS. The default value is S3."
    default     = "S3"
}

variable "protocols" {
    type        = list(string)
    description = "(Optional) Specifies the file transfer protocol or protocols over which your file transfer protocol client can connect to your server's endpoint. This defaults to SFTP . The available protocols are: SFTP: File transfer over SSH, FTPS: File transfer with TLS encryption, FTP: Unencrypted file transfer"
    default     = ["SFTP"]
}

variable "endpoint_type" {
    type        = string
    description = "(Optional) The type of endpoint that you want your SFTP server connect to. If you connect to a VPC (or VPC_ENDPOINT), your SFTP server isn't accessible over the public internet. If you want to connect your SFTP server via public internet, set PUBLIC. Defaults to PUBLIC."
    default     = "PUBLIC"
}

variable "invocation_role" {
    type        = string
    description = "(Optional) Amazon Resource Name (ARN) of the IAM role used to authenticate the user account with an identity_provider_type of API_GATEWAY."
    default     = null
}

variable "host_key" {
    type        = string
    description = "(Optional) RSA private key (e.g., as generated by the ssh-keygen -N '' -m PEM -f my-new-server-key command)."
    default     = null
}

variable "url" {
    type        = string
    description = "(Optional) - URL of the service endpoint used to authenticate users with an identity_provider_type of API_GATEWAY."
    default     = null
}

variable "identity_provider_type" {
    type        = string
    description = "(Optional) The mode of authentication enabled for this service. The default value is SERVICE_MANAGED, which allows you to store and access SFTP user credentials within the service. API_GATEWAY indicates that user authentication requires a call to an API Gateway endpoint URL provided by you to integrate an identity provider of your choice. Using AWS_DIRECTORY_SERVICE will allow for authentication against AWS Managed Active Directory or Microsoft Active Directory in your on-premises environment, or in AWS using AD Connectors. Use the AWS_LAMBDA value to directly use a Lambda function as your identity provider. If you choose this value, you must specify the ARN for the lambda function in the function argument."
    default     = "SERVICE_MANAGED"
}

variable "directory_id" {
    type = string
    description = "(Optional) The directory service ID of the directory service you want to connect to with an identity_provider_type of AWS_DIRECTORY_SERVICE."
    default     = null
}

variable "function" {
    type = string
    description = "(Optional) The ARN for a lambda function to use for the Identity provider."
    default = null
}

variable "force_destroy" {
    type = bool
    description = "(Optional) A boolean that indicates all users associated with the server should be deleted so that the Server can be destroyed without error. The default value is false. This option only applies to servers configured with a SERVICE_MANAGED identity_provider_type."
    default = false
}

variable "post_authentication_login_banner" {
    type = string
    description = "(Optional) Specify a string to display when users connect to a server. This string is displayed after the user authenticates. The SFTP protocol does not support post-authentication display banners."
    default = null
}

variable "pre_authentication_login_banner" {
    type = string
    description = "(Optional) Specify a string to display when users connect to a server. This string is displayed before the user authenticates."
    default = null
}

variable "security_policy_name" {
    type = string
    description = "(Optional) Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, TransferSecurityPolicy-FIPS-2020-06 and TransferSecurityPolicy-2022-03. Default value is: TransferSecurityPolicy-2022-03."
    default = "TransferSecurityPolicy-2022-03"
}

variable "address_allocation_ids" {
    type = list(string)
    description = "(Optional) A list of address allocation IDs that are required to attach an Elastic IP address to your SFTP server's endpoint. This property can only be used when endpoint_type is set to VPC."
    default = null
}

variable "security_group_ids" {
    type = list(string)
    description = "(Optional) A list of security groups IDs that are available to attach to your server's endpoint. If no security groups are specified, the VPC's default security groups are automatically assigned to your endpoint. This property can only be used when endpoint_type is set to VPC."
    default = null
}

variable "subnet_ids" {
    type = list(string)
    description = "(Optional) A list of subnet IDs that are required to host your SFTP server endpoint in your VPC. This property can only be used when endpoint_type is set to VPC."
    default = null
}

variable "vpc_endpoint_id" {
    type = string
    description = "(Optional) The ID of the VPC endpoint. This property can only be used when endpoint_type is set to VPC_ENDPOINT"
    default = null
}

variable "vpc_id" {
    type = string
    description = "(Optional) The VPC ID of the virtual private cloud in which the SFTP server's endpoint will be hosted. This property can only be used when endpoint_type is set to VPC."
}

##################################
# General Variables
##################################

variable "tags" {
    type = map
    description = "(Required) A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
}
