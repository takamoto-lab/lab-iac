
resource "aws_sns_topic" "notification_sns_topic" {
  name = "aws-budget-notification-topic_${var.budget_name}"
}

resource "aws_sns_topic_policy" "notification_sns_topic_policy" {
  arn    = aws_sns_topic.notification_sns_topic.arn
  policy = data.aws_iam_policy_document.notification_sns_topic_policy_document.json
}

data "aws_iam_policy_document" "notification_sns_topic_policy_document" {
  statement {
    actions = ["SNS:Publish"]
    resources = [aws_sns_topic.notification_sns_topic.arn]

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }
  }
}

resource "aws_budgets_budget" "budget" {
  name              = var.budget_name
  budget_type       = "COST"
  time_unit         = "MONTHLY"
  time_period_start = "2022-08-01"
  limit_amount      = var.amount_usd
  limit_unit        = "USD"

  cost_types {
    include_credit             = false
    include_discount           = true
    include_other_subscription = true
    include_recurring          = true
    include_refund             = false
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
    use_amortized              = false
    use_blended                = false
  }

  notification {
    notification_type          = "ACTUAL"
    comparison_operator        = "GREATER_THAN"
    threshold                  = 90
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = var.mail_address_list
    subscriber_sns_topic_arns = [
      aws_sns_topic.notification_sns_topic.arn
    ]
  }
}

resource "awscc_chatbot_slack_channel_configuration" "notification_chatbot_configuration" {
  configuration_name = "aws-budget-notification-configuration_${var.budget_name}"
  iam_role_arn       = var.chatbot_iam_role_arn
  slack_workspace_id = var.slack_workspace_id
  slack_channel_id   = var.slack_channel_id
  sns_topic_arns = [aws_sns_topic.notification_sns_topic.arn]
}
