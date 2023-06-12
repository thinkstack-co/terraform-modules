terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.port
  protocol          = var.protocol
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.ssl_certificate

  default_action {
    type = "forward"

    forward {
      dynamic "target_group" {
        for_each = var.target_groups
        content {
          arn    = target_group.value["arn"]
          weight = target_group.value["weight"]
        }
      }

      stickiness {
        enabled  = var.stickiness_enabled
        duration = var.stickiness_duration
      }
    }
  }

  tags = var.tags
}

