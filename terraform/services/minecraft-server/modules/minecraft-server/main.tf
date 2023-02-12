locals {
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  cidr_blocks        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
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
  source  = "terraform-aws-modules/efs/aws"
  version = "1.1.1"

  name = "minecraft-server"
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

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "minecraft-server"
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "minecraft-server"
  cpu                      = 512
  memory                   = 4096
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions = jsonencode([
    {
      name  = "minecraft-server-container",
      image = "itzg/minecraft-server:latest",
      environment = [
        { name = "EULA", value = "TRUE" },
        { name = "MEMORY", value = "4G" },
        { name = "TYPE", value = "PAPER" },
      ],
      portMappings = [
        { containerPort = 25565 },
      ],
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  volume {
    name = "data"
    efs_volume_configuration {
      file_system_id = module.efs.id
      root_directory = "/data"
    }
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "minecraft-server"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_def.arn

  desired_count = 1
  # Minecraft が複数同時起動した際の挙動を把握していないので、安全のために1つしか立ち上がらないようにしておく。
  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 1
    weight            = 1
  }
  network_configuration {
    assign_public_ip = true
    subnets = [
      for az, subnet in data.aws_subnet.subnets : subnet.id
    ]
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
