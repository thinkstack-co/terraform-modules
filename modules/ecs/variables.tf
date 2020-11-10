variable "create_ecs" {
    type        = bool
    description = "Controls the creation of your ECS cluster"
    default     = true
}

variable "name" {
    type = string
    description = "Name used on your ECS cluster"
}

variable "tags" {
    type = map(string)
    description = "map of tags for your ECS cluster"
}

variable "container_insights" {
    type        = bool
    description = "controls if cloudwatch contrainer insights is enabled on the cluster"
    default     = false
}