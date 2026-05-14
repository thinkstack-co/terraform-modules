# Outputs preserve list shape for backward compatibility with consumers. Iteration
# over the for_each map produces values in alphabetical key order (dc1, dc2, ...).
output "ec2_instance_id" {
  value = [for inst in aws_instance.ec2_instance : inst.id]
}

output "ec2_instance_priv_ip" {
  value = [for inst in aws_instance.ec2_instance : inst.private_ip]
}

output "ec2_instance_pub_ip" {
  value = [for inst in aws_instance.ec2_instance : inst.public_ip]
}

/*
This is now breaking things
output "ec2_instance_network_id" {
    value = aws_instance.ec2_instance[*].network_interface_id
}*/

output "ec2_instance_subnet_id" {
  value = [for inst in aws_instance.ec2_instance : inst.subnet_id]
}

output "ec2_instance_security_groups" {
  value = [for inst in aws_instance.ec2_instance : inst.security_groups]
}

output "dhcp_options_id" {
  value = aws_vpc_dhcp_options.dc_dns[*].id
}
