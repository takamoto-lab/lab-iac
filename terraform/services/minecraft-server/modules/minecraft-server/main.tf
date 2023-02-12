locals {
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]
  cidr_blocks        = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name           = "minecraft-server"
  cidr           = local.vpc_cidr
  azs            = local.availability_zones
  public_subnets = local.cidr_blocks
}

data "aws_subnet" "subnets" {
  for_each          = toset(local.availability_zones)
  vpc_id            = module.vpc.vpc_id
  availability_zone = each.key
}

module "efs" {
  source = "terraform-aws-modules/efs/aws"
  version = "1.1.1"

  name   = "minecraft-server"
  mount_targets = {
    for az, subnet in data.aws_subnet.subnets : az => { subnet_id = "${subnet.id}" }
  }

  security_group_name   = "minecraft-server_efs"
  security_group_vpc_id = module.vpc.vpc_id
  security_group_rules = {
    vpc = { cidr_blocks = local.cidr_blocks }
  }

  enable_backup_policy = true
}
