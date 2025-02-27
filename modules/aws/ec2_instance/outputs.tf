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
  description = "The ID of the instance status alarm"
  value       = aws_cloudwatch_metric_alarm.instance.id
}

output "system_alarm_id" {
  description = "The ID of the system status alarm"
  value       = aws_cloudwatch_metric_alarm.system.id
}

output "recovery_support_info" {
  description = "Diagnostic information about CloudWatch recovery action support for this instance"
  value = {
    instance_family                  = local.instance_family
    is_recovery_supported            = local.is_recovery_supported
    has_instance_store               = local.has_instance_store
    instance_store_recovery_supported = local.instance_store_recovery_supported
    disable_recovery                 = local.disable_recovery
    uses_efa                         = var.uses_efa
  }
}
