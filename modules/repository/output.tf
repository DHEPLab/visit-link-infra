output "admin_web_image_uri" {
  value = aws_ecr_repository.admin_web_repo.repository_url
}

output "service_image_uri" {
  value = aws_ecr_repository.service_repo.repository_url
}
