resource "azurerm_user_assigned_identity" "registry_managed_identity" {
  name                = "uid-registry"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  tags = {
    displayName = "registry managed identity"
    what        = "rbac"
    reason      = "aad-workload-identity"
    app         = "jhipster-registry"
  }
}

resource "azurerm_user_assigned_identity" "store_managed_identity" {
  name                = "uid-store"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  tags = {
    displayName = "store managed identity"
    what        = "rbac"
    reason      = "aad-workload-identity"
    app         = "jhipster-store"
  }
}

resource "azurerm_user_assigned_identity" "product_managed_identity" {
  name                = "uid-product"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  tags = {
    displayName = "product managed identity"
    what        = "rbac"
    reason      = "aad-workload-identity"
    app         = "jhipster-product"
  }
}

