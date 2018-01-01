variable "fifo_queue" {
  description = "(Optional) Boolean designating a FIFO queue. If not set, it defaults to false making it standard."
  default     = false
}

variable "name" {
  type        = "string"
  description = "(Optional) This is the human-readable name of the queue. If omitted, Terraform will assign a random name."
}
