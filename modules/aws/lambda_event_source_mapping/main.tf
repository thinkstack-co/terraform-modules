terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_lambda_event_source_mapping" "this" {
  batch_size       = var.batch_size
  enabled          = var.enabled
  event_source_arn = var.event_source_arn
  function_name    = var.function_name
  # starting_position           = var.starting_position
  # starting_position_timestamp = var.starting_position_timestamp
}
