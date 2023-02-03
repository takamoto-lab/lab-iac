variable "budget_settings" {
  type = map(object({
    mail_address_list = list(string),
    slack_workspace_id = string,
    slack_channel_id = string,
    amount_usd = number
  }))
  description = "予算の設定"
}
