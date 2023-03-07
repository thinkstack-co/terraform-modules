terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = var.name
  description         = var.description
  schedule_expression = var.schedule_expression
  is_enabled          = var.is_enabled
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule = aws_cloudwatch_event_rule.event_rule.name
  arn  = var.event_target_arn
}
