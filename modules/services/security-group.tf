resource "aws_security_group" "load_balancer_security_group" {
  name   = "${var.project_name}-lb-sg-${var.env}"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      # trivy:ignore:avd-aws-0107
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # trivy:ignore:avd-aws-0104
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_service_security_group" {
  name   = "${var.project_name}-ecs-service-sg-${var.env}"
  vpc_id = var.vpc_id

  ingress {
    from_port       = local.service_container_binding_port
    to_port         = local.service_container_binding_port
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  ingress {
    from_port       = local.admin_web_container_binding_port
    to_port         = local.admin_web_container_binding_port
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # trivy:ignore:avd-aws-0104
    cidr_blocks = ["0.0.0.0/0"]
  }
}