terraform {
  cloud {
    organization = "takamoto-lab"

    workspaces {
      name = "auth0-prod"
    }
  }
}
