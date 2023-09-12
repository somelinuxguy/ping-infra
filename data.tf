data "aws_caller_identity" "current" {}

data "terraform_remote_state" "cloudops" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "sect-cloudops"
    key    = "infrastructure/cloudops.tfstate"
    region = var.region
  }
}

data "aws_availability_zones" "all-azs" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}