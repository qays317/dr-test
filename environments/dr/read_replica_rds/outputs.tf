output "wordpress_secret_arn" {
    value = aws_secretsmanager_secret.rr.arn
}

output "dr_rds_sg_id" {
    value = module.sg.dr_rds_sg_id
}

output "dr_secret_manager_endpoint_sg_id" {
    value = module.sg.dr_secret_manager_endpoint_sg_id
}
