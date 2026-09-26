variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente atual"
  type        = string
}


variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

# 
variable "private_subnet_ids" {
  description = "Subnets privadas onde o Redis será criado"
  type        = list(string)
}