##### 🌎 Generic variables #####

variable "project_id" {
  description = "The project ID where the resources will be provisioned."
  type        = string
}

##### 🌐 Cluster variables #####

variable "cluster_name" {
  description = "The name of the cluster."
  type        = string
}

variable "cluster_location" {
  description = "The location of the cluster. This can be a region or a zone."
  type        = string
  default     = null
}

variable "node_locations" {
  description = "The location for the nodes. When defining this value, the cluster location is omitted."
  type        = set(string)
  default     = null
}

variable "enable_cluster_deletion_protection" {
  description = "If Terraform is allowed to delete the cluster."
  type        = bool
  default     = false
}

variable "allow_net_admin" {
  description = "If NET_ADMIN is enabled for the cluster."
  type        = bool
  default     = false
}

variable "cluster_description" {
  description = "The description of the cluster."
  type        = string
  default     = null
}

variable "enable_autopilot" {
  description = "If autopilot is enabled for the cluster."
  type        = bool
  default     = false
}

variable "initial_node_count" {
  description = "The initial node count for the cluster."
  type        = number
  default     = 1
}

variable "networking_mode" {
  description = "The networking mode for the cluster."
  type        = string
  default     = "VPC_NATIVE"

  validation {
    condition     = contains(["VPC_NATIVE", "ROUTES"], var.networking_mode)
    error_message = "networking_mode must be either VPC_NATIVE or ROUTES."
  }
}

variable "min_master_version" {
  description = "The minimum master version for the cluster."
  type        = string
  default     = null
}

variable "network" {
  description = "The network for the cluster."
  type        = string
}

variable "remove_default_node_pool" {
  description = "If the default node pool should be removed."
  type        = bool
  default     = true
}

variable "cluster_subnetwork" {
  description = "The subnetwork for the cluster."
  type        = string
}

variable "resource_labels" {
  description = "The resource labels for the cluster."
  type        = map(string)
  default = {
    provisioned_by = "terraform"
  }
}

variable "addons_config" {
  description = "The addons configuration for the cluster."
  type = object({
    disable_horizontal_pod_autoscaling = bool
    disable_http_load_balancing        = bool
    disable_network_policy_config      = bool
    enable_gcp_filestore_csi_driver    = bool
    enable_gcs_fuse_csi_driver         = bool
    cloudrun_config = optional(object({
      disable_cloudrun_config = bool
      load_balancer_type      = string
    }))
  })
  default = {
    disable_horizontal_pod_autoscaling = false
    disable_http_load_balancing        = false
    disable_network_policy_config      = false
    enable_gcp_filestore_csi_driver    = false
    enable_gcs_fuse_csi_driver         = false
    cloudrun_config                    = null
  }

  validation {
    condition     = var.addons_config.cloudrun_config == null ? true : contains(["LOAD_BALANCER_TYPE_INTERNAL", "LOAD_BALANCER_TYPE_EXTERNAL"], var.addons_config.cloudrun_config.load_balancer_type)
    error_message = "The load_balancer_type must be either LOAD_BALANCER_TYPE_INTERNAL or LOAD_BALANCER_TYPE_EXTERNAL."
  }
}

variable "cluster_autoscaling" {
  description = "The cluster autoscaling configuration for the cluster."
  type = object({
    enable_cluster_autoscaling = bool
    resource_limits = optional(set(object({
      resource_type = string
      minimum       = number
      maximum       = number
    })))
    auto_auto_provisioning_defaults = optional(object({
      service_account = optional(string)
      disk_size_gb    = optional(number)
      disk_type       = optional(string)
      image_type      = optional(string)
      management = optional(object({
        auto_upgrade = bool
        auto_repair  = bool
      }))
      upgrade_settings = optional(object({
        strategy        = string
        max_surge       = number
        max_unavailable = number
      }))
    }))
  })
  default = {
    enable_cluster_autoscaling = false
    resource_limits            = null
    auto_auto_provisioning_defaults = {
      management = null
      upgrade_settings = {
        strategy        = "SURGE"
        max_surge       = 1
        max_unavailable = 0
      }
    }
  }

  validation {
    condition = var.cluster_autoscaling.resource_limits == null ? true : alltrue([
      for limit in var.cluster_autoscaling.resource_limits :
      contains(["cpu", "memory"], lower(limit.resource_type))
    ])
    error_message = "resource_type must be either 'cpu' or 'memory'"
  }

  validation {
    condition     = var.cluster_autoscaling.auto_auto_provisioning_defaults.service_account == null ? true : can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?(@[a-z]([-a-z0-9]*[a-z0-9])?\\.iam\\.gserviceaccount\\.com)?$", var.cluster_autoscaling.auto_auto_provisioning_defaults.service_account))
    error_message = "service_account must be a valid service account name or email (e.g., 'my-sa' or 'my-sa@project-id.iam.gserviceaccount.com')"
  }

  validation {
    condition = var.cluster_autoscaling.resource_limits == null ? true : alltrue([
      for limit in var.cluster_autoscaling.resource_limits :
      contains(["cpu", "memory"], lower(limit.resource_type))
    ])
    error_message = "resource_type must be either 'cpu' or 'memory'"
  }
}

variable "service_external_ips_config" {
  description = "The service external IPs configuration for the cluster."
  type = object({
    enabled = bool
  })
  default = {
    enabled = false
  }
}

variable "ip_allocation_policy" {
  description = "The IP allocation policy configuration for the cluster."
  type = object({
    cluster_secondary_range_name  = string
    services_secondary_range_name = string
    cluster_ipv4_cidr_block       = string
    services_ipv4_cidr_block      = string
    stack_type                    = string
  })

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$", var.ip_allocation_policy.cluster_ipv4_cidr_block))
    error_message = "cluster_ipv4_cidr_block must be a valid IPv4 CIDR notation"
  }

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$", var.ip_allocation_policy.services_ipv4_cidr_block))
    error_message = "services_ipv4_cidr_block must be a valid IPv4 CIDR notation"
  }

  validation {
    condition     = contains(["IPV4", "IPV4_IPV6"], var.ip_allocation_policy.stack_type)
    error_message = "stack_type must be either IPV4 or IPV4_IPV6"
  }
}

variable "maintenance_policy" {
  description = "The maintenance policy configuration for the cluster."
  type = object({
    daily_maintenance_window = optional(object({
      start_time = string
    }))
    recurring_window = optional(object({
      start_time = string
      end_time   = string
      recurrence = string
    }))
    maintenance_exclusion = optional(set(object({
      exclusion_name = string
      start_time     = string
      end_time       = string
      exclusion_options = optional(object({
        scope = string
      }))
    })))
  })
  default = null

  validation {
    condition     = var.maintenance_policy == null ? true : can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.maintenance_policy.daily_maintenance_window.start_time))
    error_message = "daily_maintenance_window start_time must be in HH:mm format (00:00-23:59)"
  }

  validation {
    condition = var.maintenance_policy == null ? true : (
      can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}T([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]Z$", var.maintenance_policy.recurring_window.start_time)) &&
    can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}T([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]Z$", var.maintenance_policy.recurring_window.end_time)))
    error_message = "recurring_window times must be in RFC3339 format"
  }

  validation {
    condition     = var.maintenance_policy == null ? true : can(regex("^FREQ=(DAILY|WEEKLY|MONTHLY);(BYDAY=[A-Z,]+)?$", var.maintenance_policy.recurring_window.recurrence))
    error_message = "recurring_window recurrence must be in iCal format (e.g., FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR)"
  }
}

variable "master_authorized_networks_config" {
  description = "The master authorized networks configuration for the cluster."
  type = object({
    cidr_blocks = optional(set(object({
      cidr_block   = string
      display_name = string
    })))
    gcp_public_cidrs_access_enabled = bool
  })
  default = {
    cidr_blocks                     = null
    gcp_public_cidrs_access_enabled = false
  }

  validation {
    condition = var.master_authorized_networks_config.cidr_blocks == null ? true : alltrue([
      for block in var.master_authorized_networks_config.cidr_blocks : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$", block.cidr_block))
    ])
    error_message = "cidr_blocks must be valid IPv4 CIDR notation"
  }
}

variable "network_policy" {
  description = "The network policy configuration for the cluster."
  type = object({
    provider = string
    enabled  = bool
  })
  default = null
}

variable "node_pool_auto_config" {
  description = "The node pool auto configuration for the cluster with autopilot."
  type = object({
    node_kubelet_config = optional(object({
      insecure_kubelet_readonly_port_enabled = string
    }))
    resource_manager_tags = optional(map(string))
    network_tags          = optional(set(string))
  })
  default = {}
}

variable "node_pool_defaults" {
  description = "The node pool defaults configuration for the cluster."
  type = object({
    insecure_kubelet_readonly_port_enabled = string
    gcfs_config_enabled                    = bool
  })
  default = {
    insecure_kubelet_readonly_port_enabled = "FALSE"
    gcfs_config_enabled                    = false
  }

  validation {
    condition     = contains(["TRUE", "FALSE"], var.node_pool_defaults.insecure_kubelet_readonly_port_enabled)
    error_message = "insecure_kubelet_readonly_port_enabled must be either TRUE or FALSE in upper case."
  }
}

variable "secret_manager_enabled" {
  description = "If secret manager is enabled for the cluster."
  type        = bool
  default     = false
}

variable "authenticator_groups_config" {
  description = "The authenticator groups configuration for the cluster."
  type = object({
    security_group = string
  })
  default = null
}

variable "private_cluster_config" {
  description = "The private cluster configuration for the cluster."
  type = object({
    enable_private_nodes         = bool
    enable_private_endpoint      = bool
    master_ipv4_cidr_block       = optional(string)
    private_endpoint_subnetwork  = optional(string)
    master_global_access_enabled = bool
  })
  default = {
    enable_private_nodes         = false
    enable_private_endpoint      = false
    master_ipv4_cidr_block       = null
    private_endpoint_subnetwork  = null
    master_global_access_enabled = false
  }
}

variable "kubernetes_release_channel" {
  description = "The Kubernetes release channel for the cluster."
  type        = string
  default     = "UNSPECIFIED"

  validation {
    condition     = contains(["UNSPECIFIED", "RAPID", "REGULAR", "STABLE", "EXTENDED"], var.kubernetes_release_channel)
    error_message = "kubernetes_release_channel must be one of: UNSPECIFIED, RAPID, REGULAR, STABLE, or EXTENDED"
  }
}

variable "vertical_pod_autoscaling_enabled" {
  description = "If vertical pod autoscaling is enabled for the cluster."
  type        = bool
  default     = false
}

variable "workload_identity_config" {
  description = "The workload identity configuration for the cluster."
  type = object({
    workload_pool = string
  })
  default = null
}

variable "dns_config" {
  description = "The DNS configuration for the cluster."
  type = object({
    additive_vpc_scope_dns_domain = optional(string)
    cluster_dns                   = string
    cluster_dns_scope             = optional(string)
    cluster_dns_domain            = optional(string)
  })
  default = {
    additive_vpc_scope_dns_domain = null
    cluster_dns                   = "PLATFORM_DEFAULT" # Best solution if Cloud DNS isn't used in the project.
    cluster_dns_scope             = null
    cluster_dns_domain            = null
  }

  validation {
    condition     = contains(["PROVIDER_UNSPECIFIED", "PLATFORM_DEFAULT", "CLOUD_DNS"], var.dns_config.cluster_dns)
    error_message = "cluster_dns must be one of: PROVIDER_UNSPECIFIED, PLATFORM_DEFAULT, or CLOUD_DNS"
  }

  validation {
    condition     = var.dns_config.cluster_dns_scope == null ? true : contains(["DNS_SCOPE_UNSPECIFIED", "CLUSTER_SCOPE", "VPC_SCOPE"], var.dns_config.cluster_dns_scope)
    error_message = "cluster_dns_scope must be one of: DNS_SCOPE_UNSPECIFIED, CLUSTER_SCOPE, or VPC_SCOPE"
  }
}

variable "gateway_api_channel" {
  description = "Enables GKE Gateway API support."
  type        = string
  default     = "CHANNEL_STANDARD"

  validation {
    condition     = contains(["CHANNEL_DISABLED", "CHANNEL_EXPERIMENTAL", "CHANNEL_STANDARD"], var.gateway_api_channel)
    error_message = "gateway_api_channel must be one of: CHANNEL_DISABLED, CHANNEL_EXPERIMENTAL, or CHANNEL_STANDARD"
  }
}

##### 🔄 Node pool variables #####

variable "node_pool" {
  description = "A map to create node pools attached to the cluster."
  type = map(object({
    initial_node_count = number
    node_locations     = set(string)
    node_pool_name     = string
  }))
  default = null
}

variable "node_pool_auto_repair_enabled" {
  description = "If node pool auto repair is enabled for the cluster."
  type        = bool
  default     = true
}

variable "node_pool_auto_upgrade_enabled" {
  description = "If node pool auto upgrade is enabled for the cluster."
  type        = bool
  default     = false
}

variable "max_pods_per_node" {
  description = "The maximum number of pods per node for the cluster."
  type        = number
  default     = null
}

variable "node_pool_name_prefix" {
  description = "The prefix of the node pool name. This will preffix the random unique name if node_pool_name is not provided."
  type        = string
  default     = null
}

variable "node_count" {
  description = "The number of nodes in the node pool."
  type        = number
  default     = null
}

variable "node_pool_autoscaling" {
  description = "The node pool autoscaling configuration for the cluster."
  type = object({
    min_node_count       = number
    max_node_count       = number
    total_min_node_count = number
    total_max_node_count = number
    location_policy      = string
  })
  default = {
    min_node_count       = 1
    max_node_count       = 1
    total_min_node_count = 1
    total_max_node_count = 1
    location_policy      = "BALANCED"
  }

  validation {
    condition     = contains(["BALANCED", "ANY"], var.node_pool_autoscaling.location_policy)
    error_message = "location_policy must be either BALANCED or ANY"
  }
}

variable "node_config" {
  description = "The node configuration for the cluster."
  type = object({
    disk_size_gb        = optional(number)
    disk_type           = optional(string)
    image_type          = optional(string)
    machine_type        = optional(string)
    preemptible_enabled = optional(bool) # Deprecated, if required, evaluate using spot instead.
    spot_enabled        = optional(bool)
    service_account     = optional(string)
    tags                = set(string)
    node_group          = optional(string)
    gcfs_config_enabled = bool
    gvnic_enabled       = bool
    taint = optional(set(object({
      key    = string
      value  = string
      effect = string
    })))
  })
  default = {
    disk_size_gb        = null
    disk_type           = null
    image_type          = null
    machine_type        = null
    preemptible_enabled = null
    spot_enabled        = null
    service_account     = null
    tags                = null
    node_group          = null
    gcfs_config_enabled = false
    gvnic_enabled       = true
    taint               = null
  }

  validation {
    condition     = var.node_config.service_account == null ? true : can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?@[a-z]([-a-z0-9]*[a-z0-9])?\\.iam\\.gserviceaccount\\.com$", var.node_config.service_account))
    error_message = "service_account must be a valid service account email (e.g., name@project-id.iam.gserviceaccount.com)"
  }
}

variable "upgrade_settings" {
  description = "The upgrade settings for the cluster."
  type = object({
    max_surge       = number
    max_unavailable = number
  })
  default = {
    max_surge       = 1
    max_unavailable = 0
  }
}
