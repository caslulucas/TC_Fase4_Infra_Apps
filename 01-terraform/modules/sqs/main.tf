# =====================================================================
# AMAZON SQS
# Fila utilizada pelos microsserviços para comunicação assíncrona.
# =====================================================================

resource "aws_sqs_queue" "this" {
  name = "${var.project_name}-${var.environment}-queue"
  # Tempo que a mensagem permanece invisível após consumo
  visibility_timeout_seconds = 30

  # Retenção das mensagens por 4 dias
  message_retention_seconds = 345600

  tags = {
    Name        = "${var.project_name}-${var.environment}-queue"
    Environment = var.environment
  }
}