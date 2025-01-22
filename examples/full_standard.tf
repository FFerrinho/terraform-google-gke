module "gke_standard" {
  source = "github.com/USERNAME/terraform-google-gke"

  project_id          = var.project_id
  cluster_name        = "standard-cluster"
  cluster_location    = "us-central1-a"
  network            = module.vpc.network_name
  cluster_subnetwork = module.vpc.subnets_names[0]

  # Network configuration
  ip_allocation_policy = {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
    cluster_ipv4_cidr_block      = null
    services_ipv4_cidr_block     = null
    stack_type                   = "IPV4"
  }

  # Node pool configuration
  node_pool = {
    main = {
      initial_node_count = 1
      node_locations     = ["us-central1-a"]
      node_pool_name     = "main-pool"
    }
  }

  node_config = {
    machine_type        = "e2-medium"
    disk_size_gb        = 100
    disk_type           = "pd-standard"
    image_type          = "COS_CONTAINERD"
    spot_enabled        = false
    gcfs_config_enabled = false
    gvnic_enabled       = true
    preemptible_enabled = false
    service_account     = null
    tags               = ["gke-node"]
  }

  # Additional features
  network_policy = {
    enabled  = true
    provider = "CALICO"
  }

  maintenance_policy = {
    recurring_window = {
      start_time = "2024-01-01T00:00:00Z"
      end_time   = "2024-01-02T00:00:00Z"
      recurrence = "FREQ=WEEKLY"
    }
  }
}
