variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets_ids" {
  description = "Public subnets ids"
  type        = list(string)
}

# variable "certificate_arn" {
#     description = "Certificate ARN"
#     type = string
# }