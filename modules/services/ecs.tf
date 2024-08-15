resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-cluster-${var.env}"
}

resource "aws_ecs_task_definition" "service_task" {
  family                   = "${var.project_name}-service-task-${var.env}"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.project_name}-service-task-${var.env}",
      "image": "${var.service_image_uri}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${local.service_container_binding_port},
          "hostPort": ${local.service_container_binding_port}
        }
      ],
      "memory": 1024,
      "cpu": 512,
      "secrets": [
          {
              "name":"JWT_SECRET_KEY",
              "valueFrom":  "${aws_secretsmanager_secret.jwt_key.arn}"
          },
          {
              "name":"DATABASE_URL",
              "valueFrom":  "${aws_secretsmanager_secret.database_url_key.arn}"
          }
      ],
      "environment": [
          {
              "name":"SPRING_PROFILES_ACTIVE",
              "value":  "${var.env}"
          }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log_group.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 1024
  cpu                      = 512
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
}

# resource "aws_ecs_task_definition" "admin_web_task" {
#   family                   = "${var.project_name}-admin-web-task-${var.env}"
#   container_definitions    = <<DEFINITION
#   [
#     {
#       "name": "${var.project_name}-admin-web-task-${var.env}",
#       "image": "${var.admin_web_image_uri}",
#       "essential": true,
#       "portMappings": [
#         {
#           "containerPort": ${local.admin_web_container_binding_port},
#           "hostPort": ${local.admin_web_container_binding_port}
#         }
#       ],
#       "memory": 512,
#       "cpu": 256
#     }
#   ]
#   DEFINITION
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   memory                   = 512
#   cpu                      = 256
#   execution_role_arn       = aws_iam_role.ecs_task_role.arn
# }

resource "aws_ecs_service" "backend_service" {
  name            = "${var.project_name}-backend-service-${var.env}"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.service_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.service_target_group.arn
    container_name   = "${var.project_name}-service-task-${var.env}"
    container_port   = local.service_container_binding_port
  }

  network_configuration {
    subnets          = var.ecs_subnet_ids
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_service_security_group.id]
  }
}

# resource "aws_ecs_service" "admin_web_service" {
#   name            = "${var.project_name}-admin-web-service-${var.env}"
#   cluster         = aws_ecs_cluster.cluster.id
#   task_definition = aws_ecs_task_definition.admin_web_task.arn
#   launch_type     = "FARGATE"
#   desired_count   = 1
#
#   load_balancer {
#     target_group_arn = aws_lb_target_group.admin_web_target_group.arn
#     container_name   = "${var.project_name}-admin-web-task-${var.env}"
#     container_port   = local.admin_web_container_binding_port
#   }
#
#   network_configuration {
#     subnets          = var.ecs_subnet_ids
#     assign_public_ip = false
#     security_groups  = [aws_security_group.ecs_service_security_group.id]
#   }
# }