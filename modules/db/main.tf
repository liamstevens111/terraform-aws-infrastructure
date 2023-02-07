resource "aws_db_instance" "main" {
  identifier             = "liamdb"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.1"
  db_name                = "${var.namespace}db"
  instance_class         = var.instance_class
  username               = var.username
  password               = var.db_password
  parameter_group_name   = "default.postgres14"
  skip_final_snapshot    = true
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
  multi_az               = true
}

resource "aws_db_subnet_group" "db-subnet" {
  name       = "db_subnet_group"
  subnet_ids = var.subnet_ids
}
