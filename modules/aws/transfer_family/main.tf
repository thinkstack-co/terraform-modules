terraform {
  required_version = ">= 0.15.0"
}

###########################
# Data Sources
###########################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

###########################
# IAM Policy
###########################
resource "aws_iam_policy" "cloudwatch_logging_policy" {
  description = var.iam_policy_description
  name_prefix = var.iam_policy_name_prefix
  path        = var.iam_policy_path
  tags        = var.tags
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
        Effect = "Allow",
        Action = [
            "logs:DescribeLogStreams",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
        ],
        Resource = [
            "*"
        ]
        }]
    })
}

###########################
# IAM Role
###########################

resource "aws_iam_role" "cloudwatch_logging_role" {
  assume_role_policy    = var.iam_role_assume_role_policy
  description           = var.iam_role_description
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration
  name_prefix           = var.iam_role_name_prefix
  permissions_boundary  = var.iam_role_permissions_boundary
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logging_role_attach" {
  role       = aws_iam_role.cloudwatch_logging_role.name
  policy_arn = aws_iam_policy.cloudwatch_logging_policy.arn
}

##################################
# Transfer Family Server
##################################
resource "aws_transfer_server" "this" {
  certificate                      = var.certificate
  domain                           = var.domain
  protocols                        = var.protocols
  endpoint_type                    = var.endpoint_type
  invocation_role                  = var.invocation_role
  host_key                         = var.host_key
  url                              = var.url
  identity_provider_type           = var.identity_provider_type
  directory_id                     = var.directory_id
  function                         = var.function
  logging_role                     = var.logging_role
  force_destroy                    = var.force_destroy
  post_authentication_login_banner = var.post_authentication_login_banner
  pre_authentication_login_banner  = var.pre_authentication_login_banner
  security_policy_name             = var.security_policy_name
  tags                             = var.tags

  endpoint_details {
    address_allocation_ids = var.address_allocation_ids
    security_group_ids     = var.security_group_ids
    subnet_ids             = var.subnet_ids
    vpc_endpoint_id        = var.vpc_endpoint_id
    vpc_id                 = var.vpc_id
  }
}
