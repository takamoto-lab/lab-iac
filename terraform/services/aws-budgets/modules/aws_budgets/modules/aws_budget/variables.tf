variable "budget_name" {
  type = string
  description = "予算の名前"
}

variable "chatbot_iam_role_arn" {
  type = string
  description = "ChatBot に当てる IAM ロールの ARN"
}

variable "mail_address_list" {
  type = list(string)
  description = "通知先のメールアドレスのリスト"
}

variable "slack_workspace_id" {
  type = string
  description = "通知先の Slack ワークスペースのID"
}

variable "slack_channel_id" {
  type = string
  description = "通知先の Slack チャンネルの ID"
}

variable "amount_usd" {
  type = string
  description = "予算（USD）"
}
