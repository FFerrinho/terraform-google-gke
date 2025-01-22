module "gke_autopilot" {
  source = "github.com/USERNAME/terraform-google-gke"

  # Required variables
  project_id        = "my-project-id"
  cluster_name      = "my-autopilot-cluster"
  cluster_location  = "us-central1"  # Using regional cluster for autopilot
  network          = "default"
  cluster_subnetwork = "default"

  # Enable autopilot
  enable_autopilot = true

  # IP allocation policy for VPC-native cluster
  ip_allocation_policy = {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
    cluster_ipv4_cidr_block      = "10.100.0.0/16"
    services_ipv4_cidr_block     = "10.101.0.0/16"
    stack_type                   = "IPV4"
  }
}
