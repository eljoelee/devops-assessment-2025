module "vpc" {
  source = "./modules/vpc"

  project     = local.projects.name
  environment = local.projects.environment

  vpc_cidr = local.vpc.cidr
  azs      = local.vpc.azs
  
  private_subnets      = local.vpc.private_subnets
  private_subnet_names = local.vpc.private_subnet_names

  database_subnets      = local.vpc.database_subnets
  database_subnet_names = local.vpc.database_subnet_names

  public_subnets      = local.vpc.public_subnets
  public_subnet_names = local.vpc.public_subnet_names
}

module "ecr" {
  source = "./modules/ecr"

  project     = local.projects.name
  environment = local.projects.environment
}

module "rds" {
  source = "./modules/rds"

  project     = local.projects.name
  environment = local.projects.environment

  vpc_id               = module.vpc.vpc_id
  database_subnets_ids = module.vpc.database_subnets

  ecs_sg_id = module.ecs.ecs_sg_id
}

module "iam" {
  source = "./modules/iam"

  project     = local.projects.name
  environment = local.projects.environment
  account_id  = local.projects.account_id

  region      = data.aws_region.current.id

  secretsmanager_arn = module.rds.rds_master_secret_arn
}

module "alb" {
  source = "./modules/alb"

  project     = local.projects.name
  environment = local.projects.environment

  vpc_id             = module.vpc.vpc_id
  public_subnets_ids = module.vpc.public_subnets
}

module "ecs" {
  source = "./modules/ecs"

  project = local.projects.name
  environment = local.projects.environment
  account_id = local.projects.account_id
  
  region = data.aws_region.current.id

  vpc_id = module.vpc.vpc_id
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