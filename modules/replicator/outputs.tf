output "service_principal" {
  value = {
    object_id = azuread_service_principal.replicator.id
    app_id    = azuread_service_principal.replicator.application_id
  }
}

output "service_principal_password" {
  value     = azuread_service_principal_password.service_principal_password.value
  sensitive = true
}