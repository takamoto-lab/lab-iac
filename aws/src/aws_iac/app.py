#!/usr/bin/env python3
import aws_cdk as cdk


if __name__ == "__main__":
    app = cdk.App()
    env = cdk.Environment(account="715861157510", region="ap-northeast-1")
    app.synth()
