#!/usr/bin/env python3
import aws_cdk.aws_iam as iam
from aws_cdk import Stack
from constructs import Construct


class GitHubActionsOIDC(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # 参考: https://zenn.dev/miyajan/articles/github-actions-support-openid-connect
        oidc_provider = iam.OpenIdConnectProvider(
            self,
            "GithubActionsOidcProvider",
            url="https://token.actions.githubusercontent.com",
            client_ids=["sts.amazonaws.com"],
            # thumbprintについて: https://qiita.com/minamijoyo/items/eac99e4b1ca0926c4310
            thumbprints=["6938fd4d98bab03faadb97b34396831e3780aea1"],
        )

        iam.Role(
            self,
            "GithubActionsOidcRole",
            path="/github-actions/",
            role_name="cdk-deploy-job",
            assumed_by=iam.FederatedPrincipal(
                federated=oidc_provider.open_id_connect_provider_arn,
                assume_role_action="sts:AssumeRoleWithWebIdentity",
                conditions={
                    "StringEquals": {
                        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    },
                    "StringLike": {
                        "token.actions.githubusercontent.com:sub": [
                            "repo:takamoto-lab/lab-iac:environment:production"
                        ]
                    },
                },
            ),
            inline_policies={
                "allow-resources-to-deploy": iam.PolicyDocument(
                    statements=[iam.PolicyStatement(actions=["*"], resources=["*"])]
                )
            },
        )
