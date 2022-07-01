terraform {
  required_version = ">= 1.0"
  backend "local" {
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}
