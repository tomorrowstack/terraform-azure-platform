terraform {
  backend "azurerm" {
    subscription_id      = "{...}"
    resource_group_name  = "{...}"
    storage_account_name = "{...}"
    container_name       = "{...}"
    key                  = "{...}.tfstate"
  }
}

provider "azurerm" {
  features {}
}

module "azure_platform" {
  source = "tomorrowstack/platform/azure"

  integration_name_suffix = "{...}"
  management_group_name   = "{...}"
}
