terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.target_group_name
  target_type = "alb"
  port        = var.port
  protocol    = var.protocol
  vpc_id      = var.vpc_id

  health_check {
    protocol            = var.health_check_protocol
    port                = var.health_check_port
    path                = var.health_check_path
    timeout             = var.health_check_timeout_seconds
    interval            = var.health_check_interval_seconds
    healthy_threshold   = var.healthy_threshold_count
    unhealthy_threshold = var.unhealthy_threshold_count
    matcher             = var.matcher
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = var.target_group_arn
  target_id        = var.aws_instances
  port             = var.port
}