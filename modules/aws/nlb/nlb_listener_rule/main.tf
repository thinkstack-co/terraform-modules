terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = var.type
    target_group_arn = var.target_group_arn
  }

  dynamic "condition" {
    for_each = var.condition_field == "path-pattern" ? [1] : []
    content {
      path_pattern {
        values = var.condition_values
      }
    }
  }

  dynamic "condition" {
    for_each = var.condition_field == "host-header" ? [1] : []
    content {
      host_header {
        values = var.condition_values
      }
    }
  }
}