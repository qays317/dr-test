output "primary-db-setup" {
    value = aws_lambda_function.main["primary-db-setup"].function_name
}
