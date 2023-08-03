# Generate random resource group name
resource "random_pet" "rg_name" {
  prefix = "ic-rg"
}

resource "azurerm_resource_group" "rg" {
  location = "eastus"
  name     = random_pet.rg_name.id
}

resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "ic"
}

resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
  prefix = "dns"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  name                = random_pet.azurerm_kubernetes_cluster_name.id
  dns_prefix          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = 2
  }

  image_cleaner_enabled = true
  image_cleaner_interval_hours = 24
}
