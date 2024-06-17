output "hub_vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}

output "hub_fw_private_ip" {
  value = azurerm_firewall.azure_firewall.ip_configuration.0.private_ip_address
}

