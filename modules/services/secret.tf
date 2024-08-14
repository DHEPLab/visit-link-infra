resource "aws_secretsmanager_secret" "database_url_key" {
  name        = "${var.project_name}-database-url-${var.env}"
  description = "database url"
}

resource "aws_secretsmanager_secret_version" "database_url_key_version" {
  secret_id     = aws_secretsmanager_secret.database_url_key.id
  secret_string = var.database_url
}