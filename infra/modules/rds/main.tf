module "rds_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "${var.project}-${var.environment}-rds-sg"
  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = var.ecs_sg_id
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
    Name        = "${var.project}-${var.environment}-rds-sg"
    Project     = var.project
    Environment = var.environment
  }
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.project}-${var.environment}-rds"

  engine         = "postgres"
  engine_version = "15.15"
  family         = "postgres15"
  instance_class = "db.t3.medium"

  create_db_parameter_group = false
  parameter_group_name      = "default.postgres15"

  allocated_storage     = 50
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "receipts_db"
  username = "receipts_user"
  port     = 5432

  manage_master_user_password          = true
  manage_master_user_password_rotation = false

  vpc_security_group_ids = [module.rds_security_group.security_group_id]
  subnet_ids             = var.database_subnets_ids
  create_db_subnet_group = true

  create_db_option_group = false

  multi_az            = true
  publicly_accessible = false

  deletion_protection     = true
  skip_final_snapshot     = false
  backup_retention_period = 7
  copy_tags_to_snapshot   = true

  maintenance_window = "Sun:16:00-Sun:17:00"
  backup_window      = "17:00-18:00"

  tags = {
    Name        = "${var.project}-${var.environment}-rds"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}