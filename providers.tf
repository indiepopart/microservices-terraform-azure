terraform {
  required_version = ">=1.8"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.107"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }

  }
}

provider "azurerm" {
  features {}
}

