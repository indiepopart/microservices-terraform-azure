# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "app-gwateway-beap"
  frontend_port_name             = "app-gateway-feport"
  frontend_ip_configuration_name = "app-gateway-feip"
  http_setting_name              = "app-gateway-be-htst"
  listener_name                  = "app-gateway-httplstn"
  request_routing_rule_name      = "app-gateway-rqrt"
  redirect_configuration_name    = "app-gateway-rdrcfg"
  gateway_pip_name               = "app-gateway-pip"
}


resource "azurerm_application_gateway" "gateway" {
  name                = "app-gateway"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = var.spoke_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = var.spoke_pip_id
  }

  waf_configuration {
    enabled = true
    firewall_mode = "Prevention"
    rule_set_type = "OWASP"
    rule_set_version = "3.0"
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}