module "ecs_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "${var.project}-${var.environment}-ecs-sg"
  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 8000
      to_port                  = 8000
      protocol                 = "tcp"
      source_security_group_id = var.alb_sg_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name        = "${var.project}-${var.environment}-ecs-sg"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.project}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-cluster"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.project}-${var.environment}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [module.ecs_security_group.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "receipt-api"
    container_port   = 8000
  }

  tags = {
    Name        = "${var.project}-${var.environment}-service"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_appautoscaling_target" "autoscaling_target" {
  service_namespace = "ecs"

  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = 3
  max_capacity = 12

  depends_on = [aws_ecs_service.service]
}

resource "aws_appautoscaling_policy" "autoscaling_policy" {
  name               = "${var.project}-${var.environment}-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    target_value = 50

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_out_cooldown = 60
    scale_in_cooldown  = 120
  }

  depends_on = [aws_appautoscaling_target.autoscaling_target]
}

resource "aws_appautoscaling_scheduled_action" "end_of_month_scheduled_action" {
  name               = "${var.project}-${var.environment}-3days-before-end-of-month"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  schedule = "cron(0 0 L-2 * ? *)"

  scalable_target_action {
    min_capacity = 9
    max_capacity = 12
  }

  depends_on = [aws_appautoscaling_target.autoscaling_target]
}

resource "aws_appautoscaling_scheduled_action" "month_start_scheduled_action" {
  name               = "${var.project}-${var.environment}-month-start"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  schedule = "cron(0 0 1 * ? *)"

  scalable_target_action {
    min_capacity = 3
    max_capacity = 12
  }

  depends_on = [aws_appautoscaling_target.autoscaling_target]
}

resource "aws_ecs_task_definition" "task" {
  family = "${var.project}-${var.environment}-task"

  container_definitions = templatefile("${path.module}/defs/service.tpl", {
    project_name = var.project
    environment  = var.environment

    aws_account_id = var.account_id
    aws_region     = var.region

    ecr_repository_name = var.ecr_repository_name

    rds_address        = var.rds_address
    rds_port           = var.rds_port
    rds_user           = var.rds_user
    secretsmanager_arn = var.secretsmanager_arn
  })

  requires_compatibilities = ["FARGATE"]

  cpu    = 1024
  memory = 2048

  network_mode = "awsvpc"

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-task"
    Project     = var.project
    Environment = var.environment
  }
}