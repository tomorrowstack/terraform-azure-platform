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

resource "azurerm_role_definition" "replicator" {
  name  = "replicator.${var.integration_name_suffix}"
  scope = var.scope

  permissions {
    actions = concat([
      "Microsoft.Authorization/permissions/read",
      "Microsoft.Authorization/roleAssignments/*",
      "Microsoft.Authorization/roleDefinitions/read",

      "Microsoft.Management/managementGroups/subscriptions/write",
      "Microsoft.Management/managementGroups/write",

      "Microsoft.Resources/tags/*",

      "*/register/action"
      ],
      var.replicator_arg_enabled ? [
        "Microsoft.Resources/subscriptions/resourceGroups/write"
      ] : [],
      var.additional_permissions
    )
  }

  assignable_scopes = [
    var.scope
  ]
}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

resource "azuread_application" "replicator" {
  display_name = "replicator.${var.integration_name_suffix}"

  web {
    implicit_grant {
      access_token_issuance_enabled = false
    }
  }
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["Directory.Read.All"]
      type = "Role"
    }

    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["Group.ReadWrite.All"]
      type = "Role"
    }
  }

  dynamic "required_resource_access" {
    for_each = var.additional_required_resource_accesses

    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = required_resource_access.value.resource_accesses
        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      app_role
    ]
  }
}

resource "azuread_service_principal" "replicator" {
  application_id = azuread_application.replicator.application_id
  tags = [
    "WindowsAzureActiveDirectoryIntegratedApp",
  ]
}

resource "azurerm_role_assignment" "replicator" {
  scope              = var.scope
  role_definition_id = azurerm_role_definition.replicator.role_definition_resource_id
  principal_id       = azuread_service_principal.replicator.id
}

resource "azuread_app_role_assignment" "replicator_role_directory" {
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["Directory.Read.All"]
  principal_object_id = azuread_service_principal.replicator.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "replicator_role_group" {
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["Group.ReadWrite.All"]
  principal_object_id = azuread_service_principal.replicator.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

resource "azuread_service_principal_password" "service_principal_password" {
  service_principal_id = azuread_service_principal.replicator.id
  end_date             = "2099-01-01T01:00:00Z"
}

resource "azurerm_policy_definition" "privilege_escalation_prevention" {
  name                = "tos-privilege-escalation-prevention"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Tomorrowstack Privilege Escalation Prevention"
  management_group_id = var.scope

  policy_rule = <<RULE
  {
      "if": {
        "allOf": [
          {
            "equals": "Microsoft.Authorization/roleAssignments",
            "field": "type"
          },
          {
            "allOf": [
              {
                "field": "Microsoft.Authorization/roleAssignments/principalId",
                "equals": "${azuread_service_principal.replicator.object_id}"
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "deny"
      }
  }
RULE
}

resource "azurerm_management_group_policy_assignment" "privilege_escalation_prevention" {
  name                 = "ts-escalation-prevention"
  policy_definition_id = azurerm_policy_definition.privilege_escalation_prevention.id
  management_group_id  = var.scope
}