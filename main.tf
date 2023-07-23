terraform {
  required_version = ">= 1.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.54.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.38.0"
    }
  }
}

data "azurerm_management_group" "root" {
  name = var.management_group_name
}

module "replicator_service_principal" {
  count  = var.replicator_enabled || var.replicator_arg_enabled ? 1 : 0
  source = "./modules/replicator/"

  integration_name_suffix = var.integration_name_suffix
  scope                   = data.azurerm_management_group.root.id

  additional_required_resource_accesses = var.additional_required_resource_accesses
  additional_permissions                = var.additional_permissions
}

module "metering_service_principal" {
  count  = var.metering_enabled ? 1 : 0
  source = "./modules/metering/"

  integration_name_suffix = var.integration_name_suffix
  scope                   = data.azurerm_management_group.root.id
}

data "azuread_client_config" "current" {}