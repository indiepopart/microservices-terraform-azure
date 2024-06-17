resource "random_pet" "ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = random_pet.ssh_key_name.id
  location  = var.resource_group_location
  parent_id = var.resource_group_id
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}


resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "cluster"
}

resource "azurerm_user_assigned_identity" "cluster_control_plane_identity" {
  location            = var.resource_group_location
  name                = "mi-${random_pet.azurerm_kubernetes_cluster_name.id}-controlplane"
  resource_group_name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = var.resource_group_location
  name                = random_pet.azurerm_kubernetes_cluster_name.id
  resource_group_name = var.resource_group_name
  dns_prefix          = random_pet.azurerm_kubernetes_cluster_name.id
  oidc_issuer_enabled = true
  workload_identity_enabled = true
  node_resource_group = "rg-${random_pet.azurerm_kubernetes_cluster_name.id}-nodepools"

  tags = {
    displayName = "Kubernetes Cluster"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.cluster_control_plane_identity.id
    ]
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_B2s_v2"
    node_count = var.node_count
    zones = ["1","3"]
    type = "VirtualMachineScaleSets"
    vnet_subnet_id = var.vnet_subnet_id
  }
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    outbound_type = "loadBalancer"
    pod_cidr = "10.244.0.0/16"
    service_cidr = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
  }
}


resource "azurerm_role_assignment" "cluster_identity_acrpull_role_assignment" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}


resource "azurerm_role_assignment" "cluster_nodepool_role_assignment" {
  scope                = azurerm_kubernetes_cluster.k8s.node_resource_group_id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
}
