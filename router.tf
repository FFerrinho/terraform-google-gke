# Google router and NAT configuration for cases where the GKE cluster needs access to Google APIs to register nodes, etc. since these are usually via a Google's 'public' IP and the 'usual' GKE deployment doesn't allow access to public IPs.check 

resource "google_compute_router" "gke" {
  name        = var.router_name
  network     = data.google_compute_network.main.name
  description = "A router to connect the GKE autopilot cluster to the internet."
  region      = substr(var.location, 0, length(var.location) - 2)
  project     = data.google_project.main.id
}

resource "google_compute_router_nat" "gke" {
  name                               = "${var.router_name}-nat}"
  router                             = google_compute_router.gke.name
  region                             = substr(var.location, 0, length(var.location) - 2)
  project                            = data.google_project.main.id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = data.google_compute_subnetwork.gke.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
