locals {
  cluster_vnet_name = "vnet-hub-spoke-${var.application_id}-00"
  route_table_name = "route-${local.cluster_vnet_name}-clusternodes-to-hub"
  spoke_rg_name = "rg-enterprise-networking-spokes-${var.resource_group_location}"

}

resource "azurerm_resource_group" "rg_spoke_networks" {
  name = local.spoke_rg_name
  location = var.resource_group_location

  tags = {
    displayName = "Resource Group for Spoke networks"
  }
}

resource "azurerm_virtual_network" "spoke_vnet" {
  name                = local.cluster_vnet_name
  location            = azurerm_resource_group.rg_spoke_networks.location
  resource_group_name = azurerm_resource_group.rg_spoke_networks.name
  address_space       = [var.spoke_vnet_address_space]
}

resource "azurerm_subnet" "cluster_nodes_subnet" {
  name                 = "snet-clusternodes"
  resource_group_name  = azurerm_resource_group.rg_spoke_networks.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes       = [var.cluster_nodes_address_space]
}

resource "azurerm_route_table" "spoke_route_table" {
  name                = local.route_table_name
  location            = azurerm_resource_group.rg_spoke_networks.location
  resource_group_name = azurerm_resource_group.rg_spoke_networks.name

  route {
    name                = "r-nexthop-to-fw"
    address_prefix      = "0.0.0.0/0"
    next_hop_type       = "VirtualAppliance"
    next_hop_in_ip_address = var.hub_fw_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "cluster_nodes_route_table" {
  subnet_id = azurerm_subnet.cluster_nodes_subnet.id
  route_table_id = azurerm_route_table.spoke_route_table.id
}

resource "azurerm_subnet" "ingress_services_subnet" {
  name                 = "snet-clusternodes"
  resource_group_name  = azurerm_resource_group.rg_spoke_networks.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes       = [var.ingress_services_address_space]

}

resource "azurerm_subnet" "application_gateways_subnet" {
  name                 = "snet-clusternodes"
  resource_group_name  = azurerm_resource_group.rg_spoke_networks.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes       = [var.application_gateways_address_space]

}
