terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  actions_enabled           = var.actions_enabled
  alarm_actions             = var.alarm_actions
  alarm_description         = var.alarm_description
  alarm_name                = var.alarm_name
  comparison_operator       = var.comparison_operator
  datapoints_to_alarm       = var.datapoints_to_alarm
  dimensions                = var.dimensions
  evaluation_periods        = var.evaluation_periods
  insufficient_data_actions = var.insufficient_data_actions
  metric_name               = var.metric_name
  namespace                 = var.namespace
  ok_actions                = var.ok_actions
  period                    = var.period
  statistic                 = var.statistic
  threshold                 = var.threshold
  treat_missing_data        = var.treat_missing_data
  unit                      = var.unit
}
