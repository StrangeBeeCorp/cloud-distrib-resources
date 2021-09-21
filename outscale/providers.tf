terraform {
  required_version = ">= 0.15"
  backend "local" {
  }
  required_providers {
    outscale = {
      source = "outscale-dev/outscale"
    }
  }
}

provider "outscale" {
    region  = var.secops_region
}
