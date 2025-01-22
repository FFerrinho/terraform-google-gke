module "gke" {
  source = "github.com/USERNAME/terraform-google-gke"

  # Required variables
  project_id = "my-project-id"
  cluster_name = "my-gke-cluster"
  cluster_location = "us-central1-a"
  network = "default"
  cluster_subnetwork = "default"

  # IP allocation policy for VPC-native cluster
  ip_allocation_policy = {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
    cluster_ipv4_cidr_block      = "10.100.0.0/16"
    services_ipv4_cidr_block     = "10.101.0.0/16"
    stack_type                   = "IPV4"
  }

  # Basic node pool configuration
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
    tags                = ["gke-node"]
  }
}
