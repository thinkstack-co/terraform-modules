module "thinkstack_azure_ad" {
  source = ""
  
  saml_metadata_document = "${file("global/iam/providers/FederationMetadata.xml")}"
}
