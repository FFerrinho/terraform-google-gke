resource "google_container_cluster" "main" {
  name                      = var.cluster_name
  location                  = var.cluster_location
  node_locations            = var.cluster_node_locations
  cluster_ipv4_cidr         = var.cluster_ipv4_cidr
  description               = var.cluster_description
  default_max_pods_per_node = var.default_max_pods_per_node
  enable_kubernetes_alpha   = var.enable_kubernetes_alpha
  enable_shielded_nodes     = var.enable_shielded_nodes
  enable_autopilot          = var.enable_autopilot
  initial_node_count        = var.initial_node_count
  networking_mode           = var.networking_mode
  logging_service           = var.logging_service
  min_master_version        = var.min_master_version
  monitoring_service        = var.monitoring_service
  network                   = var.network
  project                   = var.project_id
  remove_default_node_pool  = var.remove_default_node_pool
  resource_labels           = var.resource_labels
  subnetwork                = var.subnetwork

  dynamic "addons_config" {
    for_each = var.cluster_addons_config
    content {
      horizontal_pod_autoscaling {
        disabled = addons_config.value["horizontal_pod_autoscaling_disabled"]
      }
      http_load_balancing {
        disabled = addons_config.value["http_load_balancing_disabled"]
      }
      kubernetes_dashboard {
        disabled = addons_config.value["kubernetes_dashboard_disabled"]
      }
      network_policy_config {
        disabled = addons_config.value["network_policy_config_disabled"]
      }
    }
  }

  dynamic "cluster_autoscaling" {
    for_each = var.cluster_autoscaling
    content {
      enabled = cluster_autoscaling.value["enabled"]
      dynamic "resource_limits" {
        for_each = cluster_autoscaling.value["resource_limits"]
        content {
          resource_type = resource_limits.value["resource_type"]
          minimum       = resource_limits.value["minimum"]
          maximum       = resource_limits.value["maximum"]
        }
      }
      dynamic "auto_provisioning_defaults" {
        for_each = cluster_autoscaling.value["auto_provisioning_defaults"]
        content {
          min_cpu_platform = auto_provisioning_defaults.value["min_cpu_platform"]
          oauth_scopes     = auto_provisioning_defaults.value["oauth_scopes"]
        }
      }
    }
  }

  dynamic "binary_authorization" {
    for_each = var.cluster_binary_authorization
    content {
      evaluation_mode = binary_authorization.value["evaluation_mode"]
    }
  }

  dynamic "service_external_ips_config" {
    for_each = var.cluster_service_external_ips_config
    content {
      enabled = service_external_ips_config.value["enabled"]
    }
  }

  dynamic "ip_allocation_policy" {
    for_each = var.cluster_ip_allocation_policy
    content {
      cluster_secondary_range_name  = ip_allocation_policy.value["cluster_secondary_range_name"]
      services_secondary_range_name = ip_allocation_policy.value["services_secondary_range_name"]
      cluster_ipv4_cidr_block       = ip_allocation_policy.value["cluster_ipv4_cidr_block"]
      services_ipv4_cidr_block      = ip_allocation_policy.value["services_ipv4_cidr_block"]
      stack_type                    = ip_allocation_policy.value["stack_type"]
    }
  }

  dynamic "logging_config" {
    for_each = var.cluster_logging_config
    content {
      enable_components = logging_config.value["enable_components"]
    }
  }

  dynamic "maintenance_policy" {
    for_each = var.cluster_maintenance_policy
    content {
      dynamic "daily_maintenance_window" {
        for_each = maintenance_policy.value["daily_maintenance_window"]
        content {
          start_time = daily_maintenance_window.value["start_time"]
        }
      }
      dynamic "recurring_window" {
        for_each = maintenance_policy.value["recurring_window"]
        content {
          start_time = recurring_window.value["start_time"]
          end_time   = recurring_window.value["end_time"]
          recurrence = recurring_window.value["recurrence"]
        }
      }
      dynamic "maintenance_exclusion" {
        for_each = maintenance_policy.value["maintenance_exclusion"]
        content {
          exclusion_name = maintenance_exclusion.value["exclusion_name"]
          start_time     = maintenance_exclusion.value["start_time"]
          end_time       = maintenance_exclusion.value["end_time"]
          dynamic "exclusion_options" {
            for_each = maintenance_exclusion.value["exclusion_options"]
            content {
              scope = exclusion_options.value["scope"]
            }
          }
        }
      }
    }
  }

  dynamic "master_auth" {
    for_each = var.cluster_master_auth
    content {
      dynamic "client_certificate_config" {
        for_each = master_auth.value["client_certificate_config"]
        content {
          issue_client_certificate = client_certificate_config.value["issue_client_certificate"]
        }
      }

      dynamic "master_authorized_networks_config" {
        for_each = master_auth.value["master_authorized_networks_config"]
        content {
          cidr_blocks {
            dynamic "cidr_blocks" {
              for_each = master_authorized_networks_config.value["cidr_blocks"]
              content {
                display_name = cidr_block.value["display_name"]
                cidr_block   = cidr_block.value["cidr_block"]
              }
            }
            gcp_public_cidrs_access_enabled = master_authorized_networks_config.value["gcp_public_cidrs_access_enabled"]
          }
        }
      }
    }
  }

  dynamic "monitoring_config" {
    for_each = var.cluster_monitoring_config
    content {
      enable_components = monitoring_config.value["enable_components"]
      dynamic "managed_prometheus" {
        for_each = monitoring_config.value["managed_prometheus"]
        content {
          enabled = managed_prometheus.value["enabled"]
        }
      }
    }
  }

  dynamic "network_policy" {
    for_each = var.cluster_network_policy
    content {
      enabled  = network_policy.value["enabled"]
      provider = network_policy.value["provider"]
    }
  }

  dynamic "node_config" {
    for_each = var.node_config
    content {
      disk_size_gb     = node_config.value["disk_size_gb"]
      disk_type        = node_config.value["disk_type"]
      image_type       = node_config.value["image_type"]
      labels           = node_config.value["labels"]
      resource_labels  = node_config.value["resource_labels"]
      local_ssd_count  = node_config.value["local_ssd_count"]
      machine_type     = node_config.value["machine_type"]
      metadata         = node_config.value["metadata"]
      min_cpu_platform = node_config.value["min_cpu_platform"]
      oath_scopes      = node_config.value["oath_scopes"]
      preemptible      = node_config.value["preemptible"]
      spot             = node_config.value["spot"]
      service_account  = node_config.value["service_account"]
      tags             = node_config.value["tags"]
      node_group       = node_config.value["node_group"]
      logging_variant  = node_config.value["logging_variant"]

      dynamic "ephemeral_storage_config" {
        for_each = node_config.value["ephemeral_storage_config"]
        content {
          local_ssd_count = ephemeral_storage_config.value["local_ssd_count"]
        }
      }

      dynamic "ephemeral_storage_local_ssd_config" {
        for_each = node_config.value["ephemeral_storage_local_ssd_config"]
        content {
          local_ssd_count = ephemeral_storage_local_ssd_config.value["local_ssd_count"]
        }
      }

      dynamic "local_nvme_ssd_block_config" {
        for_each = node_config.value["local_nvme_ssd_block_config"]
        content {
          local_ssd_count = local_nvme_ssd_block_config.value["local_ssd_count"]
        }
      }

      dynamic "gcfs_config" {
        for_each = node_config.value["gcfs_config"]
        content {
          enabled = gcfs_config.value["enabled"]
        }
      }

      dynamic "gvnic" {
        for_each = node_config.value["gvnic"]
        content {
          enabled = gvnic.value["enabled"]
        }
      }

      dynamic "guest_guest_accelerator" {
        for_each = node_config.value["guest_accelerator"]
        content {
          type               = guest_accelerator.value["type"]
          count              = guest_accelerator.value["count"]
          gpu_partition_size = guest_accelerator.value["gpu_partition_size"]
          dynamic "gpu_sharing_config" {
            for_each = guest_accelerator.value["gpu_sharing_config"]
            content {
              gpu_sharing_strategy       = gpu_sharing_config.value["gpu_sharing_strategy"]
              max_shared_clients_per_gpu = gpu_sharing_config.value["max_shared_clients_per_gpu"]
            }
          }
        }
      }

      dynamic "reservation_affinity" {
        for_each = node_config.value["reservation_affinity"]
        content {
          consume_reservation_type = reservation_affinity.value["consume_reservation_type"]
          key                      = reservation_affinity.value["key"]
          values                   = reservation_affinity.value["values"]
        }
      }

      dynamic "sandbox_config" {
        for_each = node_config.value["sandbox_config"]
        content {
          sandbox_type = sandbox_config.value["sandbox_type"]
        }
      }

      dynamic "workload_metadata_config" {
        for_each = node_config.value["workload_metadata_config"]
        content {
          mode = workload_metadata_config.value["mode"]
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
        for_each = node_config.value["linux_node_config"]
        content {
          sysctls = linux_node_config.value["sysctls"]
        }
      }

      dynamic "advanced_machine_features" {
        for_each = node_config.value["advanced_machine_features"]
        content {
          threads_per_core = advanced_machine_features.value["threads_per_core"]
        }
      }
    }
  }

  dynamic "node_pool" {
    for_each = var.node_pool
    content {
      name               = node_pool.value["name"]
      location           = node_pool.value["location"]
      initial_node_count = node_pool.value["initial_node_count"]

      dynamic "autoscaling" {
        for_each = node_pool.value["autoscaling"]
        content {
          min_node_count       = autoscaling.value["min_node_count"]
          max_node_count       = autoscaling.value["max_node_count"]
          total_min_node_count = autoscaling.value["total_min_node_count"]
          total_max_node_count = autoscaling.value["total_max_node_count"]
          location_policy      = autoscaling.value["location_policy"]
        }
      }

      dynamic "management" {
        for_each = node_pool.value["management"]
        content {
          auto_upgrade              = management.value["auto_upgrade"]
          auto_repair               = management.value["auto_repair"]
      }
    }
  }

  dynamic "node_pool_auto_config" {
    for_each = var.node_pool_auto_config
    content {
      dynamic "network_tags" {
        for_each = node_pool_auto_config.value["network_tags"]
        content {
          tag = network_tags.value["tag"]
        }
      }
    }
  }

  dynamic "private_cluster_config" {
    for_each = var.private_cluster_config
    content {
      enable_private_endpoint = private_cluster_config.value["enable_private_endpoint"]
      enable_private_nodes    = private_cluster_config.value["enable_private_nodes"]
      master_ipv4_cidr_block  = private_cluster_config.value["master_ipv4_cidr_block"]
      dynamic "master_global_access_config" {
        for_each = private_cluster_config.value["master_global_access_config"]
        content {
          enabled = master_global_access_config.value["enabled"]
        }
      }
    }
  }

  dynamic "release_channel" {
    for_each = var.release_channel
    content {
      channel = release_channel.value["channel"]
    }
  }

  dynamic "vertical_pod_autoscaling" {
    for_each = var.vertical_pod_autoscaling
    content {
      enabled = vertical_pod_autoscaling.value["enabled"]
    }
  }

  dynamic "workload_identity_config" {
    for_each = var.workload_identity_config
    content {
      workload_pool = workload_identity_config.value["workload_pool"]
    }
  }

  dynamic "dns_config" {
    for_each = var.dns_config
    content {
      cluster_dns        = dns_config.value["cluster_dns"]
      cluster_dns_scope  = dns_config.value["cluster_dns_scope"]
      cluster_dns_domain = dns_config.value["cluster_dns_domain"]
    }
  }

  dynamic "project_config" {
    for_each = var.project_config
    content {
      workload_vulnerability_mode = project_config.value["workload_vulnerability_mode"]

      dynamic "workload_config" {
        for_each = project_config.value["workload_config"]
        content {
          audit_mode = workload_config.value["audit_mode"]
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition        = var.node_pool == null && var.initial_node_count != null && var.initial_node_count > 0 && var.remove_default_node_pool == true
      error_message    = "If no node_pool is specified, initial_node_count must be set to a value greater than 0 and remove_default_node_pool must be set to true."
      abort_on_failure = true
    }

    precondition {
      condition        = var.networking_mode == "VPC_NATIVE" && var.ip_allocation_policy == null
      error_message    = "If networking_mode is set to VPC_NATIVE, ip_allocation_policy must be set."
      abort_on_failure = true
    }

    precondition {
      condition = var.gcfs_config == null || (
        var.gcfs_config.image_type == "COS_CONTAINERD" &&
        (
          starts_with(var.gcfs_config.node_version, "1.19.") ||
          starts_with(var.gcfs_config.node_version, "1.20.") ||
          starts_with(var.gcfs_config.node_version, "1.21.")
        ) &&
        (
          starts_with(var.gcfs_config.node_version, "1.19.15-gke") ||
          starts_with(var.gcfs_config.node_version, "1.20.11-gke") ||
          starts_with(var.gcfs_config.node_version, "1.21.5-gke")
        )
      )
      error_message    = "Invalid gcfs_config parameters. Please ensure image_type is set to 'COS_CONTAINERD' and node_version matches the recommended versions."
      abort_on_failure = true
    }

    precondition {
      condition     = can(var.enable_sandbox_config) && var.enable_sandbox_config == true && var.image_type == "COS_CONTAINERD" && var.node_version >= "1.12.7-gke.17"
      error_message = "When enabling GKE Sandbox configuration, image_type must be 'COS_CONTAINERD' and node_version must be '1.12.7-gke.17' or later."
    }
  }
}
