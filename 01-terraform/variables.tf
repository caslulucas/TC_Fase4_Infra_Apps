#Declaração de variáveis com diferentes tipos e valores

variable "aws_region" {
  description = "Região da AWS onde os recursos serão provisionados"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente de implantação"
  type        = string
  default     = "academy"
}

variable "enable_nat_gateway" {
  description = "Controla a criação do NAT Gateway"
  type        = bool
  default     = false
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "togglemaster"
}


variable "lab_role_arn" {
  description = "ARN da LabRole utilizada no AWS Academy"
  type        = string
  default     = ""
}

variable "db_password" {
  description = "Senha PostgreSQL"
  type        = string
  sensitive   = true
}

#Controle de recursos AWS Academy
variable "enable_rds" {
  type    = bool
  default = true
}

variable "enable_redis" {
  type    = bool
  default = true
}

variable "enable_eks" {
  type    = bool
  default = true
}