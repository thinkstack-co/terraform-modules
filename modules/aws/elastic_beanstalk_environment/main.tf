terraform {
  required_version = ">= 0.12.0"
}

resource "aws_elastic_beanstalk_environment" "this" {
  application            = var.application
  cname_prefix           = var.cname_prefix
  description            = var.description
  name                   = var.name
  platform_arn           = var.platform_arn
  poll_interval          = var.poll_interval
  setting                = var.setting
  solution_stack_name    = var.solution_stack_name
  tags                   = var.tags
  template_name          = var.template_name
  tier                   = var.tier
  version_label          = var.version_label
  wait_for_ready_timeout = var.wait_for_ready_timeout
}
