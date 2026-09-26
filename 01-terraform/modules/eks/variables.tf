# =====================================================================
# EKS VARIABLES
# =====================================================================

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente atual"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.30"
}

variable "private_subnet_ids" {
  description = "Subnets privadas utilizadas pelo EKS"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Subnets públicas utilizadas pelo EKS"
  type        = list(string)
}

# ID da VPC utilizada pelo cluster
variable "vpc_id" {
  description = "VPC utilizada pelo cluster"
  type        = string
}

# ARN da LabRole (AWS Academy)
variable "lab_role_arn" {
  description = "ARN da LabRole"
  type        = string
  default     = ""
}

# Tipo das instâncias dos Nodes
variable "node_instance_type" {
  description = "Tipo das instâncias EC2"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Quantidade desejada de nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Quantidade mínima"
  type        = number
  default     = 1
}
variable "max_size" {
  description = "Quantidade máxima"
  type        = number
  default     = 3
}