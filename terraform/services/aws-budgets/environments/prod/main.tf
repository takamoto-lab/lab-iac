
module "aws_budgets" {
  source = "../../modules/aws_budgets"
  budget_settings = {
    account-monthly = {
      mail_address_list = [
        "tkfmnkn@gmail.com"
      ]
      slack_workspace_id = "THASWGEBB"
      slack_channel_id   = "CP3FXK0UD"
      amount_usd         = 5
    }
  }
}
