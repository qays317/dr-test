data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = var.state_bucket_name
    key = "environments/global/iam/terraform.tfstate"
    region = var.state_bucket_region
  }
}

data "terraform_remote_state" "network" {
    backend = "s3"
    config = {
      bucket = var.state_bucket_name
      key = "environments/primary/network/terraform.tfstate"
      region = var.state_bucket_region
    }
}

module "rds" {
  source = "../../../modules/rds"
  # VPC configuration
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  subnets = data.terraform_remote_state.network.outputs.subnets
  private_subnets_ids = data.terraform_remote_state.network.outputs.private_subnets_ids
  # RDS configuration
  rds_identifier = var.rds_identifier
  rds = local.rds_config
}

module "lambda" {
  source = "../../../modules/lambda"
  name_prefix = "wordpress-infrastructure"
  lambda_source_base = local.lambda_source_base
  function = local.lambda
}


resource "aws_lambda_invocation" "db_bootstrap" {
  function_name = module.lambda.primary_db_setup_name

  input = jsonencode({
    trigger = "terraform"
  })

  depends_on = [
    module.rds,
    module.lambda
  ]
}
