module "aws_admin_iam_role" {
  source = "../../modules/aws_admin_iam_role"
  auth0_workspace_name = "auth0-prod"
}
