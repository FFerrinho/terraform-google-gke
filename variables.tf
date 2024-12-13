variable "project_id" {
  description = "The project ID where the resources will be provisioned."
  type        = string
}

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
  default     = true
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

variable "network" {
  description = "The network for the cluster."
  type        = string
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
    condition     = var.cluster_autoscaling.auto_auto_provisioning_defaults.service_account == null ? true : can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.cluster_autoscaling.auto_auto_provisioning_defaults.service_account))
    error_message = "service_account must be a valid service account name"
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
  default = {
    daily_maintenance_window = null
    recurring_window         = null
    maintenance_exclusion    = null
  }

  validation {
    condition     = var.maintenance_policy.daily_maintenance_window == null ? true : can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.maintenance_policy.daily_maintenance_window.start_time))
    error_message = "daily_maintenance_window start_time must be in HH:mm format (00:00-23:59)"
  }

  validation {
    condition = var.maintenance_policy.recurring_window == null ? true : (
      can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}T([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]Z$", var.maintenance_policy.recurring_window.start_time)) &&
    can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}T([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]Z$", var.maintenance_policy.recurring_window.end_time)))
    error_message = "recurring_window times must be in RFC3339 format"
  }

  validation {
    condition     = var.maintenance_policy.recurring_window == null ? true : can(regex("^FREQ=(DAILY|WEEKLY|MONTHLY);(BYDAY=[A-Z,]+)?$", var.maintenance_policy.recurring_window.recurrence))
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
  default = {
    provider = "PROVIDER_UNSPECIFIED"
    enabled  = false
  }
}

variable "node_pool_auto_config" {
  description = "The node pool auto configuration for the cluster."
  type = object({
    node_kubelet_config = optional(object({
      insecure_kubelet_readonly_port_enabled = bool
    }))
    resource_manager_tags = optional(map(string))
    network_tags          = optional(set(string))
  })
  default = {
    node_kubelet_config = {
      insecure_kubelet_readonly_port_enabled = false
    }
    resource_manager_tags = null
    network_tags          = null
  }
}
