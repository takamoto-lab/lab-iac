
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

resource "aws_sns_topic" "notification_sns_topic" {
  for_each = var.budget_settings

  name = "aws-budget-notification-topic_${each.key}"
}

resource "aws_sns_topic_policy" "notification_sns_topic_policy" {
  for_each = var.budget_settings

  arn    = aws_sns_topic.notification_sns_topic[each.key].arn
  policy = data.aws_iam_policy_document.notification_sns_topic_policy_document[each.key].json
}

data "aws_iam_policy_document" "notification_sns_topic_policy_document" {
  for_each = var.budget_settings

  statement {
    actions = ["SNS:Publish"]
    principals {
      type        = "AWS"
      identifiers = ["budgets.amazonaws.com"]
    }
    resources = [aws_sns_topic.notification_sns_topic[each.key].arn]
  }
}

resource "aws_budgets_budget" "budget" {
  for_each = var.budget_settings

  name              = each.key
  budget_type       = "COST"
  time_unit         = "MONTHLY"
  time_period_start = "2022-08-01"
  limit_amount      = each.value.amount_usd
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
    subscriber_email_addresses = each.value.mail_address_list
    subscriber_sns_topic_arns = [
      aws_sns_topic.notification_sns_topic[each.key].arn
    ]
  }
}

resource "awscc_chatbot_slack_channel_configuration" "notification_chatbot_configuration" {
  for_each = var.budget_settings

  configuration_name = "aws-budget-notification-configuration_${each.key}"
  iam_role_arn       = aws_iam_role.notification_chatbot_role.arn
  slack_workspace_id = each.value.slack_workspace_id
  slack_channel_id   = each.value.slack_channel_id

  sns_topic_arns = [aws_sns_topic.notification_sns_topic[each.key].arn]
}
