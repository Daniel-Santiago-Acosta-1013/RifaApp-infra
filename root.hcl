locals {
  backend = {
    bucket = "rifaapp-terraform-state-745819688993"
    key    = "rifaapp/terraform.tfstate"
    region = "us-east-1"
  }

  backend_lambda_dir        = "${get_repo_root()}/backend/lambda_dist"
  local_lambda_dir          = "${get_repo_root()}/../RifaApp-back/lambda_dist"
  backend_lambda_dir_exists = can(fileset(local.backend_lambda_dir, "*"))
  resolved_lambda_dir       = local.backend_lambda_dir_exists ? local.backend_lambda_dir : local.local_lambda_dir
}

remote_state {
  backend = "s3"
  config = {
    bucket = local.backend.bucket
    key    = local.backend.key
    region = local.backend.region
  }
}

inputs = {
  lambda_source_dir = get_env("TF_VAR_lambda_source_dir", local.resolved_lambda_dir)
}
