output "node-instance-id" {
    value = aws_instance.node.id
}

output "node-instance-ami-id" {
    value = aws_instance.node.ami
}

output "node-mgmt-public-ip" {
    value = aws_eip.mgmt_ip.public_ip
}

output "node-mgmt-private-ip" {
    value = aws_network_interface.management_eni.private_ips
}

output "node-data-private-ip" {
    value = aws_network_interface.data_eni.private_ips
}

output "node-security-group-id" {
    value = aws_security_group.node_mgmt_sg.id
}