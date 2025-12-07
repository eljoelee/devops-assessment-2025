variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "secretsmanager_arn" {
  description = "Secretsmanager ARN"
  type        = string
}