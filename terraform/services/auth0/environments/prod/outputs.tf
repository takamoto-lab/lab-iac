output "saml_provider_arn" {
  description = "Auth0 の SAML プロバイダの ARN"
  value       = module.aws_saml.saml_provider_arn
}
