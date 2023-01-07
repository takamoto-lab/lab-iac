locals {
  roles = set([
    "tkfmnkn@gmail.com"
  ])
}

data "tfe_outputs" "auth0_workspace_output" {
  organization = "takamoto-lab"
  workspace = var.auth0_workspace_name
}

resource "aws_iam_role" "iam_role_admin_user" {
  for_each = local.roles
  name = each.key
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
          Effect = "Allow"
          Principal = {
              Federated = tfe_outputs.auth0_workspace_output.saml_provider_arn
          }
          Action = "sts:AssumeRoleWithSAML"
          Condition = {
              StringEquals = {
                  "SAML:aud" = "https://signin.aws.amazon.com/saml"
              }
          }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment_iam_role_admin_user" {
  for_each = var.iam_roles
  role = each.key
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
