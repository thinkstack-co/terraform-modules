resource "aws_lb" "this" {
  count                            = var.number
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  idle_timeout                     = var.idle_timeout
  internal                         = var.internal
  ip_address_type                  = var.ip_address_type
  load_balancer_type               = var.load_balancer_type
  name                             = var.name
  security_groups                  = var.security_groups
  subnets                          = var.subnets

  access_logs {
    bucket  = var.access_logs_bucket
    enabled = var.access_logs_enabled
    prefix  = var.access_logs_prefix
  }

  tags = merge(var.tags, ({"Name" = format("%s%d", var.name, count.index + 1)}))
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.port
  protocol          = var.protocol
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  default_action {
    type             = var.default_action_type
    target_group_arn = var.default_action_target_group_arn
    redirect {
      # for blank do this
      # blank == 0 or false
    }
    fixed_response {
      # for blank do this
      # blank == 0 or false
    }
  }
}
