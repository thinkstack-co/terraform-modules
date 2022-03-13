module "thinkstack_azure_ad_provider" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/iam_saml_provider"

  name                   = "thinkstack_azure_ad"
  saml_metadata_document = file("global/iam/providers/azuread_sso_aws_metadata.xml")
}
