locals {
  spoke_vnet_name = "vnet-${var.resource_group_location}-spoke"
  spoke_rg_name = "rg-spokes-${var.resource_group_location}"
  pip_name = "pip-${var.application_id}-00"
}

resource "azurerm_resource_group" "rg_spoke_networks" {
  name = local.spoke_rg_name
  location = var.resource_group_location

  tags = {
    displayName = "Resource Group for Spoke networks"
  }
}

resource "azurerm_virtual_network" "spoke_vnet" {
  name                = local.spoke_vnet_name
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
  name                = "route-spoke-to-hub"
  location            = azurerm_resource_group.rg_spoke_networks.location
  resource_group_name = azurerm_resource_group.rg_spoke_networks.name

  route {
    name                = "r-nexthop-to-fw"
    address_prefix      = "0.0.0.0/0"
    next_hop_type       = "VirtualAppliance"
    next_hop_in_ip_address = var.hub_fw_private_ip
  }
  route {
    name                = "r-internet"
    address_prefix      = "${var.hub_fw_public_ip}/32"
    next_hop_type       = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "cluster_nodes_route_table" {
  subnet_id = azurerm_subnet.cluster_nodes_subnet.id
  route_table_id = azurerm_route_table.spoke_route_table.id
}

resource "azurerm_subnet" "ingress_services_subnet" {
  name                 = "snet-ingress-services"
  resource_group_name  = azurerm_resource_group.rg_spoke_networks.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes       = [var.ingress_services_address_space]

}

resource "azurerm_subnet" "application_gateways_subnet" {
  name                 = "snet-application-gateways"
  resource_group_name  = azurerm_resource_group.rg_spoke_networks.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes       = [var.application_gateways_address_space]

}


resource "azurerm_virtual_network_peering" "spoke_to_hub_peer" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.rg_spoke_networks.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  use_remote_gateways = false

  depends_on = [
    var.hub_vnet_id,
    azurerm_virtual_network.spoke_vnet
  ]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke_peer" {
  name                      = "hub-to-spoke"
  resource_group_name       = var.hub_rg_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id
  allow_forwarded_traffic = false
  allow_virtual_network_access = true
  allow_gateway_transit = false
  use_remote_gateways = false

  depends_on = [
    var.hub_vnet_id,
    azurerm_virtual_network.spoke_vnet
  ]

}

resource "azurerm_private_dns_zone" "dns_zone_acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg_spoke_networks.name
}


resource "azurerm_private_dns_zone_virtual_network_link" "acr_network_link" {
  name                  = "dns-link-acr"
  resource_group_name   = azurerm_resource_group.rg_spoke_networks.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone_acr.name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_public_ip" "spoke_pip" {
  name                = local.pip_name
  location            = azurerm_resource_group.rg_spoke_networks.location
  resource_group_name = azurerm_resource_group.rg_spoke_networks.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones              = ["1", "3"]
  idle_timeout_in_minutes = 4
  ip_version = "IPv4"
}


