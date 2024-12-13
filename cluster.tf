data "google_project" "main" {
  project_id = var.project_id
}

resource "google_container_cluster" "main" {
  name                = var.cluster_name
  location            = var.node_locations != null ? null : var.cluster_location
  node_locations      = var.node_locations
  deletion_protection = var.enable_cluster_deletion_protection
  allow_net_admin     = var.enable_autopilot == true ? true : var.allow_net_admin
  description         = var.cluster_description
  enable_autopilot    = var.enable_autopilot
  initial_node_count  = var.initial_node_count
  networking_mode     = var.networking_mode
  min_master_version  = var.min_master_version
  network             = var.network
  node_version        = var.min_master_version # Mandatory to be equal to the min_master_version, either set or unset

  addons_config {
    horizontal_pod_autoscaling {
      disabled = var.addons_config.disable_horizontal_pod_autoscaling
    }
    http_load_balancing {
      disabled = var.addons_config.disable_http_load_balancing
    }
    network_policy_config {
      disabled = var.addons_config.disable_network_policy_config
    }
    gcp_filestore_csi_driver_config {
      enabled = var.addons_config.enable_gcp_filestore_csi_driver
    }
    gcs_fuse_csi_driver_config {
      enabled = var.addons_config.enable_gcs_fuse_csi_driver
    }

    dynamic "cloudrun_config" {
      for_each = var.addons_config.cloudrun_config != null ? [var.addons_config.cloudrun_config] : []
      content {
        disabled           = cloudrun_config.value.disable_cloudrun_config
        load_balancer_type = cloudrun_config.value.load_balancer_type
      }
    }
  }

  dynamic "cluster_autoscaling" {
    for_each = var.cluster_autoscaling.enable_cluster_autoscaling ? [var.cluster_autoscaling] : []
    content {
      enabled = cluster_autoscaling.value.enable_cluster_autoscaling

      dynamic "resource_limits" {
        for_each = cluster_autoscaling.value.resource_limits != null ? cluster_autoscaling.value.resource_limits : []
        content {
          resource_type = resource_limits.value.resource_type
          minimum       = resource_limits.value.minimum
          maximum       = resource_limits.value.maximum
        }
      }

      dynamic "auto_provisioning_defaults" {
        for_each = cluster_autoscaling.value.auto_auto_provisioning_defaults != null ? [cluster_autoscaling.value.auto_auto_provisioning_defaults] : []
        content {
          service_account = auto_provisioning_defaults.value.service_account
          disk_size       = auto_provisioning_defaults.value.disk_size_gb
          disk_type       = auto_provisioning_defaults.value.disk_type
          image_type      = auto_provisioning_defaults.value.image_type

          dynamic "management" {
            for_each = auto_provisioning_defaults.value.management != null ? [auto_provisioning_defaults.value.management] : []
            content {
              auto_upgrade = management.value.auto_upgrade
              auto_repair  = management.value.auto_repair
            }
          }

          dynamic "upgrade_settings" {
            for_each = auto_provisioning_defaults.value.upgrade_settings != null ? [auto_provisioning_defaults.value.upgrade_settings] : []
            content {
              strategy        = upgrade_settings.value.strategy
              max_surge       = upgrade_settings.value.max_surge
              max_unavailable = upgrade_settings.value.max_unavailable
            }
          }
        }
      }
    }
  }

  dynamic "service_external_ips_config" {
    for_each = var.service_external_ips_config != null ? [var.service_external_ips_config] : []
    content {
      enabled = service_external_ips_config.value.enabled
    }
  }

  dynamic "ip_allocation_policy" {
    for_each = var.ip_allocation_policy != null ? [var.ip_allocation_policy] : []
    content {
      cluster_secondary_range_name  = ip_allocation_policy.value.cluster_secondary_range_name
      services_secondary_range_name = ip_allocation_policy.value.services_secondary_range_name
      cluster_ipv4_cidr_block       = ip_allocation_policy.value.cluster_ipv4_cidr_block
      services_ipv4_cidr_block      = ip_allocation_policy.value.services_ipv4_cidr_block
      stack_type                    = ip_allocation_policy.value.stack_type
    }
  }

  dynamic "maintenance_policy" {
    for_each = var.maintenance_policy != null ? [var.maintenance_policy] : []
    content {

      dynamic "daily_maintenance_window" {
        for_each = maintenance_policy.value.daily_maintenance_window != null ? [maintenance_policy.value.daily_maintenance_window] : []
        content {
          start_time = daily_maintenance_window.value.start_time
        }
      }

      dynamic "recurring_window" {
        for_each = maintenance_policy.value.recurring_window != null ? [maintenance_policy.value.recurring_window] : []
        content {
          start_time = recurring_window.value.start_time
          end_time   = recurring_window.value.end_time
          recurrence = recurring_window.value.recurrence
        }
      }

      dynamic "maintenance_exclusion" {
        for_each = maintenance_policy.value.maintenance_exclusion != null ? [maintenance_policy.value.maintenance_exclusion] : []
        content {
          exclusion_name = maintenance_exclusion.value.exclusion_name
          start_time     = maintenance_exclusion.value.start_time
          end_time       = maintenance_exclusion.value.end_time

          dynamic "exclusion_options" {
            for_each = maintenance_exclusion.value.exclusion_options != null ? [maintenance_exclusion.value.exclusion_options] : []
            content {
              scope = exclusion_options.value.scope
            }
          }
        }
      }
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config != null ? [var.master_authorized_networks_config] : []
    content {

      dynamic "cidr_blocks" {
        for_each = master_authorized_networks_config.value.cidr_blocks != null ? master_authorized_networks_config.value.cidr_blocks : []
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }

      gcp_public_cidrs_access_enabled = master_authorized_networks_config.value.gcp_public_cidrs_access_enabled
    }
  }

  dynamic "network_policy" {
    for_each = var.network_policy != null ? [var.network_policy] : []
    content {
      provider = network_policy.value.provider
      enabled  = network_policy.value.enabled
    }
  }

  dynamic "node_pool_auto_config" {
    for_each = var.node_pool_auto_config != null ? [var.node_pool_auto_config] : []
    content {

      dynamic "node_kubelet_config" {
        for_each = node_pool_auto_config.value.node_kubelet_config != null ? [node_pool_auto_config.value.node_kubelet_config] : []
        content {
          insecure_kubelet_readonly_port_enabled = node_kubelet_config.value.insecure_kubelet_readonly_port_enabled
        }
      }

      resource_manager_tags = node_pool_auto_config.value.resource_manager_tags

      dynamic "network_tags" {
        for_each = node_pool_auto_config.value.network_tags != null ? node_pool_auto_config.value.network_tags : []
        content {
          tags = network_tags.value
        }
      }
    }
  }

  dynamic "node_pool_defaults" {
    for_each = var.node_pool_defaults != null ? [var.node_pool_defaults] : []
    content {

      node_config_defaults {
        insecure_kubelet_readonly_port_enabled = node_pool_defaults.value.insecure_kubelet_readonly_port_enabled
        gcfs_config {
          enabled = node_pool_defaults.value.gcfs_config_enabled
        }
      }
    }
  }

  secret_manager_config {
    enabled = var.secret_manager_enabled
  }

  dynamic "authenticator_groups_config" {
    for_each = var.authenticator_groups_config != null ? [var.authenticator_groups_config] : []
    content {
      security_group = authenticator_groups_config.value.security_group
    }
  }


  lifecycle {
    precondition {
      condition     = !(var.node_locations == null && var.cluster_location == null)
      error_message = "Either cluster_location or node_locations must be provided. Unless your cluster nodes need to be in specific zones, please provide the value for cluster_location."
    }
  }
}
