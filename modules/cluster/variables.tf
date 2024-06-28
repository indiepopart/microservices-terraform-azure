variable "resource_group_location" {
  description = "The location of the resource group"
}

variable "resource_group_name" {
  description = "The name of the resource group"
}

variable "resource_group_id" {
  description = "The id of the resource group"
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}


variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 3
}


variable "acr_id" {

}

variable "vnet_subnet_id" {

}

/**
variable "application_gateway_id" {

}
**/

variable "vm_size" {
  type        = string
  description = "The size of the Virtual Machine."
  default     = "Standard_B2s_v2"
}