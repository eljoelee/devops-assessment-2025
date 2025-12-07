output "rds_master_secret_arn" {
  value = module.rds.db_instance_master_user_secret_arn
}

output "rds_address" {
  value = module.rds.db_instance_address
}

output "rds_port" {
  value = module.rds.db_instance_port
}

output "rds_user" {
  value = module.rds.db_instance_username
}