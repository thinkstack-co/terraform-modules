output "instance_id" {
  description = "ID of the AppGate gateway EC2 instance."
  value       = aws_instance.appgate.id
}

output "availability_zone" {
  description = "Availability zone of the gateway instance."
  value       = aws_instance.appgate.availability_zone
}

output "private_ip" {
  description = "Private IP address of the gateway instance."
  value       = aws_instance.appgate.private_ip
}

output "public_ip" {
  description = "Public IP assigned to the instance at launch (if associate_public_ip_address is true). For the stable EIP address, use eip_public_ip."
  value       = aws_instance.appgate.public_ip
}

output "ami_id" {
  description = "ID of the AppGate SDP AMI the gateway was launched from."
  value       = data.aws_ami.appgate_sdp.id
}

output "eip_id" {
  description = "Allocation ID of the gateway's Elastic IP. Null if create_eip is false."
  value       = var.create_eip ? aws_eip.appgate[0].id : null
}

output "eip_public_ip" {
  description = "Public IP address of the gateway's Elastic IP. Null if create_eip is false."
  value       = var.create_eip ? aws_eip.appgate[0].public_ip : null
}

output "instance_alarm_id" {
  description = "ID of the instance status-check alarm. Null if create_cloudwatch_alarms is false."
  value       = var.create_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.instance[0].id : null
}

output "system_alarm_id" {
  description = "ID of the system status-check alarm. Null if create_cloudwatch_alarms is false."
  value       = var.create_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.system[0].id : null
}
