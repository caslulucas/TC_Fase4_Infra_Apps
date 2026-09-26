# terraform {
#   backend "s3" {
#     bucket = "togglemaster-terraform-state"
#     key    = "terraform.tfstate"
#     region = "us-east-1"

#     #evitar alterações simultâneas no estado do Terraform
#     use_lockfile = true
#   }
# }