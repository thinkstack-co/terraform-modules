output "ec2_instance_id" {
  value = aws_instance.ec2_instance[*].id
}

output "ec2_instance_priv_ip" {
  value = aws_instance.ec2_instance[*].private_ip
}

output "ec2_instance_pub_ip" {
  value = aws_instance.ec2_instance[*].public_ip
}

/*
This is now breaking things
output "ec2_instance_network_id" {
    value = aws_instance.ec2_instance[*].network_interface_id
}*/

output "ec2_instance_subnet_id" {
  value = aws_instance.ec2_instance[*].subnet_id
}

output "ec2_instance_security_groups" {
  value = aws_instance.ec2_instance[*].security_groups
}

output "dhcp_options_id" {
  value = aws_vpc_dhcp_options.dc_dns[*].id
}
