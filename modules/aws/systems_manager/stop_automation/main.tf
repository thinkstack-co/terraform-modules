terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

# Maintenance Window Resource
resource "aws_ssm_maintenance_window" "maintenance_window" {
  name                       = var.mw_name
  schedule                   = var.mw_schedule
  cutoff                     = var.mw_cutoff
  duration                   = var.mw_duration
  description                = var.mw_description
  allow_unassociated_targets = var.mw_allow_unassociated_targets
  enabled                    = var.mw_enabled
  end_date                   = var.mw_end_date
  schedule_timezone          = var.mw_schedule_timezone
  schedule_offset            = var.mw_schedule_offset
  start_date                 = var.mw_start_date
  tags                       = var.mw_tags
}

# Maintenance Window Target Resource
resource "aws_ssm_maintenance_window_target" "target" {
  window_id     = aws_ssm_maintenance_window.maintenance_window.id # Linking the target to the maintenance window created above
  name          = var.target_name
  description   = var.target_description
  resource_type = var.target_resource_type

  # Dynamic block to iterate over the provided targets
  dynamic "targets" {
    for_each = var.target_details
    content {
      key    = targets.value.key
      values = targets.value.values
    }
  }

  owner_information = var.target_owner_information
}

# Maintenance Window Task Resource for starting EC2 instances
resource "aws_ssm_maintenance_window_task" "stop_ec2_instance" {
  count = length(var.stop_order)

  window_id     = aws_ssm_maintenance_window.maintenance_window.id # Linking the target to the maintenance window created above
  max_concurrency = var.max_concurrency
  max_errors      = var.max_errors
  priority        = count.index
  task_arn        = "AWS-StopEC2Instance"
  task_type       = "AUTOMATION"
  service_role_arn = var.iam_role_arn

  targets {
    key    = "InstanceIds"
    values = [var.stop_order[count.index]]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"

      parameter {
        name   = "InstanceId"
        values = [var.start_order[count.index]]
      }
    }
  }
}

