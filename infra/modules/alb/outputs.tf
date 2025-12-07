output "target_group_arn" {
    value = module.alb.target_groups["alb-target-group"].arn
}

output "alb_sg_id" {
    value = module.alb.security_group_id
}