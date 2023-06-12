output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.cert.arn
}

output "lb_listener_certificate_arn" {
  description = "The ARN of the LB Listener Certificate"
  value       = aws_lb_listener_certificate.cert_attach.certificate_arn
}
