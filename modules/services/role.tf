data "aws_iam_policy_document" "ecs_task_role_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.project_name}-ecs-task-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_document.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_role_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.database_url_key.arn,
      aws_secretsmanager_secret.jwt_key.arn
    ]
  }
}

resource "aws_iam_policy" "ecs_task_role_policy" {
  name   = "${var.project_name}-ecs-task-role-policy-${var.env}"
  policy = data.aws_iam_policy_document.ecs_task_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.project_name}-s3-access-policy-${var.env}"
  description = "Policy to allow ECS tasks to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          var.bucket_anr,
          "${var.bucket_anr}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3_access" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
