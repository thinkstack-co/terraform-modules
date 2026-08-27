output "id" {
  description = "List of IDs of the Silverpeak appliance instances."
  value       = aws_instance.ec2[*].id
}

output "availability_zone" {
  description = "List of availability zones the Silverpeak appliances were placed in."
  value       = aws_instance.ec2[*].availability_zone
}

output "security_group_id" {
  description = "ID of the security group applied to the Silverpeak network interfaces. Consumed by route tables and peer security group rules."
  value       = aws_security_group.silverpeak_sg.id
}

output "wan0_network_interface_id" {
  description = "List of wan0 network interface IDs. Consumed by route tables that send internet-bound traffic through the appliance."
  value       = aws_network_interface.wan0_nic[*].id
}

output "lan0_network_interface_id" {
  description = "List of lan0 network interface IDs. Consumed by route tables that send private-subnet traffic through the appliance."
  value       = aws_network_interface.lan0_nic[*].id
}

output "mgmt0_network_interface_id" {
  description = "List of mgmt0 network interface IDs. mgmt0 is the primary (device 0) interface on each instance."
  value       = aws_network_interface.mgmt0_nic[*].id
}

output "mgmt0_private_ip" {
  description = "List of private IP addresses on the mgmt0 interfaces. Consumed when building management access rules."
  value       = aws_network_interface.mgmt0_nic[*].private_ip
}
