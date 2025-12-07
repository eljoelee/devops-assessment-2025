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

variable "vpc_cidr" {
    description = "VPC CIDR block"
    type = string
}

variable "private_subnet_names" {
    description = "Private subnet names"
    type = list(string)
}

variable "private_subnets" {
    description = "Private subnets"
    type = list(string)
}

variable "database_subnet_names" {
    description = "Database subnet names"
    type = list(string)
}

variable "database_subnets" {
    description = "Database subnets"
    type = list(string)
}

variable "public_subnet_names" {
    description = "Public subnet names"
    type = list(string)
}

variable "public_subnets" {
    description = "Public subnets"
    type = list(string)
}