output "id" {
  description = "List of IDs of instances"
  value       = aws_instance.ec2[0].id
}

output "availability_zone" {
  description = "List of availability zones of instances"
  value       = aws_instance.ec2[0].availability_zone
}

output "key_name" {
  description = "List of key names of instances"
  value       = aws_instance.ec2[0].key_name
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.ec2[0].public_dns
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = aws_instance.ec2[0].public_ip
}

output "primary_network_interface_id" {
  description = "List of IDs of the primary network interface of instances"
  value       = aws_instance.ec2[0].primary_network_interface_id
}

output "private_dns" {
  description = "List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.ec2[0].private_dns
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.ec2[0].private_ip
}

output "security_groups" {
  description = "List of associated security groups of instances"
  value       = aws_instance.ec2[0].security_groups
}

output "vpc_security_group_ids" {
  description = "List of associated security groups of instances, if running in non-default VPC"
  value       = aws_instance.ec2[0].vpc_security_group_ids
}

output "subnet_id" {
  description = "List of IDs of VPC subnets of instances"
  value       = aws_instance.ec2[0].subnet_id
}

output "arn" {
  description = "The ARN of instances"
  value       = aws_instance.ec2[0].arn
}

