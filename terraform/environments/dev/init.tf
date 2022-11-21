terraform {
  required_version = "1.3.5"
  #   backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.32.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.30.0"
    }
  }
}
provider "azurerm" {
  features {}
}

provider "azuread" {
}
