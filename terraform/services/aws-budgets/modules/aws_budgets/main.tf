
resource "aws_iam_role" "notification_chatbot_role" {
  name = "aws-budget-notification-chatbot"
  path = "/aws-budgets/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "allow-describe-cloudwatch"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "cloudwatch:Describe*",
            "cloudwatch:Get*",
            "cloudwatch:List*",
          ]
          Resource = ["*"]
        }
      ]
    })
  }
}

module "aws_budget" {
  for_each = var.budget_settings

  source = "./modules/aws_budget"
  budget_name = each.key
  chatbot_iam_role_arn = aws_iam_role.notification_chatbot_role.arn
  mail_address_list = each.value.mail_address_list
  slack_workspace_id = each.value.slack_workspace_id
  slack_channel_id = each.value.slack_channel_id
  amount_usd = each.value.amount_usd
}
