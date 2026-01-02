locals {
  backend = {
    bucket = "rifaapp-terraform-state-745819688993"
    key    = "rifaapp/terraform.tfstate"
    region = "us-east-1"
  }
}

remote_state {
  backend = "s3"
  config = {
    bucket = local.backend.bucket
    key    = local.backend.key
    region = local.backend.region
  }
}
