terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_elastic_beanstalk_environment" "this" {
  application            = var.application
  cname_prefix           = var.cname_prefix
  description            = var.description
  name                   = var.name
  platform_arn           = var.platform_arn
  poll_interval          = var.poll_interval
  solution_stack_name    = var.solution_stack_name
  tags                   = var.tags
  template_name          = var.template_name
  tier                   = var.tier
  version_label          = var.version_label
  wait_for_ready_timeout = var.wait_for_ready_timeout

  dynamic "setting" {
    for_each = var.setting
    content {
      namespace = lookup(setting.value, "namespace")
      name      = lookup(setting.value, "name")
      value     = lookup(setting.value, "value")
      resource  = lookup(setting.value, "resource", null)
    }
  }
}
