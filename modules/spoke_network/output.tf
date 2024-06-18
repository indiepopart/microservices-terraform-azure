output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke_vnet.id
}

output "cluster_nodes_subnet_id" {
  value = azurerm_subnet.cluster_nodes_subnet.id
}