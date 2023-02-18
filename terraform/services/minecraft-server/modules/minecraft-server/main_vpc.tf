locals {
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = {
    "ap-northeast-1a": "10.0.1.0/24",
    "ap-northeast-1c": "10.0.2.0/24",
    "ap-northeast-1d": "10.0.3.0/24"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name           = "minecraft-server"
  cidr           = local.vpc_cidr
  azs            = keys(local.availability_zones)
  public_subnets = values(local.availability_zones)
  # EFS をマウントする際に必要。
  # false の場合、「Failed to resolve "fs-xxxxxxxxxxx.efs.us-east-1.amazonaws.com"」 のようなエラーが出る。
  # Ref. https://aws.amazon.com/jp/premiumsupport/knowledge-center/fargate-unable-to-mount-efs/
  enable_dns_hostnames = true
}

data "aws_subnet" "subnets" {
  for_each = toset(module.vpc.public_subnets)
  id       = each.value
}
