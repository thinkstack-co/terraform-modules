variable "application" {
  type        = string
  description = "(Required) Name of the application that contains the version to be deployed"
}

variable "cname_prefix" {
  type        = string
  description = "(Optional) Prefix to use for the fully qualified DNS name of the Environment"
  default     = ""
}

variable "description" {
  type        = string
  description = "(Optional) Short description of the Environment"
  default     = ""
}

variable "name" {
  type        = string
  description = "(Required) A unique name for this Environment. This name is used in the application URL"
}

variable "platform_arn" {
  type        = string
  description = "(Optional) The ARN of the Elastic Beanstalk Platform to use in deployment"
  default     = ""
}

variable "poll_interval" {
  type        = string
  description = "The time between polling the AWS API to check if changes have been applied. Use this to adjust the rate of API calls for any create or update action. Minimum 10s, maximum 180s. Omit this to use the default behavior, which is an exponential backoff"
  default     = ""
}

variable "setting" {
  type        = string
  description = "(Optional) Option settings to configure the new Environment. These override specific values that are set as defaults. The format is detailed below in Option Settings"
  default     = ""
}

variable "solution_stack_name" {
  type        = string
  description = "(Optional) A solution stack to base your environment off of. Example stacks can be found in the Amazon API documentation"
  default     = ""
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A set of tags to apply to the Environment."
  default     = {}
}

variable "template_name" {
  type        = string
  description = "(Optional) The name of the Elastic Beanstalk Configuration template to use in deployment"
  default     = ""
}

variable "tier" {
  type        = string
  description = "(Optional) Elastic Beanstalk Environment tier. Valid values are Worker or WebServer. If tier is left blank WebServer will be used."
  default     = ""
}

variable "version_label" {
  type        = string
  description = "(Optional) The name of the Elastic Beanstalk Application Version to use in deployment."
  default     = ""
}

variable "wait_for_ready_timeout" {
  type        = string
  description = "(Default: 20m) The maximum duration that Terraform should wait for an Elastic Beanstalk Environment to be in a ready state before timing out."
  default     = 20
}
