# =====================================================================
# SECURITY GROUP
# Permite acesso PostgreSQL dentro da VPC.
# =====================================================================

resource "aws_security_group" "this" {
  name   = "${var.identifier}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
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
    Name = "${var.identifier}-sg"
  }
}

# =====================================================================
# SUBNET GROUP
#
# Define as subnets onde o RDS será criado.
# =====================================================================

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# =====================================================================
# RDS POSTGRESQL
# =====================================================================

resource "aws_db_instance" "this" {
  identifier        = var.identifier
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  username          = "postgres"

  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    aws_security_group.this.id
  ]

  publicly_accessible = false

  skip_final_snapshot = true

  tags = {
    Name        = var.identifier
    Environment = var.environment
  }
}