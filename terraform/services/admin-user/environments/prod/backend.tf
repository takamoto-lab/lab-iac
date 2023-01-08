terraform {
  cloud {
    organization = "takamoto-lab"

    workspaces {
      name = "admin-user-prod"
    }
  }
}
