output "ec2_instance_id" {
  value = aws_instance.ec2[*].id
}

output "ec2_instance_priv_ip" {
  value = aws_instance.ec2[*].private_ip
}

output "ec2_instance_pub_ip" {
  value = aws_instance.ec2[*].public_ip
}

output "ec2_instance_network_id" {
  value = aws_instance.ec2[*].network_interface_id
}

output "ec2_instance_subnet_id" {
  value = aws_instance.ec2[*].subnet_id
}

output "ec2_instance_security_groups" {
  value = aws_instance.ec2[*].security_groups
}
