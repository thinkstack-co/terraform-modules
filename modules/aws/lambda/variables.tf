variable "description" {
    description = "Description of the lambda function"
}

variable "filename" {
    description = "Filename to upload to lambda"
}

variable "source_code_hash" {
    description = "Hash of the source code file"
}

variable "function_name" {
    description = "Name of your lambda function"
}

variable "role" {
    description = "Role the lambda function will use"
}

variable "handler" {
    description = "Entrypoint to the lambda function"
    default     = "main.handler"
}

variable "memory_size" {
    type = "string"
    description = "amount of memory to allocate to the function in 64MB increments"
    default = 128
}

variable "runtime" {
    description = "Lambda runtime"
    default     = "python3.6"
}

variable "timeout" {
    description = "Timeout of the lambda function in seconds"
    default     = 180
}

/*variable "statement_id" {
    description = "A unique statement identifier"
}

variable "action" {
    description = "The AWS lambda action you want to allow"
    default     = "lambda:InvokeFunction"
}

variable "principal" {
    description = "The principal which is receiving this permission"
    default     = "events.amazonaws.com"
}

variable "source_arn" {
    description = "arn of the resource to allow permission to run the lambda function"
}
*/
