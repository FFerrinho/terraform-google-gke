variable "cluster_name" {
  description = "The name for the cluster."
  type        = string
}

variable "location" {
  description = "The location (region or zone) to host the cluster in."
  type        = string
}

variable "node_locations" {
  description = "The list of zones in which the cluster's nodes should be located."
  type        = list(string)
  default     = null
}

variable "cluster_ipv4_cidr" {
  description = "The IP address range of the Kubernetes pods in this cluster in CIDR notation."
  type        = string
  default     = null
}

variable "cluster_description" {
  description = "The description of the cluster."
  type        = string
  default     = null
}

variable "default_max_pods_per_node" {
  description = "The maximum number of pods per node in this cluster."
  type        = number
  default     = null
}

variable "enable_kubernetes_alpha" {
  description = "Whether to enable Kubernetes Alpha features for this cluster."
  type        = bool
  default     = false
}

variable "enable_shielded_nodes" {
  description = "Whether to enable Shielded Nodes features on all nodes in this cluster."
  type        = bool
  default     = true
}

variable "enable_autopilot" {
  description = "Whether to enable Autopilot for this cluster."
  type        = bool
  default     = false
}

variable "initial_node_count" {
  description = "The number of nodes to create in this cluster's default node pool."
  type        = number
  default     = null
}

variable "networking_mode" {
  description = "The networking mode to use for the cluster."
  type        = string
  default     = null

  validation {
    condition     = can(regex("^(VPC_NATIVE|ROUTES)?$", var.networking_mode))
    error_message = "The networking mode must be either VPC_NATIVE or ROUTES."
  }
}

variable "logging_service" {
  description = "The logging service that the cluster should write logs to."
  type        = string
  default     = null

  validation {
    condition     = can(regex("^(logging.googleapis.com/kubernetes|logging.googleapis.com|none)?$", var.logging_service))
    error_message = "The logging service must be either logging.googleapis.com/kubernetes, logging.googleapis.com, or none."
  }
}

variable "monitoring_service" {
  description = "The monitoring service that the cluster should write metrics to."
  type        = string
  default     = null

  validation {
    condition     = can(regex("^(monitoring.googleapis.com/kubernetes|monitoring.googleapis.com|none)?$", var.monitoring_service))
    error_message = "The monitoring service must be either monitoring.googleapis.com/kubernetes, monitoring.googleapis.com, or none."
  }
}

variable "network" {
  description = "The name or self_link of the Google Compute Engine network to which the cluster is connected."
  type        = string
  default     = null
}

variable "project" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "remove_default_node_pool" {
  description = "Whether to remove the default node pool from the cluster."
  type        = bool
  default     = false
}

variable "resource_labels" {
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster."
  type        = map(string)
  default     = null
}

variable "subnetwork" {
  description = "The name or self_link of the Google Compute Engine subnetwork to which the cluster is connected."
  type        = string
  default     = null
}

variable "addons_config" {
  description = "The configuration of cluster addons."
  type = map(object({
    horizontal_pod_autoscaling_disabled = optional(bool)
    http_load_balancing_disabled        = optional(bool)
    kubernetes_dashboard_disabled       = optional(bool)
    network_policy_config_disabled      = optional(bool)
  }))
  default = null
}


variable "cluster_autoscaling" {
  description = "The configuration of cluster autoscaling."
  type = map(object({
    enabled = optional(bool)
    resource_limits = optional(map(object({
      resource_type = optional(string)
      minimum       = optional(number)
      maximum       = optional(number)
    })))
    auto_provisioning_defaults = optional(map(object({
      min_cpu_platform = optional(string)
      oauth_scopes      = optional(list(string))
    })))
  }))
  default = null
}

variable "binary_authorization" {
  description = "The configuration of cluster binary authorization."
  type = map(object({
    evaluation_mode = optional(string)
  }))
  default = null
}

variable "service_external_ips_config" {
  description = "The configuration of cluster service external IPs."
  type = map(object({
    enabled = optional(bool)
  }))
  default = null
}

variable "ip_allocation_policy" {
  description = "The configuration of cluster IP allocation policy."
  type = map(object({
    cluster_ipv4_cidr_block       = optional(string)
    cluster_secondary_range_name  = optional(string)
    services_ipv4_cidr_block      = optional(string)
    services_secondary_range_name = optional(string)
    stack_type                    = optional(string)
  }))
  default = null
}

variable "logging_config" {
  description = "The configuration of cluster logging."
  type = map(object({
    enable_components = optional(list(string))
  }))
  default = null

  validation {
    condition     = can(regex("^(SYSTEM_COMPONENTS|APISERVER|CONTROLLER_MANAGER|SCHEDULER|WORKLOADS)?$", var.logging_config["enable_components"]))
    error_message = "The logging component must be either SYSTEM_COMPONENTS, APISERVER, CONTROLLER_MANAGER, SCHEDULER or WORKLOADS."
  }
}

variable "maintenance_policy" {
  description = "The configuration of cluster maintenance policy."
  type = map(object({
    daily_maintenance_window = optional(map(object({
      start_time = optional(string)
      duration   = optional(string)
    })))
    recurring_window = optional(map(object({
      window = optional(map(object({
        start_time = optional(string)
        end_time   = optional(string)
        recurrence = optional(string)
      })))
      maintenance_exclusion = optional(map(object({
        exclusion_name = optional(string)
        start_time     = optional(string)
        end_time       = optional(string)
        exclusion_options = optional(map(object({
          scope = optional(string)
        })))
      })))
    })))
  }))
  default = null

  validation {
    condition     = can(regex("^(NO_UPGRADES|NO_MINOR_UPGRADES|NO_MINOR_OR_NODE_UPGRADES)?$", var.maintenance_policy["window"]["maintenance_exclusion"]["exclusion_options"]["scope"]))
    error_message = "The maintenance exclusion scope must be either NO_UPGRADES, NO_MINOR_UPGRADES or NO_MINOR_OR_NODE_UPGRADES."
  }
}

variable "master_auth" {
  description = "The configuration of cluster master auth."
  type = map(object({
    client_certificate_config = optional(map(object({
      issue_client_certificate = optional(bool)
    })))
    master_authorized_networks_config = optional(map(object({
      cidr_blocks = optional(list(object({
        cidr_block   = optional(string)
        display_name = optional(string)
      })))
    })))
    gcp_public_cidrs_access_enabled = optional(bool)
  }))
  default = null
}

variable "monitoring_config" {
  description = "The configuration of cluster monitoring."
  type = map(object({
    enable_components = optional(list(string))
    managed_prometheus = optional(map(object({
      enabled = optional(bool)
    })))
  }))
  default = null

  validation {
    condition     = can(regex("^(SYSTEM_COMPONENTS|APISERVER|CONTROLLER_MANAGER|SCHEDULER|WORKLOADS)?$", var.monitoring_config["enable_components"]))
    error_message = "The monitoring component must be either SYSTEM_COMPONENTS, APISERVER, CONTROLLER_MANAGER, SCHEDULER or WORKLOADS."
  }
}

variable "network_policy" {
  description = "The configuration of cluster network policy."
  type = map(object({
    enabled  = optional(bool)
    provider = optional(string)
  }))
  default = null
}

variable "node_config" {
  description = "The configuration of cluster node config."
  type = map(object({
    disk_size_gb     = number
    disk_type        = string
    image_type       = string
    labels           = map(string)
    resource_labels  = map(string)
    local_ssd_count  = number
    machine_type     = string
    metadata         = map(string)
    min_cpu_platform = string
    oath_scopes      = list(string)
    preemptible      = bool
    spot             = bool
    service_account  = string
    tags             = list(string)
    node_group       = string
    ephemeral_storage_config = map(object({
      local_ssd_count = number
    }))
    ephemeral_storage_local_ssd_config = map(object({
      local_ssd_count = number
    }))
    local_nvme_ssd_block_config = map(object({
      local_ssd_count = number
    }))
    logging_variant = string
    gcfs_config = map(object({
      enabled = bool
    }))
    gvnic = map(object({
      enabled = bool
    }))
    guest_accelerator = map(object({
      type               = string
      count              = number
      gpu_partition_size = number
      gpu_sharing_config = map(object({
        gpu_sharing_strategy       = string
        max_shared_clients_per_gpu = number
      }))
    }))
    reservation_affinity = map(object({
      consume_reservation_type = string
      key                      = string
      values                   = list(string)
    }))
    sandbox_config = map(object({
      sandbox_type = string
    }))
    workload_metadata_config = map(object({
      mode = string
    }))
    kubelet_config = map(object({
      cpu_manager_policy   = string
      cpu_cfs_quota        = number
      cpu_cfs_quota_period = string
      pod_pids_limit       = number
    }))
    linux_node_config = map(object({
      sysctls = map(string)
    }))
    advanced_machine_features = map(object({
      threads_per_core = number
    }))
  }))
  default = null
}

variable "node_pool" {
  
}

variable "node_pool_auto_config" {
  description = "Auto-configuration options for the node pool."
  type = map(object({
    network_tags = map(object({
      tag = string
    }))
  }))
  default = null
}

variable "private_cluster_config" {
  description = "Configuration options for private cluster setup."
  type = map(object({
    enable_private_endpoint = bool
    enable_private_nodes    = bool
    master_ipv4_cidr_block  = string
    master_global_access_config = map(object({
      enabled = bool
    }))
  }))
  default = null
}

variable "release_channel" {
  description = "Release channel configuration for the cluster."
  type = map(object({
    channel = string
  }))
  default = null
}

variable "vertical_pod_autoscaling" {
  description = "Vertical Pod Autoscaling configuration for the cluster."
  type = map(object({
    enabled = bool
  }))
  default = null
}

variable "workload_identity_config" {
  description = "Workload Identity configuration for the cluster."
  type = map(object({
    workload_pool = string
  }))
  default = null
}

variable "dns_config" {
  description = "DNS configuration for the cluster."
  type = map(object({
    cluster_dns        = list(string)
    cluster_dns_scope  = string
    cluster_dns_domain = string
  }))
  default = null
}


variable "project_config" {
  description = "Project configuration for the cluster."
  type = map(object({
    workload_vulnerability_mode = string
    workload_config = map(object({
      audit_mode = string
    }))
  }))
  default = null
}
