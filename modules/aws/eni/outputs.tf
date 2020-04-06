output "subnet_id" {
  value = aws_network_interface.eni.subnet_id
}

output "description" {
  value = aws_network_interface.eni.description
}

output "private_ips" {
  value = aws_network_interface.eni.private_ips
}

output "security_groups" {
  value = aws_network_interface.eni.security_groups
}

output "attachment" {
  value = aws_network_interface.eni.attachment
}

output "source_dest_check" {
  value = aws_network_interface.eni.source_dest_check
}

output "tags" {
  value = aws_network_interface.eni.tags
}
