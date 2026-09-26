# =====================================================================
# SECURITY GROUP
# Permite acesso ao Redis somente dentro da VPC.
# =====================================================================

resource "aws_security_group" "this" {
  name   = "${var.project_name}-${var.environment}-redis-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/16"
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-sg"
  }
}

# =====================================================================
# SUBNET GROUP
#
# Define onde o Redis será executado.
# =====================================================================

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# =====================================================================
# REDIS
# =====================================================================

resource "aws_elasticache_cluster" "this" {
  cluster_id        = "${var.project_name}-${var.environment}-redis"
  engine            = "redis"
  node_type         = "cache.t3.micro"
  num_cache_nodes   = 1
  port              = 6379
  subnet_group_name = aws_elasticache_subnet_group.this.name

  security_group_ids = [
    aws_security_group.this.id
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-redis"

    Environment = var.environment
  }
}