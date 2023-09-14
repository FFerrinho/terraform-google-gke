resource "google_container_cluster" "main" {
  name           = var.name
  location       = var.location
  node_locations = var.node_locations

  dynamic "addons_config" {
    for_each = var.addons_config
    content {
      horizontal_pod_autoscaling {
        disabled = addons_config.value["horizontal_pod_autoscaling_disabled"]
      }
      http_load_balancing {
        disabled = addons_config.value["http_load_balancing_disabled"]
      }
      network_policy_config {
        disabled = addons_config.value["network_policy_config_disabled"]
      }
      gcp_filestore_csi_driver_config {
        enabled = addons_config.value["gcp_filestore_csi_driver_config_enabled"]
      }
      gcs_fuse_csi_driver_config {
        enabled = addons_config.value["gcs_fuse_csi_driver_config_enabled"]
      }
      gce_persistent_disk_csi_driver_config {
        enabled = addons_config.value["gce_persistent_disk_csi_driver_config_enabled"]
      }
      gke_backup_agent_config {
        enabled = addons_config.value["gke_backup_agent_config_enabled"]
      }
      config_connector_config {
        enabled = addons_config.value["config_connector_config_enabled"]
      }
    }
  }

  allow_net_admin   = var.enable_autopilot == false ? null : var.allow_net_admin # This value is only relevant for Autopilot clusters.
  cluster_ipv4_cidr = var.cluster_ipv4_cidr

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
    for_each = toset(var.binary_authorization_evaluation_mode ? [1] : [])
    content {
      evaluation_mode = var.binary_authorization_evaluation_mode
    }
  }

  dynamic "service_external_ips_config" {
    for_each = toset(var.service_external_ips_config_enabled ? [1] : [])
    content {
      enabled = var.service_external_ips_config_enabled
    }
  }

  dynamic "database_encryption" {
    for_each = var.database_encryption
    content {
      state    = database_encryption.value["state"]
      key_name = database_encryption.value["key_name"]
    }
  }

  description               = var.description
  default_max_pods_per_node = var.default_max_pods_per_node
  enable_kubernetes_alpha   = var.enable_kubernetes_alpha

  dynamic "enable_k8s_beta_apis" {
    for_each = toset(var.enabled_k8s_beta_apis ? [1] : [])
    content {
      enabled_apis = var.enabled_k8s_beta_apis
    }
  }

  enable_shielded_nodes = var.enable_shielded_nodes
  enable_autopilot      = var.enable_autopilot
  initial_node_count    = var.enable_autopilot == true ? null : var.initial_node_count # If autopilot is enabled, this field shouldn't be specified.

  dynamic "ip_allocation_policy" {
    for_each = var.ip_allocation_policy
    content {
      cluster_secondary_range_name  = ip_allocation_policy.value["cluster_secondary_range_name"]
      services_secondary_range_name = ip_allocation_policy.value["services_secondary_range_name"]
      cluster_ipv4_cidr_block       = ip_allocation_policy.value["cluster_ipv4_cidr_block"]
      services_ipv4_cidr_block      = ip_allocation_policy.value["services_ipv4_cidr_block"]
      stack_type                    = ip_allocation_policy.value["stack_type"]
      dynamic "additional_pod_ranges_config" {
        for_each = var.ip_allocation_policy.value["additional_pod_ranges_config"]
        content {
          pod_range_names = additional_pod_ranges_config.value["pod_range_names"]
        }
      }
    }
  }

  networking_mode = var.networking_mode

  dynamic "logging_config" {
    for_each = toset(var.logging_config_enabled_components ? [1] : [])
    content {
      enable_components = var.logging_config_enabled_components
    }
  }

  logging_service = var.logging_service

  dynamic "maintenance_policy" {
    for_each = var.maintenance_policy
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
    for_each = toset(var.master_auth_enabled ? [1] : [])
    content {
      client_certificate_config {
        issue_client_certificate = var.master_auth_enabled
      }
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks_config.value["cidr_blocks"]
        content {
          cidr_block   = cidr_blocks.value["cidr_block"]
          display_name = cidr_blocks.value["display_name"]
        }
      }
      gcp_public_cidrs_access_enabled = master_authorized_networks_config.value["gcp_public_cidrs_access_enabled"]
    }
  }

  min_master_version = var.min_master_version

  dynamic "monitoring_config" {
    for_each = var.monitoring_config
    content {
      enable_components = monitoring_config.value["enable_components"]
      dynamic "managed_prometheus" {
        for_each = monitoring_config.value["managed_prometheus"]
        content {
          enabled = managed_prometheus.value["enabled"]
        }
      }
      dynamic "advanced_datapath_observability_config" {
        for_each = monitoring_config.value["advanced_datapath_observability_config"]
        content {
          enable_metrics = advanced_datapath_observability_config.value["enable_metrics"]
          relay_mode     = advanced_datapath_observability_config.value["relay_mode"]
        }
      }
    }
  }

  monitoring_service = var.monitoring_service
  network            = data.google_compute_network.main.self_link

  dynamic "network_policy" {
    for_each = var.network_policy
    content {
      provider = network_policy.value["provider"]
      enabled  = network_policy.value["enabled"]
    }
  }

  node_version = var.node_version

  dynamic "notification_config" {
    for_each = var.notification_config
    content {
      pubsub {
        enabled = notification_config.value["pubsub_enabled"]
        topic   = notification_config.value["pubsub_topic"]
        dynamic "filter" {
          for_each = notification_config.value["pubsub_filter"]
          content {
            event_type = filter.value["event_type"]
          }
        }
      }
    }
  }

  dynamic "confidential_nodes" {
    for_each = toset(var.confidential_nodes_enabled ? [1] : [])
    content {
      enabled = var.confidential_nodes_enabled
    }
  }

  dynamic "authenticator_groups_config" {
    for_each = toset(var.authenticator_groups_config_security_group ? [1] : [])
    content {
      security_group = var.authenticator_groups_config_security_group
    }
  }

  dynamic "private_cluster_config" {
    for_each = var.private_cluster_config
    content {
      enable_private_nodes    = private_cluster_config.value["enable_private_nodes"]
      enable_private_endpoint = private_cluster_config.value["enable_private_endpoint"]
      master_ipv4_cidr_block  = private_cluster_config.value["master_ipv4_cidr_block"]
      dynamic "master_global_access_config" {
        for_each = private_cluster_config.value["master_global_access_config"]
        content {
          enabled = master_global_access_config.value["enabled"]
        }
      }
    }
  }

  project = var.project

  dynamic "release_channel" {
    for_each = toset(var.release_channel ? [1] : [])
    content {
      channel = var.release_channel
    }
  }

  remove_default_node_pool = var.enable_autopilot == true ? null : var.remove_default_node_pool # If autopilot is enabled, this field shouldn't be specified.
  resource_labels          = var.resource_labels

  dynamic "cost_management_config" {
    for_each = toset(var.cost_management_config_enabled ? [1] : [])
    content {
      enabled = cost_management_config_enabled
    }
  }

  dynamic "resource_usage_export_config" {
    for_each = var.resource_usage_export_config
    content {
      enable_network_egress_metering       = var.resource_usage_export_config.value["enable_network_egress_metering"]
      enable_resource_consumption_metering = var.resource_usage_export_config.value["enable_resource_consumption_metering"]
      dynamic "bigquery_destination" {
        for_each = toset(var.resource_usage_export_config.value["bigquery_dataset_id"] ? [1] : [])
        content {
          dataset_id = var.resource_usage_export_config.value["bigquery_dataset_id"]
        }
      }
    }
  }

  subnetwork = var.subnetwork

  dynamic "vertical_pod_autoscaling" {
    for_each = toset(var.vertical_pod_autoscaling_enabled ? [1] : [])
    content {
      enabled = var.vertical_pod_autoscaling_enabled
    }
  }

  dynamic "workload_identity_config" {
    for_each = toset(var.workload_identity_config_pool ? [1] : [])
    content {
      workload_pool = var.workload_identity_config_pool
    }
  }

  enable_intranode_visibility = var.enable_intranode_visibility
  enable_l4_ilb_subsetting    = var.enable_l4_ilb_subsetting
  private_ipv6_google_access  = var.private_ipv6_google_access
  datapath_provider           = var.datapath_provider

  dynamic "default_snat_status" {
    for_each = toset(var.default_snat_status_disabled ? [1] : [])
    content {
      disabled = var.default_snat_status_disabled
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

  dynamic "gateway_api_config" {
    for_each = toset(var.gateway_api_config_channel ? [1] : [])
    content {
      channel = var.gateway_api_config_channel
    }
  }

  dynamic "security_posture_config" {
    for_each = var.security_posture_config
    content {
      mode               = security_posture_config.value["mode"]
      vulnerability_mode = security_posture_config.value["vulnerability_mode"]
    }
  }

  lifecycle {

    ignore_changes = [
      initial_node_count
    ]

    precondition {
      condition     = var.cluster_ipv4_cidr != null && var.networking_mode == "ROUTES" && var.ip_allocation_policy != null
      error_message = "With ROUTERS networking mode, cluster_ipv4_cidr and ip_allocation_policy cannot be set at the same time."
    }

    precondition {
      condition     = var.database_encryption["state"] == "ENCRYPTED" && var.database_encryption["key_name"] == null
      error_message = "Value of database_encryption.key_name must be set if database_encryption.state is set to ENCRYPTED."
    }

    precondition {
      condition     = var.default_max_pods_per_node != null && var.networking_mode == "ROUTES" && var.ip_allocation_policy == null
      error_message = "If networking mode is set to ROUTES and ip_allocation_policy is not set, default_max_pods_per_node will not work."
    }

    precondition {
      condition     = var.enable_kubernetes_alpha == true
      error_message = "When Kubernetes Alpha is enabled, the cluster cannot be upgraded and will be deleted after 30 days."
    }

    precondition {
      condition     = var.networking_mode == "VPC_NATIVE" && var.ip_allocation_policy == null
      error_message = "If networking_mode is set to VPC_NATIVE, ip_allocation_policy must be set."
    }
  }
}
