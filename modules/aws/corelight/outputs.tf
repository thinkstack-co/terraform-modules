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
