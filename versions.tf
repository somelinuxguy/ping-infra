terraform {
  required_version = ">=1.3.3"

  backend "s3" {
    bucket = "sect-cloudops"
    key    = "infrastructure/cloudops.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.56.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "3.27.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.66.0"
    }
  }
}