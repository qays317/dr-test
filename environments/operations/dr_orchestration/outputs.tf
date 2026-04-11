output "state_machine_name" {
  value = aws_sfn_state_machine.dr_failover_orchestrator.name
}

output "state_machine_arn" {
  value = aws_sfn_state_machine.dr_failover_orchestrator.arn
}

output "recheck_incident_lambda_arn" {
  value = aws_lambda_function.main["recheck-incident"].arn
}

output "check_replica_readiness_lambda_arn" {
  value = aws_lambda_function.main["check-replica-readiness"].arn
}

output "promote_replica_lambda_arn" {
  value = aws_lambda_function.main["promote-replica"].arn
}

output "check_db_available_lambda_arn" {
  value = aws_lambda_function.main["check-db-available"].arn
}

output "validate_db_writable_lambda_arn" {
  value = aws_lambda_function.main["validate-db-writable"].arn
}

output "scaleup_dr_service_lambda_arn" {
  value = aws_lambda_function.main["scaleup-dr-service"].arn
}

output "check_ecs_healthy_lambda_arn" {
  value = aws_lambda_function.main["check-ecs-healthy"].arn
}

output "validate_application_lambda_arn" {
  value = aws_lambda_function.main["validate-application"].arn
}
