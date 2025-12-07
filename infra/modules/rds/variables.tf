variable "project" {
  description = "Project name"
  type = string
}

variable "environment" {
  description = "Environment name"
  type = string
}

variable "region" {
  description = "Region"
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "database_subnets_ids" {
  description = "Database subnets ids"
  type = list(string)
}

variable "ecs_sg_id" {
  description = "ECS security group ID"
  type = string
}