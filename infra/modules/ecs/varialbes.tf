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

variable "account_id" {
    description = "AWS account ID"
    type = string
}

variable "vpc_id" {
    description = "VPC ID"
    type = string
}

variable "alb_sg_id" {
    description = "ALB security group ID"
    type = string
}

variable "vpc_cidr_block" {
    description = "VPC CIDR block"
    type = string
}

variable "private_subnets" {
    description = "Private subnets"
    type = list(string)
}

variable "target_group_arn" {
    description = "Target group ARN"
    type = string
}

variable "ecr_repository_name" {
    description = "ECR repository name"
    type = string
}

variable "secretsmanager_arn" {
    description = "Secretsmanager ARN"
    type = string
}

variable "rds_address" {
    description = "RDS address"
    type = string
}

variable "rds_port" {
    description = "RDS port"
    type = string
}

variable "execution_role_arn" {
    description = "Execution role ARN"
    type = string
}

variable "task_role_arn" {
    description = "Task role ARN"
    type = string
}