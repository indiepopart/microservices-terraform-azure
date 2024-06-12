resource "azurerm_resource_group" "rg_ecommerce" {
  name     = "rg-ecommerce-${var.resource_group_location}"
  location = var.resource_group_location

  tags = {
    displayName = "Resource Group for general purpose"
  }
}

resource "azurerm_resource_group" "rg_ecommerce_acr" {
  name     = "rg-ecommerce-${var.resource_group_location}-acr"
  location = var.resource_group_location

  tags = {
    displayName = "Container Registry Resource Group"
  }
}

resource "azurerm_user_assigned_identity" "registry_managed_identity" {
  name                = "uid-registry"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg_ecommerce.name // replace with your actual resource group name

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
  resource_group_name = azurerm_resource_group.rg_ecommerce.name // replace with your actual resource group name

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
  resource_group_name = azurerm_resource_group.rg_ecommerce.name // replace with your actual resource group name

  tags = {
    displayName = "product managed identity"
    what        = "rbac"
    reason      = "aad-workload-identity"
    app         = "jhipster-product"
  }
}

