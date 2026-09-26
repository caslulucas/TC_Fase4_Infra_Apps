provider "aws" {
  region = var.aws_region
}

# Bucket utilizado pelo Terraform State
resource "aws_s3_bucket" "tfstate" {
  bucket = "togglemaster-terraform-state"
  tags = {
    Name = "togglemaster-terraform-state"
  }
}