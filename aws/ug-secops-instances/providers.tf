terraform {
  required_version = ">= 1.0"
  backend "local" {
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
    region  = var.secops_region
    profile = var.secops_iam_profile
}