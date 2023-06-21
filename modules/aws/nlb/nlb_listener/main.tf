terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

# AWS Load Balancer Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.port
  protocol          = var.protocol

  # The dynamic block here is used to conditionally create a default_action block for a single target group
  # If target_group_arn is provided (not null), the for_each loop runs once to create one default_action block
  # If target_group_arn is not provided (null), the for_each loop does not run, so no default_action block is created
  dynamic "default_action" {
    for_each = var.target_group_arn != null ? [1] : []
    content {
      # The type of action
      type = var.action_type

      # The ARN of the target group
      target_group_arn = var.target_group_arn
    }
  }

  # The dynamic block here is used to conditionally create a default_action block for multiple target groups
  # If target_group_arn is not provided (null) and target_groups has at least one element, the for_each loop runs once to create one default_action block
  # If target_group_arn is provided (not null) or target_groups is empty, the for_each loop does not run, so no default_action block is created
  dynamic "default_action" {
    for_each = var.target_group_arn == null && length(var.target_groups) > 0 ? [1] : []
    content {
      type = "forward"

      forward {
        # This dynamic block creates a target_group block for each element in target_groups
        dynamic "target_group" {
          for_each = var.target_groups
          content {
            # The ARN of the target group
            arn = target_group.value["arn"]

            # The weight of the target group
            weight = target_group.value["weight"]
          }
        }
      }
    }
  }

  # Metadata to assign to the listener
  tags = var.tags
}


