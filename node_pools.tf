data "google_compute_zones" "main" {
  project = data.google_project.main.project_id
  region  = length(regexall("^[a-z]+-[a-z]+[0-9]-[a-z]$", var.cluster_location)) > 0 ? substr(var.cluster_location, 0, length(var.cluster_location) - 2) : var.cluster_location
  status  = "UP"
}

resource "google_container_node_pool" "main" {
  cluster            = google_container_cluster.main.name
  location           = var.cluster_location
  initial_node_count = var.initial_node_count
  max_pods_per_node  = var.max_pods_per_node
  node_locations     = var.node_locations
  name               = var.node_pool_name
  name_prefix        = var.node_pool_name != null ? var.node_pool_name_prefix : null

  dynamic "autoscaling" {
    for_each = var.node_pool_autoscaling != null ? [var.node_pool_autoscaling] : []
    content {
      min_node_count       = node_pool_autoscaling.value.min_node_count >= 1 ? node_pool_autoscaling.value.min_node_count : 1
      max_node_count       = node_pool_autoscaling.value.max_node_count
      total_min_node_count = node_pool_autoscaling.value.total_min_node_count
      total_max_node_count = node_pool_autoscaling.value.total_max_node_count
      location_policy      = node_pool_autoscaling.value.location_policy
    }
  }

  management {
    auto_repair  = var.node_pool_auto_repair_enabled
    auto_upgrade = var.node_pool_auto_upgrade_enabled
  }

  dynamic "node_config" {
    for_each = var.node_config != null ? [var.node_config] : []
    content {
      disk_size_gb    = node_config.value.disk_size_gb
      disk_type       = node_config.value.disk_type
      image_type      = node_config.value.image_type
      machine_type    = node_config.value.machine_type
      preemptible     = node_config.value.preemptible_enabled
      spot            = node_config.value.spot_enabled
      service_account = node_config.value.service_account
      tags            = node_config.value.tags

      gcfs_config {
        enabled = node_config.value.gcfs_config_enabled
      }

      gvnic {
        enabled = node_config.value.gvnic_enabled
      }

      dynamic "taint" {
        for_each = node_config.value.tags != null ? node_config.value.tags : []
        content {
          key    = taint.value.key
          value  = taint.value.value
          effect = taint.value.effect
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.node_pool_autoscaling == null ? true : var.node_pool_autoscaling.max_node_count >= var.node_pool_autoscaling.min_node_count
      error_message = "node_pool_autoscaling.max_node_count must be greater than or equal to node_pool_autoscaling.min_node_count"
    }
    precondition {
      condition     = var.node_pool_autoscaling == null ? true : var.node_pool_autoscaling.total_max_node_count >= var.node_pool_autoscaling.total_min_node_count
      error_message = "node_pool_autoscaling.total_max_node_count must be greater than or equal to node_pool_autoscaling.total_min_node_count"
    }
    precondition {
      condition     = var.node_pool_autoscaling == null ? true : (var.node_pool_autoscaling.total_min_node_count >= 0 && var.node_pool_autoscaling.total_min_node_count <= var.node_pool_autoscaling.total_max_node_count)
      error_message = "node_pool_autoscaling.total_min_node_count must be greater than or equal to 0 and less than or equal to total_max_node_count"
    }
    precondition {
      condition     = length(regexall("^[a-z]+-[a-z]+[0-9]-[a-z]$", var.cluster_location)) > 0 ? var.node_locations == null || length(setsubtract(var.node_locations, [var.cluster_location])) == 0 : var.node_locations == null || length(setsubtract(var.node_locations, [for zone in data.google_compute_zones.main.names : zone if startswith(zone, substr(var.cluster_location, 0, length(var.cluster_location)))])) == 0
      error_message = "node_locations must be within the cluster_location zone/region"
    }
  }
}
