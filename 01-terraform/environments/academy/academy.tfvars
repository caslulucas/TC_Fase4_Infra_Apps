# environments/academy/terraform.tfvars.example
# Para usar o ambiente academy
# terraform plan -var-file="environments/academy/academy.tfvars"


environment  = "academy"
aws_region   = "us-east-1"
cluster_name = "togglemaster-academy"
db_password  = "SenhaTemporaria123!"
lab_role_arn = "arn:aws:iam::045451774875:role/LabRole"


enable_rds         = true
enable_redis       = true
enable_nat_gateway = true
enable_eks         = true