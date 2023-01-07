
module "auth0_logging" {
  source = "../../modules/auth0_logging"
}

module "aws_oidc" {
  source = "../../modules/aws_oidc"
}
