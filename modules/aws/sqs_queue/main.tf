terraform {
  required_version = ">= 0.12.0"
}

resource "aws_sqs_queue" "queue" {
  delay_seconds              = var.delay_seconds
  fifo_queue                 = var.fifo_queue
  message_retention_seconds  = var.message_retention_seconds
  name                       = var.name
  tags                       = var.tags
  visibility_timeout_seconds = var.visibility_timeout_seconds
}
