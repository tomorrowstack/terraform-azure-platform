output "service_principal" {
  value = {
    object_id = azuread_service_principal.metering.id
    app_id    = azuread_service_principal.metering.application_id
  }
}

output "service_principal_password" {
  value     = azuread_service_principal_password.service_principal_password.value
  sensitive = true
}
