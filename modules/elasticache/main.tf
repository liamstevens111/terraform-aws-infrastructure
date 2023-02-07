resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.namespace}-cluster"
  engine               = var.engine
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  port                 = var.port

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = var.security_group_ids
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.namespace}-subnet-group"
  subnet_ids = var.subnet_ids
}
