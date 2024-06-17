variable "resource_group_location" {

}

variable "hub_fw_private_ip" {

}

variable "application_id" {

}

variable "spoke_vnet_address_space" {
  description = "The address space for the spoke virtual network."
  default = "10.240.0.0/16"
}


variable "cluster_nodes_address_space" {
  description = "The address space for the cluster nodes."
  default = "10.240.0.0/22"
}

variable "ingress_services_address_space" {
  description = "The address space for the ingress services."
  default = "10.240.4.0/28"
}

variable "application_gateways_address_space" {
  description = "The address space for the application gateways."
  default = "10.240.4.16/28"
}

