#!/usr/bin/env python3
import aws_cdk as cdk

from aws_iac.stacks.minecraft_server import MinecraftServer
from aws_iac.stacks.github_actions_oidc import GitHubActionsOIDC


if __name__ == "__main__":
    app = cdk.App()
    env = cdk.Environment(account="715861157510", region="ap-northeast-1")
    MinecraftServer(app, MinecraftServer.__name__, env=env)
    GitHubActionsOIDC(app, GitHubActionsOIDC.__name__, env=env)
    app.synth()
