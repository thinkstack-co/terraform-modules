output "id" {
  description = "List of IDs of instances"
  value       = aws_instance.ec2[*].id
}

output "availability_zone" {
  description = "List of availability zones of instances"
  value       = aws_instance.ec2[*].availability_zone
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.ec2[*].private_ip
}

output "security_group_id" {
  description = "ID of the security group applied to the Corelight network interfaces. Consumed by peer security group rules and traffic mirror targets."
  value       = aws_security_group.corelight_sg.id
}

output "listener_network_interface_id" {
  description = "List of listener network interface IDs. Consumed by VPC traffic mirror targets."
  value       = aws_network_interface.listener_nic[*].id
}

output "mgmt_network_interface_id" {
  description = "List of management network interface IDs, attached as device 1 on each sensor."
  value       = aws_network_interface.mgmt_nic[*].id
}

output "nlb_arn" {
  description = "ARN of the Corelight network load balancer. Consumed by traffic mirror targets and listener/target group resources."
  value       = aws_lb.corelight_nlb.arn
}

output "nlb_dns_name" {
  description = "DNS name of the Corelight network load balancer."
  value       = aws_lb.corelight_nlb.dns_name
}
