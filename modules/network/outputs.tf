output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_target_group_arn" {
  value = aws_alb_target_group.main.arn
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "alb_security_group_id" {
  value = aws_security_group.alb_main.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_main.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds_main.id
}

output "elasticache_security_group_id" {
  value = aws_security_group.elasticache_main.id
}
