module "vpc" {
  source = "./modules/vpc"

  project     = local.project
  environment = local.environment
  region      = local.region

  vpc_cidr = "10.0.0.0/16"

  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_names = ["private-subnet-1", "private-subnet-2", "private-subnet-3"]

  database_subnets      = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  database_subnet_names = ["database-subnet-1", "database-subnet-2", "database-subnet-3"]

  public_subnets      = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  public_subnet_names = ["public-subnet-1", "public-subnet-2", "public-subnet-3"]
}

module "ecr" {
  source = "./modules/ecr"

  project     = local.project
  environment = local.environment
}

module "rds" {
  source = "./modules/rds"

  project     = local.project
  environment = local.environment
  region      = local.region

  vpc_id               = module.vpc.vpc_id
  database_subnets_ids = module.vpc.database_subnets

  ecs_sg_id = module.ecs.ecs_sg_id
}

module "iam" {
  source = "./modules/iam"

  project     = local.project
  environment = local.environment
  region      = local.region
  account_id  = local.account_id

  secretsmanager_arn = module.rds.rds_master_secret_arn
}

module "alb" {
  source = "./modules/alb"

  project     = local.project
  environment = local.environment

  vpc_id             = module.vpc.vpc_id
  public_subnets_ids = module.vpc.public_subnets
}

module "ecs" {
  source = "./modules/ecs"

  project = local.project
  environment = local.environment
  region = local.region
  account_id = local.account_id

  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  private_subnets = module.vpc.private_subnets

  alb_sg_id = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn

  ecr_repository_name = module.ecr.ecr_repository_name

  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn = module.iam.ecs_task_role_arn

  rds_address = module.rds.rds_address
  rds_port = module.rds.rds_port
  rds_user = module.rds.rds_user

  secretsmanager_arn = module.rds.rds_master_secret_arn
}