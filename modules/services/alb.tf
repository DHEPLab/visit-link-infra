#trivy:ignore:AVD-AWS-0053
resource "aws_lb" "application_load_balancer" {
  name                       = "${var.project_name}-alb-${var.env}"
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  subnets                    = var.alb_subnet_ids
  security_groups            = [aws_security_group.load_balancer_security_group.id]
}


resource "aws_lb_target_group" "admin_web_target_group" {
  name        = "${var.project_name}-admin-web-tg-${var.env}"
  port        = local.admin_web_container_binding_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold = "3"
    interval          = "30"
    protocol          = "HTTP"
    matcher           = "200"
    timeout           = "3"
    path              = "/"
  }
}

resource "aws_lb_listener" "admin_web_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  # trivy:ignore:avd-aws-0054
  protocol = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "admin_web_https_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.certificate.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin_web_target_group.arn
  }
}

resource "aws_lb_target_group" "service_target_group" {
  name        = "${var.project_name}-service-tg-${var.env}"
  port        = local.service_container_binding_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "3"
  }
}

resource "aws_lb_listener_rule" "service_forward_listener" {
  listener_arn = aws_lb_listener.admin_web_https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/api/*", "/admin/*", "/swagger-ui/*", "/v2/api-docs"]
    }
  }

  tags = {
    name = "${var.project_name}-service-forward-${var.env}"
  }
}