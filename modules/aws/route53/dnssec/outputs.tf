output "digest_algorithm_mnemonic" {
  value = aws_route53_key_signing_key.this.digest_algorithm_mnemonic
}

output "digest_algorithm_type" {
  value = aws_route53_key_signing_key.this.digest_algorithm_type
}

output "digest_value" {
  value = aws_route53_key_signing_key.this.digest_value
}

output "dnskey_record" {
  value = aws_route53_key_signing_key.this.dnskey_record
}

output "ds_record" {
  value = aws_route53_key_signing_key.this.ds_record
}

output "flag" {
  value = aws_route53_key_signing_key.this.flag
}

output "key_tag" {
  value = aws_route53_key_signing_key.this.key_tag
}

output "public_key" {
  value = aws_route53_key_signing_key.this.public_key
}

output "signing_algorithm_mnemonic" {
  value = aws_route53_key_signing_key.this.signing_algorithm_mnemonic
}

output "signing_algorithm_type" {
  value = aws_route53_key_signing_key.this.signing_algorithm_type
}
