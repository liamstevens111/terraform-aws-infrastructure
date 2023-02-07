resource "aws_vpc" "main" {
  cidr_block           = var.base_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.namespace}-VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main IGW"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 1)
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 2)
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 3)
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 4)
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet 2"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.namespace}-public-routing-table"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1.id
}

resource "aws_route_table_association" "public_2" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_2.id
}

resource "aws_security_group" "alb_main" {
  name        = "alb_security_group"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "alb_security_group"
  }
}

resource "aws_security_group_rule" "allow_incoming_http" {
  type              = "ingress"
  from_port         = 0
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.alb_main.id
}

resource "aws_security_group_rule" "allow_incoming_https" {
  type              = "ingress"
  from_port         = 0
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.alb_main.id
}

resource "aws_security_group_rule" "outgoing_to_ecs" {
  type              = "egress"
  from_port         = 0
  to_port           = 4000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_main.id
}

resource "aws_lb" "alb_ecs_main" {
  name               = "alb-ecs-main"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_main.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

resource "aws_security_group" "ecs_main" {
  name        = "ecs_security_group"
  description = "Security group for ECS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_main.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.namespace}-ecs-sg"
  }
}

resource "aws_security_group" "rds_main" {
  name        = "rds_security_group"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_main.id]
  }

  tags = {
    Name = "${var.namespace}-rds-sg"
  }
}

resource "aws_security_group" "elasticache_main" {
  name        = "elasticache_security_group"
  description = "Security group for Elasticache"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_main.id]
  }

  tags = {
    Name = "${var.namespace}-elasticache-sg"
  }
}

resource "aws_alb_target_group" "main" {
  name        = "alb-ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}

resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.alb_ecs_main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }
}
