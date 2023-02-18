resource "aws_ecs_cluster" "ecs_cluster" {
  name = "minecraft-server"
}

resource "aws_iam_role" "iam_role_ecs_task_execution" {
  name = "minecraft-server_ecs-task-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment_ecs_task_execution" {
  role = aws_iam_role.iam_role_ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "minecraft-server"
  cpu                      = 512
  memory                   = 4096
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  execution_role_arn = aws_iam_role.iam_role_ecs_task_execution.arn

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
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/data"
      transit_encryption = "ENABLED"
    }
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "minecraft-server"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_def.arn

  desired_count = 1
  # Minecraft が複数同時起動した際の挙動を把握していないので、安全のために1つしか立ち上がらないようにしておく。
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 1
    weight            = 1
  }
  network_configuration {
    assign_public_ip = true
    subnets = [for az, subnet in aws_subnet.subnets : subnet.id]
    security_groups = [
      aws_security_group.sg_allow_ingress_to_efs.id
    ]
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
