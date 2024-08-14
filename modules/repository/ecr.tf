resource "aws_ecr_repository" "admin_web_repo" {
  name = local.admin_web_image_name
  #trivy:ignore:avd-aws-0031
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = ""
  }
}


resource "aws_ecr_repository" "service_repo" {
  name = local.service_image_name
  #trivy:ignore:avd-aws-0031
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = ""
  }
}
