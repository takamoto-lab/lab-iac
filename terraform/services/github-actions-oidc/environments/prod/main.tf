
module "github_actions_oidc" {
  source = "../../modules/github_actions_oidc"
  mapping_settings = {
    aws-account-management = {
      target_list = [
        "repo:takamoto-lab/lab-iac:environment:production"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = "*"
            Resource = "*"
          }
        ]
      })
    }
  }
}
