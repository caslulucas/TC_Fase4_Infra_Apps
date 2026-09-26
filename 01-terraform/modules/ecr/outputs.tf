# Retorna os nomes dos repositórios criados
output "repository_names" {
  value = [
    for repository in aws_ecr_repository.this :
    repository.name
  ]
}

# Retorna as URLs dos repositórios
output "repository_urls" {
  value = [
    for repository in aws_ecr_repository.this :
    repository.repository_url
  ]
}