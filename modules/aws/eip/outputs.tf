output "id" {
  description = "Contains the EIP allocation ID"
  value       = aws_eip.eip[*].id
}

output "public_ip" {
  description = "Contains the public IP address"
  value       = aws_eip.eip[*].public_ip
}
