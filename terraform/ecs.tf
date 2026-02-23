resource "aws_ecs_cluster" "arpit_cluster" {
  name = "arpit-spot-cluster"
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "arpit_task" {
  family                   = "arpit-strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu    = "512"
  memory = "1024"

  execution_role_arn = "arn:aws:iam::811738710312:role/ecs_fargate_taskRole"

  container_definitions = jsonencode([{
    name  = "arpit-strapi"
    image = "${aws_ecr_repository.arpit_repo.repository_url}:latest"

    portMappings = [{
      containerPort = 1337
      hostPort      = 1337
    }]

    environment = [
      { name = "NODE_ENV", value = "production" },
      { name = "APP_KEYS", value = "appKey1,appKey2,appKey3,appKey4" },
      { name = "API_TOKEN_SALT", value = "randomSalt123" },
      { name = "ADMIN_JWT_SECRET", value = "superSecretAdmin" },
      { name = "JWT_SECRET", value = "superSecretJwt" }
    ]

    essential = true
  }])
}

resource "aws_ecs_service" "arpit_service" {
  name            = "arpit-spot-service"
  cluster         = aws_ecs_cluster.arpit_cluster.id
  task_definition = aws_ecs_task_definition.arpit_task.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }
}
