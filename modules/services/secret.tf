resource "aws_secretsmanager_secret" "database_url_key" {
  name        = "${var.project_name}-database-url-${var.env}"
  description = "database url"
}

resource "aws_secretsmanager_secret_version" "database_url_key_version" {
  secret_id     = aws_secretsmanager_secret.database_url_key.id
  secret_string = var.database_url
}

resource "random_password" "jwt_key" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "jwt_key" {
  name        = "${var.project_name}-secretsmanager-${var.env}"
  description = "JWT Key for generate access token"
}

resource "aws_secretsmanager_secret_version" "jwt_key_version" {
  secret_id     = aws_secretsmanager_secret.jwt_key.id
  secret_string = random_password.jwt_key.result
}

resource "aws_secretsmanager_secret" "google_map_api_key" {
  name = "${var.project_name}-google-map-api-key-${var.env}"
}
