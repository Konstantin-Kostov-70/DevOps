# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.59.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#  Generates a random integer to be used for creating globally unique resource names
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = "ContactBookRG${random_integer.ri.result}"
  location = "West Europe"
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "sp" {
  name                = "contact-book-plan${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

# Create the Web App, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "app" {
  name                = "contact-book-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.sp.location
  service_plan_id     = azurerm_service_plan.sp.id

  site_config {
    application_stack {
      node_version = "16-lts"
    }
    always_on = false
  }
}

# Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "git" {
  app_id   = azurerm_linux_web_app.app.id
  repo_url = "https://github.com/nakov/ContactBook"
  branch   = "master"

  use_manual_integration = true
}