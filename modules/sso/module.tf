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

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

resource "azuread_application" "sso_application" {
  display_name = "sso.${var.integration_name_suffix}"

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
      type = "Role"
    }
  }

  web {
    redirect_uris = [var.redirect_uri]
  }

  lifecycle {
    ignore_changes = [
      app_role
    ]
  }
}

resource "azuread_application_password" "sso_application_password" {
  application_object_id = azuread_application.sso_application.object_id
}