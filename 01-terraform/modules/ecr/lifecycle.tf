# Mantém apenas as 20 imagens mais recentes
#evitar acúmulo infinito de imagens.
#Ideal para Portifólio de microsserviços que possuem pipelines CI/CD que geram imagens Docker diariamente.

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Mantém apenas as 20 imagens mais recentes"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}