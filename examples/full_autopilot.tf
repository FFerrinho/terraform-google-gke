module "gke_autopilot" {
  source = "github.com/USERNAME/terraform-google-gke"

  project_id          = var.project_id
  cluster_name        = "autopilot-cluster"
  cluster_location    = "us-central1"  # Regional cluster
  network            = module.vpc.network_name
  cluster_subnetwork = module.vpc.subnets_names[0]

  # Enable Autopilot mode
  enable_autopilot = true

  # Network configuration
  ip_allocation_policy = {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
    cluster_ipv4_cidr_block      = null
    services_ipv4_cidr_block     = null
    stack_type                   = "IPV4"
  }

  # Security configuration
  master_authorized_networks_config = {
    cidr_blocks = [
      {
        cidr_block   = "10.0.0.0/8"
        display_name = "internal"
      }
    ]
    gcp_public_cidrs_access_enabled = false
  }

  # Maintenance configuration
  maintenance_policy = {
    recurring_window = {
      start_time = "2024-01-01T00:00:00Z"
      end_time   = "2024-01-02T00:00:00Z"
      recurrence = "FREQ=WEEKLY"
    }
  }
}
