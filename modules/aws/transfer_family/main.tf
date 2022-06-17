resource "aws_transfer_server" "this" {
  certificate = var.certificate
  domain = var.domain
  protocols = var.protocols
  endpoint_details {
    
  }

  endpoint_type = var.endpoint_type
  invocation_role = var.invocation_role
  host_key = var.host_key
  url = var.url
  identity_provider_type = var.identity_provider_type
  directory_id = var.directory_id
  function = var.function
  logging_role = var.logging_role
  force_destroy = var.force_destroy
  post_authentication_login_banner = var.post_authentication_login_banner
  pre_authentication_login_banner = var.pre_authentication_login_banner
  security_policy_name = var.security_policy_name
  tags = var.tags
}