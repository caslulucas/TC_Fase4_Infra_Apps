variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

# Define se o NAT Gateway será criado para academy
variable "enable_nat_gateway" {
  description = "Controla a criação do NAT Gateway"
  type        = bool
  default     = false
}