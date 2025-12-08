module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "${var.project}-${var.environment}-alb"
  vpc_id  = var.vpc_id
  subnets = var.public_subnets_ids

  security_group_ingress_rules = {
    all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }

    # all_https = {
    #     type = "ingress"
    #     from_port = 443
    #     to_port = 443
    #     protocol = "tcp"
    #     description = "Allow HTTPS traffic"
    #     cidr_ipv4 = "0.0.0.0/0"
    # }
  }

  security_group_egress_rules = {
    all_traffic = {
      ip_protocol = "-1"
      description = "Allow all traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_tags = {
    Project     = var.project
    Environment = var.environment
  }

  listeners = {
    http_listener = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "alb-target-group"
      }
    }

    # 도메인, acm 등 추가 리소스 필요하여 주석 처리함
    # redirect_http_to_https = {
    #     port = 80
    #     protocol = "HTTP"

    #     redirect = {
    #         port = 443
    #         protocol = "HTTPS"
    #         status_code = "HTTP_301"
    #     }
    # }

    #   https_listener = {
    #       port = 443
    #       protocol = "HTTPS"
    #       certificate_arn = var.certificate_arn

    #       forward = {
    #           target_group_key = "alb-target-group"
    #       }
    #   }
  }

  target_groups = {
    alb-target-group = {
      name        = "${var.project}-${var.environment}-alb-tg"
      port        = 8000
      protocol    = "HTTP"
      target_type = "ip"

      health_check = {
        path                = "/health"
        interval            = 30
        timeout             = 10
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200-302"
      }

      create_attachment = false
    }
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}