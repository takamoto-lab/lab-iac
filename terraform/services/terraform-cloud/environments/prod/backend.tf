terraform {
  cloud {
    organization = "takamoto-lab"

    workspaces {
      name = "terraform-cloud"
    }
  }
}
