output "id" {
  description = "The ID of the Simple AD directory."
  value       = aws_directory_service_directory.simple_ad.id
}

output "dns_ip_addresses" {
  description = "The IP addresses of the DNS servers for the directory; consumed by DHCP option sets and resolver rules."
  value       = aws_directory_service_directory.simple_ad.dns_ip_addresses
}

output "access_url" {
  description = "The access URL for the directory, such as http://alias.awsapps.com."
  value       = aws_directory_service_directory.simple_ad.access_url
}
