output "metering_service_principal" {
  value = length(module.metering_service_principal) > 0 ? module.metering_service_principal[0].service_principal : null
}

output "metering_service_principal_password" {
  value     = length(module.metering_service_principal) > 0 ? module.metering_service_principal[0].service_principal_password : null
  sensitive = true
}

output "replicator_service_principal" {
  value = length(module.replicator_service_principal) > 0 ? module.replicator_service_principal[0].service_principal : null
}

output "replicator_service_principal_password" {
  value     = length(module.replicator_service_principal) > 0 ? module.replicator_service_principal[0].service_principal_password : null
  sensitive = true
}

output "azure_tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}