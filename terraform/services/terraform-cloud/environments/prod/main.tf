locals {
  aws_variable_set             = "varset-PBsjEhPAZjQxmNoS"
  terraform_cloud_variable_set = "varset-kmx6ecdw8awhUfX5"
}

module "terraform-workspaces" {
  source   = "../../modules/terraform-workspaces"
  env_name = "prod"
  workspaces = {
    "admin-user" : {
      variable_set_id_list = [
        local.aws_variable_set
      ]
    },
    "auth0" : {
      variable_set_id_list = [
        local.aws_variable_set,
        local.terraform_cloud_variable_set
      ]
    },
    "aws-budgets" : {
      variable_set_id_list = [
        local.aws_variable_set
      ]
    },
    "github-actions-oidc" : {
      variable_set_id_list = [
        local.aws_variable_set
      ]
    },
    "minecraft-server" : {
      variable_set_id_list = [
        local.aws_variable_set
      ]
    },
  }
}
