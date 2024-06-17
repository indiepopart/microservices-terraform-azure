locals {
  fw_pip_name   = "pip-fw-${var.resource_group_location}-default"
  hub_fw_name   = "fw-${var.resource_group_location}-hub"
  hub_vnet_name = "vnet-${var.resource_group_location}-hub"
}

resource "azurerm_resource_group" "rg_hub_networks" {
  name = "rg-enterprise-networking-hubs-${var.resource_group_location}"
  location = var.resource_group_location

  tags = {
    displayName = "Resource Group for Hub networks"
  }
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = local.hub_vnet_name
  location            = azurerm_resource_group.rg_hub_networks.location
  resource_group_name = azurerm_resource_group.rg_hub_networks.name
  address_space       = [var.hub_vnet_address_space]
}


resource "azurerm_subnet" "azure_firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg_hub_networks.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes       = [var.azure_firewall_address_space]
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg_hub_networks.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes       = [var.on_prem_gateway_addess_space]
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg_hub_networks.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes       = [var.bastion_address_space]
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_public_ip" "hub_fw_pip" {
  name                = local.fw_pip_name
  location            = azurerm_resource_group.rg_hub_networks.location
  resource_group_name = azurerm_resource_group.rg_hub_networks.name
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_firewall" "azure_firewall" {
  name                = local.hub_fw_name
  location            = azurerm_resource_group.rg_hub_networks.location
  resource_group_name = azurerm_resource_group.rg_hub_networks.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  zones               = ["1", "3"]
  threat_intel_mode   = "Alert"

  ip_configuration {
    name                 = local.fw_pip_name
    subnet_id            = azurerm_subnet.azure_firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.hub_fw_pip.id
  }
}

resource "azurerm_firewall_network_rule_collection" "azure_firewall_network_rule_collection" {
  name                = "org-wide-allowed"
  azure_firewall_name = azurerm_firewall.azure_firewall.name
  resource_group_name = azurerm_resource_group.rg_hub_networks.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "dns"

    source_addresses = [
      "*",
    ]

    protocols = [
      "UDP",
    ]

    destination_ports = [
      "53",
    ]

    destination_addresses = [
      "*",
    ]

  }

  rule {
    name = "ntp"
    description = "Network Time Protocol (NTP) time synchronization"

    source_addresses = [
      "*",
    ]

    protocols = [
      "UDP",
    ]

    destination_ports = [
      "123",
    ]

    destination_addresses = [
      "*",
    ]
  }

}