data "tfe_organization" "org" {
  name = "takamoto-lab"
}

data "tfe_oauth_client" "oauth_client" {
  organization     = data.tfe_organization.org.name
  service_provider = "github"
}

resource "tfe_project" "project" {
  organization = data.tfe_organization.org.name
  name = var.env_name
}

resource "tfe_workspace" "workspaces" {
  for_each = var.workspaces

  name         = "${each.key}-${var.env_name}"
  organization = data.tfe_organization.org.name
  project_id = tfe_project.project.id

  queue_all_runs = false
  working_directory = "terraform/services/${each.key}/environments/${var.env_name}"
  trigger_patterns = [
    "terraform/services/${each.key}/**/*"
  ]

  vcs_repo {
    identifier = "takamoto-lab/lab-iac"
    oauth_token_id = data.tfe_oauth_client.oauth_client.oauth_token_id
  }
}
