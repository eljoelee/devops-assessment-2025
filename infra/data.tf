locals {
  projects = {
    name     = "spendit-receipt-api"
    environment = "dev"
    account_id  = "131421611146"
  }

  vpc = {
    cidr = "10.0.0.0/16"
    
    azs = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]

    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnet_names = ["private-subnet-1", "private-subnet-2", "private-subnet-3"]

    database_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    database_subnet_names = ["database-subnet-1", "database-subnet-2", "database-subnet-3"]
    
    public_subnets = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
    public_subnet_names = ["public-subnet-1", "public-subnet-2", "public-subnet-3"]
  }
}

data "aws_region" "current" {}