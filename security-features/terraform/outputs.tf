output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "image_cleaner_enabled" {
  value = azurerm_kubernetes_cluster.k8s.image_cleaner_enabled
}

output "image_cleaner_interval_hours" {
  value = azurerm_kubernetes_cluster.k8s.image_cleaner_interval_hours
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}
