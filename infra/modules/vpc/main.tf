module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]

  private_subnets = var.private_subnets
  private_subnet_names = var.private_subnet_names

  database_subnets = var.database_subnets
  database_subnet_names = var.database_subnet_names
  create_database_subnet_group = true
  create_database_subnet_route_table = true

  public_subnets = var.public_subnets
  public_subnet_names = var.public_subnet_names
  map_public_ip_on_launch = true
  
  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project = var.project
    Environment = var.environment
  }
}