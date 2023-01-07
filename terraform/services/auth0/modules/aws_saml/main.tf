resource "aws_iam_saml_provider" "saml_provider_auth0" {
  name                   = "auth0"
  saml_metadata_document = vars.saml_metadata_document
}
