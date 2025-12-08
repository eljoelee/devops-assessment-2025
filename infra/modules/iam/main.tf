# 컨테이너 내부의 어플리케이션에서 AWS 서비스에 접근할 때 사용하는 역할
module "ecs_task_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role"

  name = "ecs-task-role"

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole"
      ]
      principals = [{
        type = "Service"
        identifiers = [
          "ecs-tasks.amazonaws.com"
        ]
      }]
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

module "ecs_task_execution_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name = "${var.project}-${var.environment}-execution-policy"

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
       {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${var.region}:${var.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.region}:${var.account_id}:log-group:${var.project}-${var.environment}-app-log-group:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "${var.secretsmanager_arn}"
        }
      ]
    }
    EOF

    tags = {
      Project     = var.project
      Environment = var.environment
    }
}

# 컨테이너를 실행할 때 사용하는 역할
module "ecs_task_execution_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role"

  name = "ecs-task-execution-role"

  policies = {
    AmazonECSTaskExecutionRolePolicy = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    custom                           = module.ecs_task_execution_policy.arn
  }

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole"
      ]
      principals = [{
        type = "Service"
        identifiers = [
          "ecs-tasks.amazonaws.com"
        ]
      }]
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}