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

resource "azurerm_role_assignment" "metering" {
  scope                = var.scope
  role_definition_name = "Cost Management Reader"
  principal_id         = azuread_service_principal.metering.id
}

resource "azuread_application" "metering" {
  display_name = "metering.${var.integration_name_suffix}"

  web {
    implicit_grant {
      access_token_issuance_enabled = false
    }
  }
}

resource "azuread_service_principal" "metering" {
  application_id = azuread_application.metering.application_id
}

resource "azuread_service_principal_password" "service_principal_password" {
  service_principal_id = azuread_service_principal.metering.id
  end_date             = "2099-01-01T01:00:00Z"
}
