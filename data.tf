data "google_project" "main" {
  project_id = var.project
}

data "google_compute_network" "main" {
  name    = var.network
  project = var.project
}

data "google_compute_subnetwork" "gke" {
  name    = var.subnetwork
  project = data.google_project.main.id
}
