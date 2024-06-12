resource "azurerm_resource_group" "rg_hub_networks" {
  name = "rg-enterprise-networking-hubs-${var.resource_group_location}"
  location = var.resource_group_location

  tags = {
    displayName = "Resource Group for Hub networks"
  }
}


resource "azurerm_resource_group" "rg_spoke_networks" {
  name = "rg-enterprise-networking-spokes-${var.resource_group_location}"
  location = var.resource_group_location

  tags = {
    displayName = "Resource Group for Spoke networks"
  }
}
