output "id" {
  description = "The IF for the GKE cluster."
  value       = google_container_cluster.main.id
}

output "self_link" {
  description = "The self link for the GKE cluster."
  value       = google_container_cluster.main.self_link
}

output "endpoint" {
  description = "The endpoint for the GKE cluster."
  value       = google_container_cluster.main.endpoint
}

output "master_version" {
  description = "The master version for the GKE cluster."
  value       = google_container_cluster.main.master_version
}

output "services_ipv4_cidr" {
  description = "The services IPv4 CIDR for the GKE cluster."
  value       = google_container_cluster.main.services_ipv4_cidr

}
