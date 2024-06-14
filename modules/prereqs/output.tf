output "registry_principal_id" {
  value = azurerm_user_assigned_identity.registry_managed_identity.id
}

output "store_principal_id" {
  value = azurerm_user_assigned_identity.store_managed_identity.id
}

output "product_principal_id" {
  value = azurerm_user_assigned_identity.product_managed_identity.id
}

