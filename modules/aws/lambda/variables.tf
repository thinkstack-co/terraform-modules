variable "lambda_description" {
    description = "Description of the lambda function"
}

variable "lambda_filename" {
    description = "Filename to upload to lambda"
}

variable "source_code_hash" {
    description = "Hash of the source code file"
}

variable "lambda_function_name" {
    description = "Name of your lambda function"
}

variable "lambda_role" {
    description = "Role the lambda function will use"
}

variable "lambda_handler" {
    description = "Entrypoint to the lambda function"
    default     = "main.handler"
}

variable "lambda_runtime" {
    description = "Lambda runtime"
    default     = "python3.6"
}

variable "lambda_timeout" {
    description = "Timeout of the lambda function in seconds"
    default     = 180
}

variable "statement_id" {
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
