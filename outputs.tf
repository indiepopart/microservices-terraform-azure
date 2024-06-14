output "resource_group_name" {
  value = azurerm_resource_group.rg_ecommerce.name
}


output "hub_vnet_id" {
  value = module.hub_network.hub_vnet_id
}