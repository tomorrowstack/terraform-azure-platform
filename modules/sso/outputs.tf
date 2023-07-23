output "application" {
  value = {
    object_id = azuread_application.sso_application.object_id
    app_id    = azuread_application.sso_application.application_id
  }
}

output "application_client_secret" {
  value     = azuread_application_password.sso_application_password.value
  sensitive = true
}