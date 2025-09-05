resource "aws_secretsmanager_secret" "app" {
  name = "${var.project_name}-${var.environment}-app-secret"

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-secret"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    username = var.secret_username
    password = var.secret_password
  })
}
