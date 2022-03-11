##########################
# Azure AD SAML Modules
##########################

module "thinkstack_azure_ad" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/azure_ad_sso"

  saml_metadata_document = file("global/iam/providers/FederationMetadata.xml")
}
