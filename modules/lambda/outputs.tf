output "primary_db_setup_name" {
  value = aws_lambda_function.main["primary-db-setup"].function_name
}

output "check_replica_readiness_arn" {
  value = aws_lambda_function.main["check-replica-readiness"].arn
}

output "promote_replica_arn" {
  value = aws_lambda_function.main["promote-replica"].arn
}

output "check_db_available_arn" {
  value = aws_lambda_function.main["check-db-available"].arn
}

output "validate_db_writable_arn" {
  value = aws_lambda_function.main["validate-db-writable"].arn
}

output "scaleup_dr_service_arn" {
  value = aws_lambda_function.main["scaleup-dr-service"].arn
}

output "check_ecs_healthy_arn" {
  value = aws_lambda_function.main["check-ecs-healthy"].arn
}

output "validate_application_arn" {
  value = aws_lambda_function.main["validate-application"].arn
}
