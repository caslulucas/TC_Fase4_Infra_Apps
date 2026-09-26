
variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente de execução"
  type        = string
}

# Lista de microsserviços que receberão um repositório
variable "repositories" {
  description = "Lista de repositórios ECR"
  type        = list(string)
}