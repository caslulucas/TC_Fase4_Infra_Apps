# URL da fila criada
output "queue_url" {
  value = aws_sqs_queue.this.url
}

# ARN da fila criada
output "queue_arn" {
  value = aws_sqs_queue.this.arn
}