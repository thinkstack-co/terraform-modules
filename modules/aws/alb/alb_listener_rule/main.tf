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
  tags         = var.tags

  action {
    type             = var.type
    target_group_arn = var.target_group_arn
  }

  dynamic "condition" {
    for_each = var.conditions
    content {
      %{ if condition.value.host_header != null }
      host_header {
        values = condition.value.host_header
      }
      %{ endif }
      %{ if condition.value.path_pattern != null }
      path_pattern {
        values = condition.value.path_pattern
      }
      %{ endif }
      %{ if condition.value.http_header != null }
      http_header {
        http_header_name = condition.value.http_header.http_header_name
        values           = condition.value.http_header.values
      }
      %{ endif }
      %{ if condition.value.http_request_method != null }
      http_request_method {
        values = condition.value.http_request_method
      }
      %{ endif }
      %{ if condition.value.query_string != null }
      query_string {
        dynamic "query_string" {
          for_each = condition.value.query_string
          content {
            %{ if query_string.value.key != null }
            key   = query_string.value.key
            %{ endif }
            value = query_string.value.value
          }
        }
      }
      %{ endif }
      %{ if condition.value.source_ip != null }
      source_ip {
        values = condition.value.source_ip
      }
      %{ endif }
    }
  }
}
