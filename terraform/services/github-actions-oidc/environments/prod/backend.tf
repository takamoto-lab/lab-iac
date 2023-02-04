terraform {
  cloud {
    organization = "takamoto-lab"

    workspaces {
      name = "github-actions-oidc-prod"
    }
  }
}
