variable "environment_name" {
    type = string
    description = "used as prefix for created objects, should be unique in account"
}

variable "route_table_arn" {
    type = string
    description = "AWS route table ARN that the AWS nodes need to be able to modify"
}