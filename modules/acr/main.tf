resource "azurerm_resource_group" "rg_ecommerce_acr" {
  name     = "rg-ecommerce-${var.resource_group_location}-acr"
  location = var.resource_group_location

  tags = {
    displayName = "Container Registry Resource Group"
  }
}

resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = azurerm_resource_group.rg_ecommerce_acr.name
  location                 = var.resource_group_location
  sku                      = "Premium"
  admin_enabled            = false
  network_rule_set {
    default_action = "Allow"
  }

  quarantine_policy_enabled = false

  trust_policy {
    enabled = false
  }

  retention_policy {
    days = 15
    enabled = true
  }

  tags = {
    displayName = "Container Registry"
  }
}

