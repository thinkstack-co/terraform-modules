terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_transfer_server" "transfer_server" {
  certificate                     = var.certificate
  domain                          = var.domain
  protocols                       = var.protocols
  endpoint_type                   = var.endpoint_type
  invocation_role                 = var.invocation_role
  host_key                        = var.host_key
  url                             = var.url
  identity_provider_type          = var.identity_provider_type
  directory_id                    = var.directory_id
  function                        = var.function
  logging_role                    = var.logging_role
  force_destroy                   = var.force_destroy
  post_authentication_login_banner= var.post_authentication_login_banner
  pre_authentication_login_banner = var.pre_authentication_login_banner
  security_policy_name            = var.security_policy_name
  structured_log_destinations     = var.structured_log_destinations
  tags                            = var.tags
  
  endpoint_details {
    address_allocation_ids = var.address_allocation_ids
    security_group_ids     = var.security_group_ids
    subnet_ids             = var.subnet_ids
    vpc_endpoint_id        = var.vpc_endpoint_id
    vpc_id                 = var.vpc_id
  }
  
  protocol_details {
    as2_transports              = var.as2_transports
    passive_ip                 = var.passive_ip
    set_stat_option            = var.set_stat_option
    tls_session_resumption_mode= var.tls_session_resumption_mode
  }
  
  workflow_details {
    on_upload {
      execution_role = var.workflow_execution_role
      workflow_id    = var.workflow_id
    }
    on_partial_upload {
      execution_role = var.workflow_execution_role
      workflow_id    = var.workflow_id
    }
  }
}
