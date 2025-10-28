output "id" {
  description = "ID of the instance"
  value       = aws_instance.ec2.id
}

output "availability_zone" {
  description = "Availability zone of the instance"
  value       = aws_instance.ec2.availability_zone
}

output "key_name" {
  description = "Key name of the instance"
  value       = aws_instance.ec2.key_name
}

output "public_dns" {
  description = "Public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.ec2.public_dns
}

output "public_ip" {
  description = "Public IP address assigned to the instance, if applicable"
  value       = aws_instance.ec2.public_ip
}

output "primary_network_interface_id" {
  description = "ID of the primary network interface of the instance"
  value       = aws_instance.ec2.primary_network_interface_id
}

output "private_dns" {
  description = "Private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.ec2.private_dns
}

output "private_ip" {
  description = "Private IP address assigned to the instance"
  value       = aws_instance.ec2.private_ip
}

output "security_groups" {
  description = "Associated security groups of the instance"
  value       = aws_instance.ec2.security_groups
}

output "vpc_security_group_ids" {
  description = "Associated security groups of the instance, if running in non-default VPC"
  value       = aws_instance.ec2.vpc_security_group_ids
}

output "subnet_id" {
  description = "ID of VPC subnet of the instance"
  value       = aws_instance.ec2.subnet_id
}

# CloudWatch Alarm Outputs
output "instance_alarm_id" {
  description = "ID of the instance status check alarm"
  value       = aws_cloudwatch_metric_alarm.instance.id
}

output "system_alarm_id" {
  description = "ID of the system status check alarm"
  value       = aws_cloudwatch_metric_alarm.system.id
}

output "instance_state" {
  description = "State of the instance"
  value       = aws_instance.ec2.instance_state
}

# Performance Optimization Diagnostic Outputs
# These outputs help verify that the performance optimization is working correctly
# and show which method is being used to obtain AWS region and account information.

output "performance_optimization_info" {
  description = <<-EOT
    Diagnostic information showing whether performance optimization is active.
    This helps confirm that region/account variables are being passed correctly
    to avoid redundant AWS API calls.
  EOT
  value = {
    # Shows whether aws_region variable was passed (true = optimized, false = using data source)
    region_optimization_active = var.aws_region != null

    # Shows whether aws_account_id variable was passed (true = optimized, false = using data source)
    account_optimization_active = var.aws_account_id != null

    # The actual region being used (regardless of source)
    aws_region = local.aws_region

    # The actual account ID being used (regardless of source)
    aws_account_id = local.aws_account_id

    # Overall optimization status message
    optimization_status = (var.aws_region != null && var.aws_account_id != null) ? "✅ OPTIMIZED: Both variables passed, no API calls made" : (var.aws_region != null || var.aws_account_id != null) ? "⚠️ PARTIAL: Some variables passed, some API calls still made" : "❌ NOT OPTIMIZED: Using data sources, making redundant API calls"
  }
}
