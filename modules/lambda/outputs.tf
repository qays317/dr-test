output "primary_db_setup_name" {
  value = try(aws_lambda_function.main["primary-db-setup"].function_name, null)
}

output "check_replica_readiness_arn" {
  value = try(aws_lambda_function.main["check-replica-readiness"].arn, null)
}

output "promote_replica_arn" {
  value = try(aws_lambda_function.main["promote-replica"].arn, null)
}

output "check_db_available_arn" {
  value = try(aws_lambda_function.main["check-db-available"].arn, null)
}

output "validate_db_writable_arn" {
  value = try(aws_lambda_function.main["validate-db-writable"].arn, null)
}

output "scaleup_dr_service_arn" {
  value = try(aws_lambda_function.main["scaleup-dr-service"].arn, null)
}

output "check_ecs_healthy_arn" {
  value = try(aws_lambda_function.main["check-ecs-healthy"].arn, null)
}

output "validate_application_arn" {
  value = try(aws_lambda_function.main["validate-application"].arn, null)
}
