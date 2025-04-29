variable "statement_id" {
  type        = string
  description = "A unique statement identifier"
}

variable "action" {
  type        = string
  description = "The AWS lambda action you want to allow"
  default     = "lambda:InvokeFunction"
}

variable "function_name" {
  type        = string
  description = "Name of the lambda function"
}

variable "principal" {
  type        = string
  description = "The principal which is receiving this permission"
  default     = "events.amazonaws.com"
}

variable "source_arn" {
  description = "arn of the resource to allow permission to run the lambda function"
  type        = string
}
