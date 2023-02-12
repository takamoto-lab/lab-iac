terraform {
  cloud {
    organization = "takamoto-lab"

    workspaces {
      name = "minecraft-server-prod"
    }
  }
}
