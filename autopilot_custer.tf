# Data source to get the current Google Cloud project details
data "google_project" "main" {
  project_id = var.project_id
}

# Resource to create a Google Kubernetes Engine (GKE) cluster
resource "google_container_cluster" "standard" {
  for_each                  = var.enable_autopilot == true ? { "autopilot" = "autopilot" } : {}
  name                      = var.cluster_name
  location                  = var.cluster_location
  description               = var.description
  project                   = data.google_project.main.project_id
  node_locations            = var.node_locations
  deletion_protection       = var.cluster_deletion_protection
  allow_net_admin           = var.enable_autopilot == true ? var.allow_net_admin : null
  cluster_ipv4_cidr         = var.cluster_ipv4_cidr
  enable_autopilot          = var.enable_autopilot
  enable_tpu                = var.enable_tpu
  initial_node_count        = var.node_pools != null ? var.initial_node_count : 1
  remove_default_node_pool  = var.node_pools != null ? var.remove_default_node_pool : true
  default_max_pods_per_node = var.default_max_pods_per_node
  networking_mode           = var.networking_mode
  network                   = var.network

  # Dynamic block for configuring GKE addons
  dynamic "addons_config" {
    for_each = var.addons_config != null ? var.addons_config : {}
    content {
      horizontal_pod_autoscaling {
        disabled = addons_config.value.disable_horizontal_pod_autoscaling
      }
      http_load_balancing {
        disabled = addons_config.value.disable_http_load_balancing
      }
      network_policy_config {
        disabled = addons_config.value.disable_network_policy_config
      }
      gcp_filestore_csi_driver_config {
        enabled = addons_config.value.enable_gcp_filestore_csi_driver_config
      }
      gcs_fuse_csi_driver_config {
        enabled = addons_config.value.enable_gcs_fuse_csi_driver_config
      }
      cloudrun_config {
        disabled           = addons_config.value.cloudrun_config.disabled
        load_balancer_type = addons_config.value.cloudrun_config.load_balancer_type
      }
      dns_cache_config {
        enabled = addons_config.value.dns_cache_config.enabled
      }
      gce_persistent_disk_csi_driver_config {
        enabled = addons_config.value.gce_persistent_disk_csi_driver_config.enabled
      }
      gke_backup_agent_config {
        enabled = addons_config.value.gke_backup_agent_config.enabled
      }
    }
  }

  # Dynamic block for configuring cluster autoscaling
  dynamic "cluster_autoscaling" {
    for_each = var.cluster_autoscaling != null ? var.cluster_autoscaling : {}
    content {
      enabled = var.cluster_autoscaling.enabled

      dynamic "resource_limits" {
        for_each = var.cluster_autoscaling.resource_limits != null ? var.cluster_autoscaling.resource_limits : {}
        content {
          resource_type = var.cluster_autoscaling.resource_limits.resource_type
          minimum       = var.cluster_autoscaling.resource_limits.minimum
          maximum       = var.cluster_autoscaling.resource_limits.maximum
        }
      }

      dynamic "auto_auto_provisioning_defaults" {
        for_each = var.cluster_autoscaling.auto_auto_provisioning_defaults != null ? var.cluster_autoscaling.auto_auto_provisioning_defaults : {}
        content {
          min_cpu_platform = var.cluster_autoscaling.auto_auto_provisioning_defaults.min_cpu_platform
          service_account  = var.cluster_autoscaling.auto_auto_provisioning_defaults.service_account
          disk_size        = var.cluster_autoscaling.auto_auto_provisioning_defaults.disk_size
          disk_type        = var.cluster_autoscaling.auto_auto_provisioning_defaults.disk_type
          image_type       = var.cluster_autoscaling.auto_auto_provisioning_defaults.image_type

          dynamic "management" {
            for_each = var.cluster_autoscaling.auto_auto_provisioning_defaults.management != null ? var.cluster_autoscaling.auto_auto_provisioning_defaults.management : {}
            content {
              auto_upgrade = var.cluster_autoscaling.auto_auto_provisioning_defaults.management.auto_upgrade
              auto_repair  = var.cluster_autoscaling.auto_auto_provisioning_defaults.management.auto_repair

              dynamic "upgrade_settings" {
                for_each = var.cluster_autoscaling.auto_auto_provisioning_defaults.management.upgrade_settings != null ? var.cluster_autoscaling.auto_auto_provisioning_defaults.management.upgrade_settings : {}
                content {
                  strategy        = var.cluster_autoscaling.auto_auto_provisioning_defaults.management.upgrade_settings.strategy
                  max_surge       = var.cluster_autoscaling.auto_auto_provisioning_defaults.management.upgrade_settings.max_surge
                  max_unavailable = var.cluster_autoscaling.auto_auto_provisioning_defaults.management.upgrade_settings.max_unavailable
                }
              }
            }
          }
        }
      }
    }
  }

  # Dynamic block for configuring service external IPs
  dynamic "service_external_ip_configs" {
    for_each = var.cluster_autoscaling.service_external_ip_configs != null ? var.cluster_autoscaling.service_external_ip_configs : {}
    content {
      enabled = var.cluster_autoscaling.service_external_ip_configs.enabled
    }
  }

  # Dynamic block for configuring IP allocation policy
  dynamic "ip_allocation_policy" {
    for_each = var.ip_allocation_policy != null ? var.ip_allocation_policy : {}
    content {
      cluster_secondary_range_name  = var.ip_allocation_policy.cluster_secondary_range_name
      cluster_ipv4_cidr_block       = var.ip_allocation_policy.cluster_ipv4_cidr_block
      services_secondary_range_name = var.ip_allocation_policy.services_secondary_range_name
      services_ipv4_cidr_block      = var.ip_allocation_policy.services_ipv4_cidr_block
      stack_type                    = var.ip_allocation_policy.stack_type
    }
  }

  # Dynamic block for configuring maintenance policy
  dynamic "maintenace_policy" {
    for_each = var.maintenance_policy != null ? var.maintenance_policy : {}
    content {
      dynamic "daily_maintenance_window" {
        for_each = var.maintenance_policy.daily_maintenance_window.start_time
        content {
          start_time = var.maintenance_policy.daily_maintenance_window.start_time
        }
      }

      dynamic "recurring_window" {
        for_each = var.maintenance_policy.recurring_window
        content {
          start_time = var.maintenance_policy.recurring_window.start_time
          end_time   = var.maintenance_policy.recurring_window.end_time
          recurrence = var.maintenance_policy.recurring_window.recurrence
        }
      }

      dynamic "maintenance_exclusion" {
        for_each = var.maintenance_policy.maintenance_exclusion
        content {
          exclusion_options {
            scope = var.maintenance_policy.maintenance_exclusion.exclusion_options.scope
          }
          start_time = var.maintenance_policy.maintenance_exclusion.start_time
          end_time   = var.maintenance_policy.maintenance_exclusion.end_time
        }
      }
    }
  }

  dynamic "node_pool_auto_config" {
    for_each = var.node_pool_auto_config != null ? var.node_pool_auto_config : {}
    content {
      resource_manager_tags = var.node_pool_auto_config.resource_manager_tags

      dynamic "node_kubelet_config" {
        for_each = var.node_pool_auto_config.insecure_kubelet_readonly_port_enabled != null ? var.node_pool_auto_config.insecure_kubelet_readonly_port_enabled : {}
        content {
          insecure_kubelet_readonly_port_enabled = var.node_pool_auto_config.insecure_kubelet_readonly_port_enabled
        }
      }

      dynamic "network_tags" {
        for_each = var.node_pool_auto_config.network_tags != null ? var.node_pool_auto_config.network_tags : {}
        content {
          tags = var.node_pool_auto_config.network_tags
        }
      }
    }
  }

  dynamic "node_pool_defaults" {
    for_each = var.node_pool_defaults != null ? var.node_pool_defaults : {}
    content {
      node_config_defaults {
        insecure_kubelet_readonly_port_enabled = var.node_pool_defaults.node_config_defaults.insecure_kubelet_readonly_port_enabled
        logging_variant                        = var.node_pool_defaults.node_config_defaults.logging_variant
        dynamic "gcfs_config" {
          for_each = var.node_pool_defaults.node_config_defaults.gcfs_config.enabled != null ? var.node_pool_defaults.node_config_defaults.gcfs_config.enabled : {}
          content {
            enabled = var.node_pool_defaults.node_config_defaults.gcfs_config.enabled
          }
        }
      }
    }
  }

  release_channel {
    channel = var.release_channel
  }

  dynamic "resource_labels" {
    for_each = var.resource_labels != null ? var.resource_labels : {}
    content {
      labels = var.resource_labels
    }
  }
}
