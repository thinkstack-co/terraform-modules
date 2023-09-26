# Maintenance Window for Stopping EC2 Instances
# This resource sets up the maintenance window for stopping instances. 
# It uses the schedule defined in the variable 'mw_schedule_stop'.
resource "aws_ssm_maintenance_window" "maintenance_window_stop" {
  name                       = var.mw_name
  schedule                   = var.mw_schedule_stop
  cutoff                     = var.mw_cutoff
  duration                   = var.mw_duration
  description                = var.mw_description_stop
  allow_unassociated_targets = var.mw_allow_unassociated_targets_stop
  enabled                    = var.mw_enabled_stop
  end_date                   = var.mw_end_date_stop
  schedule_timezone          = var.mw_schedule_timezone
  schedule_offset            = var.mw_schedule_offset_stop
  start_date                 = var.mw_start_date_stop
  tags                       = var.mw_tags
}
# Maintenance Window Target for Stopping EC2 Instances
# This resource registers targets (EC2 instances) to be managed within the stopping maintenance window.
resource "aws_ssm_maintenance_window_target" "target_stop" {
  window_id     = aws_ssm_maintenance_window.maintenance_window_stop.id
  name          = var.target_name_stop
  resource_type = var.target_resource_type
  targets       = var.target_details
}

# Maintenance Window Task for Stopping EC2 Instances
# This resource sets up the task to stop EC2 instances during the maintenance window.
# It loops through the list of instances specified in 'stop_order' and assigns a priority to each task based on the order.
resource "aws_ssm_maintenance_window_task" "stop_ec2_instance" {
  count = length(var.stop_order)

  window_id        = aws_ssm_maintenance_window.maintenance_window_stop.id
  max_concurrency  = var.stop_max_concurrency
  max_errors       = var.stop_max_errors
  priority         = count.index
  task_arn         = "AWS-StopEC2Instance"
  task_type        = "AUTOMATION"
  service_role_arn = aws_iam_role.ssm_role.arn

  targets {
    key    = "InstanceIds"
    values = [var.stop_order[count.index]]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"
      parameter {
        name   = "InstanceId"
        values = [var.stop_order[count.index]]
      }
    }
  }
}

# Maintenance Window for Starting EC2 Instances
# This resource sets up the maintenance window for starting instances.
# It depends on the completion of the 'stop_ec2_instance' task, ensuring that instances are stopped before they are started.
resource "aws_ssm_maintenance_window" "maintenance_window_start" {
  name                       = var.mw_name
  schedule                   = var.mw_schedule_start
  cutoff                     = var.mw_cutoff
  duration                   = var.mw_duration
  description                = var.mw_description_start
  allow_unassociated_targets = var.mw_allow_unassociated_targets_start
  enabled                    = var.mw_enabled_start
  end_date                   = var.mw_end_date_start
  schedule_timezone          = var.mw_schedule_timezone
  schedule_offset            = var.mw_schedule_offset_start
  start_date                 = var.mw_start_date_start
  tags                       = var.mw_tags
  depends_on                 = [aws_ssm_maintenance_window_task.stop_ec2_instance]
}

# Maintenance Window Target for Starting EC2 Instances
# This resource registers targets (EC2 instances) to be managed within the starting maintenance window.
resource "aws_ssm_maintenance_window_target" "target_start" {
  window_id     = aws_ssm_maintenance_window.maintenance_window_start.id
  name          = var.target_name_start
  resource_type = var.target_resource_type
  targets       = var.target_details
}

# Maintenance Window Task for Starting EC2 Instances
# This resource sets up the task to start EC2 instances during the maintenance window.
# It loops through the list of instances specified in 'start_order' and assigns a priority to each task based on the order.
resource "aws_ssm_maintenance_window_task" "start_ec2_instance" {
  count = length(var.start_order)

  window_id        = aws_ssm_maintenance_window.maintenance_window_start.id
  max_concurrency  = var.start_max_concurrency
  max_errors       = var.start_max_errors
  priority         = count.index
  task_arn         = "AWS-StartEC2Instance"
  task_type        = "AUTOMATION"
  service_role_arn = aws_iam_role.ssm_role.arn

  targets {
    key    = "InstanceIds"
    values = [var.start_order[count.index]]
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

############################
# IAM ROLE AND PERMISSIONS
############################

resource "aws_iam_role" "ssm_role" {
  name = "SSMMaintenanceWindowRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ssm.amazonaws.com"
        },
        Effect = "Allow",
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_ec2_permissions" {
  name = "SSMEC2Permissions"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
        ],
        Effect   = "Allow",
        Resource = "*",
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ssm_role.name
}

