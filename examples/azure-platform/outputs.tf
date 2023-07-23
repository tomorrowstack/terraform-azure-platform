output "metering_service_principal" {
  value = module.azure_platform.metering_service_principal
}

output "metering_service_principal_password" {
  value     = module.azure_platform.metering_service_principal_password
  sensitive = true
}

output "replicator_service_principal" {
  value = module.azure_platform.replicator_service_principal
}

output "replicator_service_principal_password" {
  value     = module.azure_platform.replicator_service_principal_password
  sensitive = true
}

output "azure_tenant_id" {
  value = module.azure_platform.azure_tenant_id
}