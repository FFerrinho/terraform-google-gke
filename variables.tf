# Variable definitions
variable "cluster_name" {
  description = "The name for the GKE cluster."
  type        = string
}

variable "cluster_location" {
  description = "The location (region or zone) for the GKE cluster."
  type        = string
}

variable "description" {
  description = "The description for the GKE cluster."
  type        = string
  default     = null
}

variable "project_id" {
  description = "The project ID for the GKE cluster."
  type        = string
}

variable "node_locations" {
  description = "A list of zones for the GKE nodes."
  type        = set(string)
  default     = []
}

variable "cluster_deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the GKE cluster (and all contained resources)."
  type        = bool
  default     = true
}

variable "allow_net_admin" {
  description = "Whether or not to allow the GKE nodes to have the 'net_admin' capability."
  type        = bool
  default     = false
}

variable "cluster_ipv4_cidr" {
  description = "The IP address range for the pods in this cluster. If left blank a /14 block will be used."
  type        = string
  default     = null
}

variable "enable_autopilot" {
  description = "Whether or not to enable Autopilot for the GKE cluster."
  type        = bool
  default     = false
}

variable "enable_tpu" {
  description = "Whether or not to enable TPUs for the GKE cluster."
  type        = bool
  default     = false
}

variable "initial_node_count" {
  description = "The initial number of nodes for the GKE cluster."
  type        = number
  default     = null
}

variable "remove_default_node_pool" {
  description = "Whether or not to remove the default node pool from the GKE cluster."
  type        = bool
  default     = false
}

variable "addons_config" {
  description = "The addons config for the GKE cluster."
  type = object({
    disable_horizontal_pod_autoscaling = optional(object({
      disabled = bool
    }))
    disable_http_load_balancing = optional(object({
      disabled = bool
    }))
    disable_network_policy_config = optional(object({
      disabled = bool
    }))
    enable_gcp_filestore_csi_driver_config = optional(object({
      enabled = bool
    }))
    enable_gcs_fuse_csi_driver_config = optional(object({
      enabled = bool
    }))
    cloudrun_config = optional(object({
      disabled           = bool
      load_balancer_type = string
    }))
    dns_cache_config = optional(object({
      enabled = bool
    }))
    gce_persistent_disk_csi_driver_config = optional(object({
      enabled = bool
    }))
    gke_backup_agent_config = optional(object({
      enabled = bool
    }))
  })
  default = null
}

variable "cluster_autoscaling" {
  description = "The cluster autoscaling config for the GKE cluster."
  type = object({
    enabled = optional(bool)
    resource_limits = optional(set(object({
      resource_type = string
      minimum       = number
      maximum       = number
    })))
    auto_auto_provisioning_defaults = optional(object({
      min_cpu_platform = string
      service_account  = string
      disk_size        = string
      disk_type        = string
      image_type       = string
      management = optional(object({
        auto_upgrade = bool
        auto_repair  = bool
        upgrade_settings = optional(object({
          strategy        = string
          max_surge       = number
          max_unavailable = number
        }))
      }))
    }))
  })
  default = null
}

variable "service_external_ip_configs" {
  description = "The service external ip configs for the GKE cluster."
  type = object({
    enabled = bool
  })
  default = null
}

variable "default_max_pods_per_node" {
  description = "The default max pods per node for the GKE cluster."
  type        = number
  default     = null
}

variable "ip_allocation_policy" {
  description = "The configuration for the cluster pod and services network ranges."
  type = object({
    cluster_secondary_range_name  = optional(string)
    services_secondary_range_name = optional(string)
    cluster_ipv4_cidr_block       = optional(string)
    services_ipv4_cidr_block      = optional(string)
    stack_type                    = optional(string)
  })
  default = null
}

variable "networking_mode" {
  description = "If the cluster network is ROUTES or VPC_NATIVE. This affects the alias IPs and routes."
  type        = string
  default     = "VPC_NATIVE"

  validation {
    condition     = contains(["ROUTES", "VPC_NATIVE"], var.networking_mode)
    error_message = "networking_mode must be either ROUTES or VPC_NATIVE."
  }
}

variable "maintenance_policy" {
  description = "Maintenance configuration for the GKE cluster"
  type = object({
    daily_maintenance_window = optional(object({
      start_time = optional(string) # Format: HH:MM, in UTC
    }))
    recurring_window = optional(object({
      start_time = optional(string) # RFC3339 timestamp
      end_time   = optional(string) # RFC3339 timestamp
      recurrence = optional(string) # RFC5545 RRULE
    }))
    maintenance_exclusion = optional(object({
      exclusion_name = optional(string)
      exclusion_options = optional(object({
        scope = optional(string) # NO_UPGRADES, NO_MINOR_UPGRADES, or NO_MINOR_OR_NODE_UPGRADES
      }))
      start_time = optional(string) # RFC3339 timestamp
      end_time   = optional(string) # RFC3339 timestamp
    }))
  })

  default = null

  validation {
    condition     = var.maintenance_policy == null || try(can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.maintenance_policy.daily_maintenance_window.start_time)), true)
    error_message = "daily_maintenance_window start_time must be in HH:MM format (00:00-23:59)."
  }
}

variable "network" {
  description = "The VPC where the cluster is connected."
  type        = string
}

variable "subnetwork" {
  description = "The VPC subnetwork where the cluster is connected."
  type        = string
}

variable "node_pool_auto_config" {
  description = "Default values for node pools managed by autopilot."
  type = object({
    insecure_kubelet_readonly_port_enabled = optional(bool)
    resource_manager_tags = optional(object({
      "name" = string
    }))
    network_tags = optional(set(string))
  })
}

variable "node_pool_defaults" {
  description = "Default values for node pools managed by autopilot."
  type = object({
    node_config_defaults = optional(object({
      insecure_kubelet_readonly_port_enabled = optional(bool)
      logging_variant                        = optional(string)
      gcfs_config_enabled                    = optional(bool)
    }))
  })
  default = {
    node_config_defaults = {
      insecure_kubelet_readonly_port_enabled = false
      logging_variant                        = "DEFAULT"
      gcfs_config_enabled                    = null
    }
  }
}

variable "release_channel" {
  description = "The release channel for Kubernetes."
  type        = string
  default     = "UNSPECIFIED"

  validation {
    condition     = contains(["UNSPECIFIED", "RAPID", "REGULAR", "STABLE", "EXTENDED"], var.release_channel)
    error_message = "release_channel must be one of UNSPECIFIED, RAPID, REGULAR, STABLE, or EXTENDED."
  }
}

variable "resource_labels" {
  description = "Labels to apply to the cluster."
  type        = map(string)
  default     = null
}

variable "enable_vertical_pod_autoscaling" {
  description = "Whether or not to enable vertical pod autoscaling for the GKE cluster."
  type        = bool
  default     = false
}

variable "workload_identity_pool" {
  description = "The workload identity pool for the GKE cluster."
  type        = string
  default     = null
}

variable "dns_config" {
  description = "Cluster DNS settings."
  type = object({
    cluster_dns       = optional(string)
    cluster_dns_scope = optional(string)
  })
  default = {
    cluster_dns       = "PROVIDER_UNSPECIFIED"
    cluster_dns_scope = "DNS_SCOPE_UNSPECIFIED"
  }

  validation {
    condition     = contains(["PROVIDER_UNSPECIFIED", "PLATFORM_DEFAULT", "CLOUD_DNS"], var.dns_config.cluster_dns)
    error_message = "release_channel must be one of PROVIDER_UNSPECIFIED, PLATFORM_DEFAULT, CLOUD_DNS."
  }

  validation {
    condition     = contains(["DNS_SCOPE_UNSPECIFIED", "CLUSTER_SCOPE", "VPC_SCOPE"], var.dns_config.cluster_dns_scope)
    error_message = "release_channel must be one of DNS_SCOPE_UNSPECIFIED, CLUSTER_SCOPE, VPC_SCOPE."
  }
}

# Node pool configuration
variable "node_pools" {
  description = "List of node pool configurations"
  type = list(object({
    name                      = string
    machine_type              = string
    node_locations            = optional(list(string))
    autoscaling_min_count     = number
    autoscaling_max_count     = number
    max_pods_per_node         = optional(number)
    node_locations            = optional(set(string))
    location_policy           = optional(string)
    local_ssd_count           = optional(number)
    disk_size_gb              = optional(number)
    disk_type                 = optional(string)
    image_type                = optional(string)
    auto_repair               = optional(bool)
    auto_upgrade              = optional(bool)
    service_account           = optional(string)
    preemptible               = optional(bool)
    spot                      = optional(bool)
    initial_node_count        = optional(number)
    management_auto_repair    = optional(bool)
    management_auto_upgrade   = optional(bool)
    gcfs_config_enabled       = optional(bool)
    gvnic_enabled             = optional(bool)
    use_preemptible_instances = optional(bool)
    use_spot_instances        = optional(bool)
    taint = optional(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = []

  validation {
    condition     = contains(["BALANCED", "ANY"], var.node_pools.location_policy)
    error_message = "node_pools_location_policy must be one of BALANCED or ANY."
  }

  validation {
    condition     = contains(["NO_SCHEDULE", "PREFER_NO_SCHEDULE", "NO_EXECUTE"], var.node_pools.taint.effect)
    error_message = "value must be one of NO_SCHEDULE, PREFER_NO_SCHEDULE, or NO_EXECUTE."
  }
}
