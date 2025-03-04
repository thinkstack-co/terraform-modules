output "id" {
  description = "The ID of the instance"
  value       = aws_instance.ec2.id
}

output "availability_zone" {
  description = "The availability zone of the instance"
  value       = aws_instance.ec2.availability_zone
}

output "key_name" {
  description = "The key name of the instance"
  value       = aws_instance.ec2.key_name
}

output "public_dns" {
  description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.ec2.public_dns
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable"
  value       = aws_instance.ec2.public_ip
}

output "primary_network_interface_id" {
  description = "The ID of the primary network interface of the instance"
  value       = aws_instance.ec2.primary_network_interface_id
}

output "private_dns" {
  description = "The private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.ec2.private_dns
}

output "private_ip" {
  description = "The private IP address assigned to the instance"
  value       = aws_instance.ec2.private_ip
}

output "security_groups" {
  description = "The associated security groups of the instance"
  value       = aws_instance.ec2.security_groups
}

output "vpc_security_group_ids" {
  description = "The associated security groups of the instance, if running in non-default VPC"
  value       = aws_instance.ec2.vpc_security_group_ids
}

output "subnet_id" {
  description = "The VPC subnet ID of the instance"
  value       = aws_instance.ec2.subnet_id
}

output "instance_state" {
  description = "The state of the instance"
  value       = aws_instance.ec2.instance_state
}

output "tags" {
  description = "A mapping of tags assigned to the instance"
  value       = aws_instance.ec2.tags
}

output "instance_alarm_id" {
  description = "The ID of the instance status alarm (if created)"
  value       = local.is_instance_running ? aws_cloudwatch_metric_alarm.instance[0].id : null
}

output "system_alarm_id" {
  description = "The ID of the system status alarm (if created)"
  value       = local.is_instance_running ? aws_cloudwatch_metric_alarm.system[0].id : null
}

output "recovery_support_info" {
  description = "Information about the recovery support for this instance"
  value = {
    instance_family                   = local.instance_family
    is_supported_instance_family      = local.is_recovery_supported
    has_instance_store_volumes        = local.has_instance_store
    instance_state                    = aws_instance.ec2.instance_state
    is_instance_running               = local.is_instance_running
    is_instance_stopped               = local.is_instance_stopped
    alarms_created                    = local.is_instance_running && !local.is_instance_stopped
    is_in_asg                         = contains(keys(aws_instance.ec2.tags), "aws:autoscaling:groupName")
    uses_efa                          = var.uses_efa
    is_on_dedicated_host              = var.host_id != null
    recovery_disabled_by_user         = var.disable_recovery_actions
    recovery_supported                = !local.disable_recovery
    recovery_actions_enabled          = !local.disable_recovery && local.is_instance_running && !local.is_instance_stopped
  }
}
