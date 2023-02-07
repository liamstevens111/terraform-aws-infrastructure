data "aws_ecr_repository" "repo" {
  name = var.ecr_repo_name
}

resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"

  tags = {
    Name = "${var.environment}-ecs"
  }
}

resource "aws_cloudwatch_log_group" "ecs-log-group" {
  name = "${var.environment}-logs"

  tags = {
    Application = var.environment
  }
}

resource "aws_ecs_task_definition" "aws-ecs-task-definition" {
  family                   = "${var.environment}-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  # task_role_arn = 

  container_definitions = jsonencode([{
    name      = var.environment,
    image     = "${data.aws_ecr_repository.repo.repository_url}:${var.ecr_tag}",
    essential = true,
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs-log-group.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs-liam"
        awslogs-create-group  = "true"
      }
    }
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.app_port
      hostPort      = var.app_port
    }],
    environment = var.environment_variables,
    secrets = [for secret in var.parameter_store_secrets :
    tomap({ name = secret.name, valueFrom = secret.arn })],
    "cpu" : 256,
    "memory" : 512
  }])
}

resource "aws_ecs_service" "main" {
  name            = "${var.environment}-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.aws-ecs-task-definition.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.environment
    container_port   = var.app_port
  }
}

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_task_execution_policy_ssm" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.policydocument.arn
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-ssm-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.policydocument-ssm.arn
}


resource "aws_iam_policy" "policydocument" {
  name   = "tf-policydocument"
  policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

resource "aws_iam_policy" "policydocument-ssm" {
  name   = "tf-policydocument-ssm"
  policy = data.aws_iam_policy_document.ecs_task_execution_policy_ssm.json
}
