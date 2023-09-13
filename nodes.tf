resource "google_container_node_pool" "main" {
  for_each = var.node_pool
  cluster  = google_container_cluster.main.name
  location = google_container_cluster.main.location

  dynamic "autoscaling" {
    for_each = each.value["autoscaling"]
    content {
      min_node_count       = autoscaling.value["min_node_count"]
      max_node_count       = autoscaling.value["max_node_count"]
      total_min_node_count = autoscaling.value["total_min_node_count"]
      total_max_node_count = autoscaling.value["total_max_node_count"]
      location_policy      = autoscaling.value["location_policy"]
    }
  }

  initial_node_count = each.value["initial_node_count"]

  dynamic "management" {
    for_each = each.value["management"]
    content {
      auto_repair  = management.value["auto_repair"]
      auto_upgrade = management.value["auto_upgrade"]
    }
  }

  max_pods_per_node = each.value["max_pods_per_node"]
  node_locations    = each.value["node_locations"]
  name              = each.value["name"]
  name_prefix       = each.value["name_prefix"]

  dynamic "node_config" {
    for_each = each.value["node_config"]
    content {
      disk_size_gb = node_config.value["disk_size_gb"]
      disk_type    = node_config.value["disk_type"]

      dynamic "ephemeral_storage_local_ssd_config" {
        for_each = toset(node_config.value["local_nvme_ssd_block_config"] ? ["1"] : [])
        content {
          local_ssd_count = node_config.value["local_nvme_ssd_block_config"]
        }
      }

      dynamic "local_nvme_ssd_block_config" {
        for_each = toset(node_config.value["local_nvme_ssd_block_config"] ? ["1"] : [])
        content {
          local_ssd_count = node_config.value["local_nvme_ssd_block_config"]
        }
      }

      logging_variant = node_config.value["logging_variant"]

      dynamic "gcfs_config" {
        for_each = toset(node_config.value["gcfs_config_enabled"] ? ["1"] : [])
        content {
          enabled = node_config.value["gcfs_config_enabled"]
        }
      }

      dynamic "gvnic" {
        for_each = toset(node_config.value["gvnic_enabled"] ? ["1"] : [])
        content {
          enabled = node_config.value["gvnic_enabled"]
        }
      }

      image_type       = node_config.value["image_type"]
      labels           = node_config.value["labels"]
      resource_labels  = node_config.value["resource_labels"]
      local_ssd_count  = node_config.value["local_ssd_count"]
      machine_type     = node_config.value["machine_type"]
      metadata         = node_config.value["metadata"]
      min_cpu_platform = node_config.value["min_cpu_platform"]

      oauth_scopes = node_config.value["oauth_scopes"] != null ? node_config.value["oauth_scopes"] : [
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/trace.append"
      ]

      preemptible = node_config.value["preemptible"]

      dynamic "reservation_affinity" {
        for_each = node_config.value["reservation_affinity"]
        content {
          consume_reservation_type = reservation_affinity.value["consume_reservation_type"]
          key                      = reservation_affinity.value["key"]
          values                   = reservation_affinity.value["values"]
        }
      }

      spot            = node_config.value["spot"]
      service_account = node_config.value["service_account"]

      dynamic "shielded_instance_config" {
        for_each = node_config.value["shielded_instance_config"]
        content {
          enable_secure_boot          = shielded_instance_config.value["enable_secure_boot"]
          enable_integrity_monitoring = shielded_instance_config.value["enable_integrity_monitoring"]
        }
      }

      tags = node_config.value["tags"]

      dynamic "taint" {
        for_each = node_config.value["taint"]
        content {
          key    = taint.value["key"]
          value  = taint.value["value"]
          effect = taint.value["effect"]
        }
      }

      dynamic "workload_metadata_config" {
        for_each = toset(node_config.value["workload_metadata_config_mode"] == "GKE_METADATA" && google_container_cluster.main.workload_identity_config != null ? ["1"] : [])
        content {
          mode = node_config.value["workload_metadata_config_mode"]
        }
      }

      dynamic "kubelet_config" {
        for_each = node_config.value["kubelet_config"]
        content {
          cpu_manager_policy   = kubelet_config.value["cpu_manager_policy"]
          cpu_cfs_quota        = kubelet_config.value["cpu_cfs_quota"]
          cpu_cfs_quota_period = kubelet_config.value["cpu_cfs_quota_period"]
          pod_pids_limit       = kubelet_config.value["pod_pids_limit"]
        }
      }

      dynamic "linux_node_config" {
        for_each = node_config.value["linux_node_config_sysctls"]
        content {
          sysctls = node_config.value["linux_node_config_sysctls"]
        }
      }

      node_group = node_config.value["node_group"]

      dynamic "sole_tenant_config" {
        for_each = node_config.value["sole_tenant_config"]
        content {
          dynamic "node_affinity" {
            for_each = sole_tenant_config.value["node_affinity"]
            content {
              key      = node_affinity.value["key"]
              operator = node_affinity.value["operator"]
              values   = node_affinity.value["values"]
            }
          }
        }
      }

      dynamic "advanced_machine_features" {
        for_each = toset(node_config.value["advanced_machine_features_threads_per_core"] ? ["1"] : [])
        content {
          threads_per_core = node_config.value["advanced_machine_features_threads_per_core"]
        }
      }
    }
  }

  dynamic "network_config" {
    for_each = each.value["network_config"]
    content {
      create_pod_range     = network_config.value["create_pod_range"]
      enable_private_nodes = network_config.value["enable_private_nodes"]
      pod_ipv4_cidr_block  = network_config.value["pod_ipv4_cidr_block"]
      pod_range            = network_config.value["pod_range"]
    }
  }

  node_count = each.value["node_count"]
  project    = var.project

  dynamic "upgrade_settings" {
    for_each = each.value["upgrade_settings"]
    content {
      max_surge       = upgrade_settings.value["max_surge"]
      max_unavailable = upgrade_settings.value["max_unavailable"]
      strategy        = upgrade_settings.value["strategy"]
      dynamic "blue_green_settings" {
        for_each = upgrade_settings.value["blue_green_settings"]
        content {
          dynamic "standard_rollout_policy" {
            for_each = blue_green_settings.value["standard_rollout_policy"]
            content {
              batch_percentage    = standard_rollout_policy.value["batch_percentage"]
              batch_node_count    = standard_rollout_policy.value["batch_node_count"]
              batch_soak_duration = standard_rollout_policy.value["batch_soak_duration"]
            }
          }
          node_pool_soak_duration = blue_green_settings.value["node_pool_soak_duration"]
        }
      }
    }
  }

  version = each.value["version"]

  dynamic "placement_policy" {
    for_each = each.value["placement_policy"]
    content {
      type        = placement_policy.value["type"]
      policy_name = placement_policy.value["policy_name"]
    }
  }

  lifecycle {
    ignore_changes = [
      initial_node_count
    ]

    # Ensure that if reservation_affinity.consume_reservation_type is set to SPECIFIC_RESERVATION, the reservation_affinity.key is not null
    precondition {
      condition     = var.node_pool[each.key].node_config["reservation_affinity"]["consume_reservation_type"] == "SPECIFIC_RESERVATION" && var.node_pool[each.key].node_config["reservation_affinity"]["key"] != null
      error_message = "If reservation_affinity.consume_reservation_type is set to SPECIFIC_RESERVATION, the reservation_affinity.key must not be null."
    }

    # Ensure that if workload_metadata_config_mode is set to GKE_METADATA, google_container_cluster.main.workload_identity_config isn't null
    precondition {
      condition     = var.node_pool[each.key].node_config["workload_metadata_config_mode"] == "GKE_METADATA" && google_container_cluster.main.workload_identity_config != null
      error_message = "If workload_metadata_config_mode is set to GKE_METADATA, google_container_cluster.main.workload_identity_config must not be null."
    }
  }
}
