data "tfe_organization" "org" {
  name = "takamoto-lab"
}

data "tfe_oauth_client" "oauth_client" {
  organization     = data.tfe_organization.org.name
  service_provider = "github"
}

resource "tfe_project" "project" {
  organization = data.tfe_organization.org.name
  name         = var.env_name
}

resource "tfe_workspace" "workspaces" {
  for_each = var.workspaces

  name         = "${each.key}-${var.env_name}"
  organization = data.tfe_organization.org.name
  project_id   = tfe_project.project.id

  queue_all_runs    = false
  working_directory = "terraform/services/${each.key}/environments/${var.env_name}"
  trigger_patterns = [
    "terraform/services/${each.key}/**/*"
  ]

  vcs_repo {
    identifier     = "takamoto-lab/lab-iac"
    oauth_token_id = data.tfe_oauth_client.oauth_client.oauth_token_id
  }
}

resource "tfe_workspace_variable_set" "workspace_variable_set" {
  for_each = {
    for obj in flatten([
      for index_key, settings in var.workspaces : [
        for variable_set_id in settings.variable_set_id_list : {
          id              = "${index_key}:${variable_set_id}"
          index_key       = index_key
          variable_set_id = variable_set_id
        }
      ]
    ]) : obj.id => obj
  }

  workspace_id    = tfe_workspace.workspaces[each.value.index_key].id
  variable_set_id = each.value.variable_set_id
}
