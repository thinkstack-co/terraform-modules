resource "aws_lb_target_group" "this" {
  name                   = var.name
  port                   = var.port
  protocol               = var.protocol
  vpc_id                 = var.vpc_id
  target_type            = var.target_type
  health_check_interval  = var.health_check_interval
  health_check_path      = var.health_check_path
  health_check_port      = var.health_check_port
  health_check_protocol  = var.health_check_protocol
  health_check_timeout   = var.health_check_timeout
  health_check_threshold = var.health_check_threshold
  health_check_matcher   = var.health_check_matcher

  stickiness {
    enabled      = var.stickiness_enabled
    type         = var.stickiness_type
    cookie_duration = var.stickiness_cookie_duration
  }

  tags = merge(var.tags, ({"Name" = var.name}))
}
