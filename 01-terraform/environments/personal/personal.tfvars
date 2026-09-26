#terraform plan -var-file="environments/personal/personal.tfvars"

environment  = "personal"
aws_region   = "us-east-1"
cluster_name = "togglemaster-personal"


#Controle de recursos AWS
enable_rds         = true
enable_redis       = true
enable_nat_gateway = true
enable_eks         = true