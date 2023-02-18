locals {
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = {
    "ap-northeast-1a": {"cidr_block": "10.0.1.0/24"},
    "ap-northeast-1c": {"cidr_block": "10.0.2.0/24"},
    "ap-northeast-1d": {"cidr_block": "10.0.3.0/24"}
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = local.vpc_cidr
  # EFS をマウントする際に必要。
  # false の場合、「Failed to resolve "fs-xxxxxxxxxxx.efs.us-east-1.amazonaws.com"」 のようなエラーが出る。
  # Ref. https://aws.amazon.com/jp/premiumsupport/knowledge-center/fargate-unable-to-mount-efs/
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnets" {
  for_each = local.availability_zones
  vpc_id = aws_vpc.vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.key
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table_associations_public" {
  for_each = aws_subnet.subnets
  subnet_id = each.value.id
  route_table_id = aws_route_table.route_table_public.id
}
