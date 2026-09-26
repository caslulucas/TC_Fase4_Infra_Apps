# =====================================================================
# AMAZON ECR
# Cria um repositório para cada microsserviço da plataforma
# Os repositórios serão utilizados pelos pipelines CI/CD para
# armazenar imagens Docker versionadas.
# =====================================================================

resource "aws_ecr_repository" "this" {
  for_each = toset(var.repositories)
  name     = "${var.project_name}-${each.value}"

  image_scanning_configuration {
    # Permite identificar imagens vulneráveis
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
  # Mantém imagens imutáveis para evitar sobrescrita acidental
  image_tag_mutability = "IMMUTABLE"
  tags = {
    Name        = "${var.project_name}-${each.value}"
    Environment = var.environment
  }
}