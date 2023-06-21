terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.port
  protocol          = var.protocol


  default_action {
    type              = var.action_type
    target_group_arn  = var.target_group_arn

    forward {
      dynamic "target_group" {
        for_each = var.target_groups
        content {
          arn    = target_group.value["arn"]
          weight = target_group.value["weight"]
        }
      }
    }
  }

  tags = var.tags
}

