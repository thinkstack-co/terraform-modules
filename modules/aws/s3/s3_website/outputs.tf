output "s3_bucket_id" {
  description = "Name of the website bucket. Consumed by bucket policies and CloudFront origin configuration."
  value       = aws_s3_bucket.this.id
}

output "s3_bucket_arn" {
  description = "ARN of the website bucket. Consumed by IAM policies granting access to the bucket."
  value       = aws_s3_bucket.this.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the website bucket. Consumed by CloudFront distributions using the bucket as an origin."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "s3_hosted_zone_id" {
  description = "Route 53 hosted zone ID for the bucket's region. Consumed by Route 53 alias records pointing at the bucket."
  value       = aws_s3_bucket.this.hosted_zone_id
}

output "s3_bucket_region" {
  description = "Region the website bucket was created in."
  value       = aws_s3_bucket.this.region
}

output "s3_bucket_website_endpoint" {
  description = "Website endpoint for the bucket. Consumed by Route 53 alias records and CloudFront origins."
  value       = aws_s3_bucket_website_configuration.this.website_endpoint
}

output "s3_bucket_website_domain" {
  description = "Domain of the website endpoint. Consumed by Route 53 alias records targeting the website endpoint."
  value       = aws_s3_bucket_website_configuration.this.website_domain
}
