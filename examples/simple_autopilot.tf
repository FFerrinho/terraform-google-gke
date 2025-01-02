data "google_compute_subnetwork" "compute" {
  self_link = module.vpc.subnetwork_self_links[0]
}

module "gke" {
  source = "git::git@github.com:FFerrinho/terraform-google-gke.git?ref=1.0"

  cluster_name               = "cluster-fferrinho-autopilot"
  cluster_location           = var.region
  project_id                 = "celfocus-gcp-ccoe-cfmsem-9923"
  enable_autopilot           = true
  network                    = module.vpc.vpc_name
  cluster_subnetwork         = data.google_compute_subnetwork.compute.self_link
  kubernetes_release_channel = "STABLE"

  ip_allocation_policy = {
    cluster_ipv4_cidr_block       = data.google_compute_subnetwork.compute.secondary_ip_range[0].ip_cidr_range
    cluster_secondary_range_name  = data.google_compute_subnetwork.compute.secondary_ip_range[0].range_name
    services_ipv4_cidr_block      = data.google_compute_subnetwork.compute.secondary_ip_range[1].ip_cidr_range
    services_secondary_range_name = data.google_compute_subnetwork.compute.secondary_ip_range[1].range_name
    stack_type                    = "IPV4"
  }
}
