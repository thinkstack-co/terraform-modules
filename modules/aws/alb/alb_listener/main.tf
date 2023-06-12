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
  load_balancer_arn = var.alb_arn
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
        type    = "lb_cookie"
        enabled = var.stickiness_enabled
        duration = var.stickiness_duration
      }
    }
  }

  tags = merge(var.tags, ({ "Name" = format("%s%d", var.name, count.index + 1) }))
}

