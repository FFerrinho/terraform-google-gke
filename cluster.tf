data "google_project" "main" {
  project_id = var.project_id
}

resource "google_container_cluster" "main" {
  name                = var.name
  location            = var.location
  description = var.description
  project = data.google_project.main.project_id
  node_locations      = var.node_locations
  deletion_protection = var.deletion_protection
  allow_net_admin = var.allow_net_admin
  cluster_ipv4_cidr = var.cluster_ipv4_cidr
  enable_autopilot = var.enable_autopilot
  enable_tpu = var.enable_tpu
  initial_node_count = var.node_pool != null ? var.initial_node_count : 1
  remove_default_node_pool = var.node_pool != null ? var.remove_default_node_pool : true

  dynamic "addons_config" {
    for_each = var.addons_config != null ? var.addons_config : {}
    content {
      horizontal_pod_autoscaling {
        disabled = addons_config.value.horizontal_pod_autoscaling
      }
      http_load_balancing {
        disabled = addons_config.value.http_load_balancing
      }
      network_policy_config {
        disabled = addons_config.value.network_policy_config
      }
      gcp_filestore_csi_driver_config {
        enabled = addons_config.value.gcp_filestore_csi_driver_config
      }
      gcs_fuse_csi_driver_config {
        enabled = addons_config.value.gcs_fuse_csi_driver_config
      }
      cloudrun_config {
        disabled = addons_config.value.cloudrun_config.disabled
        load_balancer_type = addons_config.value.cloudrun_config.load_balancer_type
      }
    }
  }

  dynamic "database_encryption" {
    for_each = var.database_encryption != null ? var.database_encryption : {}
    content {
      state    = database_encryption.value.state
      key_name = database_encryption.value.key_name
    }
  }
}
