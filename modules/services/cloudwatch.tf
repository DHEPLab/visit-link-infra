resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/fargate/service/${var.project_name}-${var.env}"
  retention_in_days = 30
}