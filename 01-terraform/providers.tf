provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "ToggleMaster"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "LucasSoares"
    }
  }
}