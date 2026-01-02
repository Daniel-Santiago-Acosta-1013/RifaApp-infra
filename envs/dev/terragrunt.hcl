include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/app"

  extra_arguments "tfvars" {
    commands = get_terraform_commands_that_need_vars()
    optional_var_files = [
      "${get_terragrunt_dir()}/terraform.tfvars",
    ]
  }
}

inputs = {
  aws_region    = get_env("AWS_REGION", "us-east-1")
  project_name  = "rifaapp"
  environment   = "dev"
  api_base_path = get_env("TF_VAR_api_base_path", "rifaapp")
  auto_migrate  = true
}
