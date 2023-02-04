
# 参考: https://zenn.dev/miyajan/articles/github-actions-support-openid-connect
resource "aws_iam_openid_connect_provider" "github_actions_oidc_provider" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # thumbprintについて: https://qiita.com/minamijoyo/items/eac99e4b1ca0926c4310
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions_iam_role" {
  for_each = var.mapping_settings

  name = "github-actions-oidc_${each.key}"
  path = "/github-actions-oidc/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions_oidc_provider.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = each.value.target_list
          }
        }
      }
    ]
  })

  inline_policy {
    name   = "allow-resources-to-deploy"
    policy = each.value.inline_policy
  }
}
