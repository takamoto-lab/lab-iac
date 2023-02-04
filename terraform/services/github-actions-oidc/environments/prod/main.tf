
module "github_actions_oidc" {
  source = "../../modules/github_actions_oidc"
  mapping_settings = {
    aws-account-management = {
      target_list = [
        "repo:takamoto-lab/lab-iac:environment:production"
      ]
      inline_policy = jsonencode({
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      })
    }
  }
}
