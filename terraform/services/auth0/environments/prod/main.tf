
module "auth0_logging" {
  source = "../../modules/auth0_logging"
}

module "aws_saml" {
  source = "../../modules/aws_saml"
  saml_metadata_document = file("saml_metadata.xml")
}
