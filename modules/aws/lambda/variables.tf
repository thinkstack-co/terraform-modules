variable "description" {
  type        = string
  description = "(Optional) Description of what your Lambda Function does."
}

variable "filename" {
  type        = string
  description = "(Optional) The path to the function's deployment package within the local filesystem. If defined, The s3_-prefixed options cannot be used."
}

variable "source_code_hash" {
  type        = string
  description = "(Optional) Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either filename or s3_key"
}

variable "function_name" {
  type        = string
  description = "(Required) A unique name for your Lambda Function."
}

variable "role" {
  type        = string
  description = "(Required) IAM role attached to the Lambda Function. This governs both who or what can invoke your Lambda Function, as well as what resources our Lambda Function has access to. See Lambda Permission Model for more details."
}

variable "handler" {
  type        = string
  description = "(Required) The function entrypoint in your code."
  default     = "main.handler"
}

variable "memory_size" {
  type        = number
  description = "(Optional) Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128. See Limits"
  default     = 128
}

variable "runtime" {
  type        = string
  description = "(Required) See Runtimes for valid values."
  default     = "python3.6"
}

variable "timeout" {
  type        = number
  description = "(Optional) The amount of time your Lambda Function has to run in seconds. Defaults to 3. See Limits"
  default     = 180
}

variable "variables" {
  type        = map(string)
  description = "(Optional) A map that defines environment variables for the Lambda function."
  default = {
    lambda = "true"
  }
}


