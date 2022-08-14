#!/usr/bin/env python3
import aws_cdk.aws_sns as sns
import aws_cdk.aws_iam as iam
import aws_cdk.aws_budgets as budgets
import aws_cdk.aws_chatbot as chatbot
from aws_cdk import Stack
from constructs import Construct


mail_address = "tkfmnkn@gmail.com"
slack_channel_id = "CP3FXK0UD"
slack_workspace_id = "THASWGEBB"
amount_usd = 5


class AccountBudget(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        topic = sns.Topic(self, "SNSTopic")
        sns.TopicPolicy(
            self,
            "SNSTopicPolicy",
            topics=[topic],
            policy_document=iam.PolicyDocument(
                statements=[
                    iam.PolicyStatement(
                        sid="BudgetsSNSPublishingPermissions",
                        actions=["SNS:Publish"],
                        principals=[iam.ServicePrincipal("budgets.amazonaws.com")],
                        resources=[topic.topic_arn],
                    )
                ]
            ),
        )

        chatbot_role = iam.Role(
            self,
            "ChatbotRole",
            path="/account-budget/",
            assumed_by=iam.ServicePrincipal("chatbot.amazonaws.com"),
            inline_policies={
                "allow-describe-cloudwatch": iam.PolicyDocument(
                    statements=[
                        iam.PolicyStatement(
                            actions=[
                                "cloudwatch:Describe*",
                                "cloudwatch:Get*",
                                "cloudwatch:List*",
                            ],
                            resources=["*"],
                        )
                    ]
                )
            },
        )

        chatbot.CfnSlackChannelConfiguration(
            self,
            "ChatBotSlackChannelConfiguration",
            configuration_name="MonthlyBudgetNotification-Chatbot",
            iam_role_arn=chatbot_role.role_arn,
            slack_channel_id=slack_channel_id,
            slack_workspace_id=slack_workspace_id,
            sns_topic_arns=[topic.topic_arn],
        )

        budgets.CfnBudget(
            self,
            "MonthlyBudget",
            budget=budgets.CfnBudget.BudgetDataProperty(
                budget_limit=budgets.CfnBudget.SpendProperty(
                    amount=amount_usd, unit="USD"
                ),
                budget_name="Monthly Budget",
                budget_type="COST",
                time_unit="MONTHLY",
                cost_types=budgets.CfnBudget.CostTypesProperty(
                    include_credit=False,
                    include_discount=True,
                    include_other_subscription=True,
                    include_recurring=True,
                    include_refund=False,
                    include_subscription=True,
                    include_support=True,
                    include_tax=True,
                    include_upfront=True,
                    use_amortized=False,
                    use_blended=False,
                ),
            ),
            notifications_with_subscribers=[
                budgets.CfnBudget.NotificationWithSubscribersProperty(
                    notification=budgets.CfnBudget.NotificationProperty(
                        notification_type="ACTUAL",
                        comparison_operator="GREATER_THAN",
                        threshold=90,
                        threshold_type="PERCENTAGE",
                    ),
                    subscribers=[
                        budgets.CfnBudget.SubscriberProperty(
                            subscription_type="EMAIL",
                            address=mail_address,
                        ),
                        budgets.CfnBudget.SubscriberProperty(
                            subscription_type="SNS",
                            address=topic.topic_arn,
                        ),
                    ],
                )
            ],
        )
