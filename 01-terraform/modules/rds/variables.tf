variable "project_name" {
  description = "Nome do projeto"
  type        = string
}


variable "environment" {
  description = "Ambiente atual"
  type        = string
}

# Nome da instância
variable "identifier" {
  description = "Identificador da instância"
  type        = string
}


variable "private_subnet_ids" {
  description = "Subnets privadas da VPC"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "db_password" {
  description = "Senha do banco"
  type        = string
  sensitive   = true
}