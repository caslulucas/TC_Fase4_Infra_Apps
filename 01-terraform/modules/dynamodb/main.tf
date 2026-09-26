# =====================================================================
# DYNAMODB
#
# Armazena métricas e analytics do ToggleMaster.
# =====================================================================

resource "aws_dynamodb_table" "this" {
  name         = "ToggleMasterAnalytics"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  tags = {
    Name        = "ToggleMasterAnalytics"
    Environment = var.environment
  }
}