

resource "azurerm_role_assignment" "registry_identity_role_assignment" {
  scope                = module.prereqs.registry_principal_id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.cluster.kubelet_identity_id
}

resource "azurerm_role_assignment" "store_identity_role_assignment" {
  scope                = module.prereqs.store_principal_id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.cluster.kubelet_identity_id
}

resource "azurerm_role_assignment" "product_identity_role_assignment" {
  scope                = module.prereqs.product_principal_id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.cluster.kubelet_identity_id
}
