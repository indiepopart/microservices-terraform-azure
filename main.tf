resource "azurerm_resource_group" "rg_ecommerce" {
  name     = "rg-ecommerce-${var.resource_group_location}"
  location = var.resource_group_location

  tags = {
    displayName = "Resource Group for general purpose"
  }
}


module "prereqs" {
  source = "./modules/prereqs"

  resource_group_location = azurerm_resource_group.rg_ecommerce.location
  resource_group_name     = azurerm_resource_group.rg_ecommerce.name
}

module "acr" {
  source = "./modules/acr"

  resource_group_location = azurerm_resource_group.rg_ecommerce.location
}



module "hub_network" {
  source = "./modules/hub_network"
  resource_group_location = azurerm_resource_group.rg_ecommerce.location
}

module "spoke_network" {
  source = "./modules/spoke_network"
  resource_group_location = azurerm_resource_group.rg_ecommerce.location
  hub_fw_private_ip          = module.hub_network.hub_fw_private_ip
  application_id         = var.application_id
}


module "cluster" {
  source = "./modules/cluster"

  resource_group_location = azurerm_resource_group.rg_ecommerce.location
  resource_group_name     = azurerm_resource_group.rg_ecommerce.name
  resource_group_id       = azurerm_resource_group.rg_ecommerce.id
  acr_id                  = module.acr.acr_id
  vnet_subnet_id          = module.hub_network.hub_vnet_id
}

