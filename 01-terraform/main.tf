module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  enable_nat_gateway = var.enable_nat_gateway
  vpc_cidr           = "10.0.0.0/16"

  availability_zones = [
    "us-east-1a",
    "us-east-1b",
  ]
}

# =====================================================================
# ECR
#
# Repositórios Docker utilizados pelos microsserviços.
# =====================================================================

module "ecr" {

  source = "./modules/ecr"

  project_name = var.project_name

  environment = var.environment

  repositories = [
    "auth",
    "flag",
    "targeting",
    "evaluation",
    "analytics"
  ]
}

module "eks" {
  source       = "./modules/eks"
  project_name = var.project_name
  environment  = var.environment
  cluster_name = "${var.project_name}-${var.environment}"

  #controle de recursos AWS
  count = var.enable_eks ? 1 : 0

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  lab_role_arn       = var.lab_role_arn

  depends_on = [
    module.vpc
  ]
}

# =====================================================================
# DYNAMODB
# =====================================================================

module "dynamodb" {
  source       = "./modules/dynamodb"
  project_name = var.project_name
  environment  = var.environment
}


# =====================================================================
# SQS
# =====================================================================

module "sqs" {
  source       = "./modules/sqs"
  project_name = var.project_name
  environment  = var.environment
}


# =====================================================================
# AUTH DATABASE
# =====================================================================

module "auth_db" {
  source       = "./modules/rds"
  project_name = var.project_name
  environment  = var.environment
  identifier   = "auth-db"
  db_password  = var.db_password

  #controle de recursos AWS
  count = var.enable_rds ? 1 : 0

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

# =====================================================================
# FLAG DATABASE
# =====================================================================

module "flag_db" {
  source       = "./modules/rds"
  project_name = var.project_name
  environment  = var.environment
  identifier   = "flag-db"

  #controle de recursos AWS
  count = var.enable_rds ? 1 : 0

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  db_password        = var.db_password
}

# =====================================================================
# TARGETING DATABASE
# =====================================================================

module "targeting_db" {
  source       = "./modules/rds"
  project_name = var.project_name
  environment  = var.environment

  #controle de recursos AWS
  count = var.enable_rds ? 1 : 0


  db_password        = var.db_password
  identifier         = "targeting-db"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

# =====================================================================
# REDIS
# =====================================================================

module "redis" {
  source       = "./modules/redis"
  project_name = var.project_name

  #controle de recursos AWS
  count = var.enable_redis ? 1 : 0

  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}