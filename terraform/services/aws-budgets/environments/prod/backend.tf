terraform {
  cloud {
    organization = "takamoto-lab"

    workspaces {
      name = "aws-budgets-prod"
    }
  }
}
