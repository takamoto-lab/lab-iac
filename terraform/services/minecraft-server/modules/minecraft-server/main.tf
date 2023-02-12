locals {
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  cidr_blocks        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name           = "minecraft-server"
  cidr           = local.vpc_cidr
  azs            = local.availability_zones
  public_subnets = local.cidr_blocks
}

module "efs" {
  source = "terraform-aws-modules/efs/aws"
  version = "1.1.1"

  name   = "minecraft-server"
  enable_backup_policy = true
}
