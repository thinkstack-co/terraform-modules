############################################################
# AWS Organization
############################################################

resource "aws_organizations_organization" "org" {
  aws_service_access_principals = var.aws_service_access_principals
  enabled_policy_types          = var.enabled_policy_types
  feature_set                   = var.feature_set

  lifecycle {
    prevent_destroy = true
  }
}
