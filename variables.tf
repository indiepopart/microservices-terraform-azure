variable "resource_group_location" {
  description = "The location of the resource group"
  default     = "westus2"
}


variable "acr_name" {
  description = "The name of the Azure Container Registry."
  default     = "jhipsteracr"
}


variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}


variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 2
}
