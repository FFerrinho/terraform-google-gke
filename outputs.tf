locals {
  show_preemptible_warning = var.node_config != null && var.node_config.preemptible_enabled == true
}

output "deprecation_warnings" {
  value = local.show_preemptible_warning ? {
    preemptible = "⚠️ Warning: Preemptible VMs are being deprecated by Google. Please consider using Spot VMs instead by setting spot_enabled = true"
  } : null
}

output "cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = google_container_cluster.main.name
}

output "cluster_endpoint" {
  description = "The endpoint of the Kubernetes cluster"
  value       = google_container_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  description = "The CA certificate of the Kubernetes cluster"
  value       = base64decode(google_container_cluster.main.master_auth.0.cluster_ca_certificate)
}

output "client_certificate" {
  description = "The client certificate used to authenticate to the Kubernetes cluster"
  value       = google_container_cluster.main.master_auth.0.client_certificate
}

output "client_key" {
  description = "The client key used to authenticate to the Kubernetes cluster"
  value       = google_container_cluster.main.master_auth.0.client_key
}

output "node_pools" {
  description = "The list of node pools in the Kubernetes cluster"
  value       = google_container_cluster.main.node_pool
}

output "cluster_ipv4_cidr" {
  description = "The IP address range of the Kubernetes pods"
  value       = google_container_cluster.main.cluster_ipv4_cidr
}

output "services_ipv4_cidr" {
  description = "The IP address range of the Kubernetes services"
  value       = google_container_cluster.main.services_ipv4_cidr
}
