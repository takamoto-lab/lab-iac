module "terraform-workspaces" {
  source = "../../modules/terraform-workspaces"
  env_name = "prod"
  workspaces = {
    "admin-user": {},
    "auth0": {},
    "aws-budgets": {},
    "github-actions-oidc": {},
  }
}
