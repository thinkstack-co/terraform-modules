output "lb_arn" {
  description = "The ARN of the Load Balancer"
  value       = aws_lb.this.arn
}

output "lb_dns_name" {
  description = "The DNS name of the Load Balancer"
  value       = aws_lb.this.dns_name
}
