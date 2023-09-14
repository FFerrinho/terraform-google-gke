## Start of cluster.tf variables

variable "name" {
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

variable "addons_config" {
  description = "The configuration of cluster addons."
  type = map(object({
    horizontal_pod_autoscaling_disabled           = optional(bool)
    http_load_balancing_disabled                  = optional(bool)
    kubernetes_dashboard_disabled                 = optional(bool)
    network_policy_config_disabled                = optional(bool)
    gcp_filestore_csi_driver_config_enabled       = optional(bool)
    gcs_fuse_csi_driver_config_enabled            = optional(bool)
    gce_persistent_disk_csi_driver_config_enabled = optional(bool)
    gke_backup_agent_config_enabled               = optional(bool)
    config_connector_config_enabled               = optional(bool)
  }))
  default = null
}

variable "allow_net_admin" {
  description = "Whether to enable network administrator features."
  type        = bool
  default     = null
}

variable "cluster_ipv4_cidr" {
  description = "The IP address range of the Kubernetes pods in this cluster in CIDR notation."
  type        = string
  default     = null
}

variable "cluster_autoscaling" {
  description = "The configuration of cluster autoscaling."
  type = map(object({
    enabled = optional(bool)
    resource_limits = optional(map(object({
      resource_type = string
      minimum       = optional(number)
      maximum       = optional(number)
    })))
    auto_provisioning_defaults = optional(map(object({
      min_cpu_platform = optional(string)
      oauth_scopes     = optional(list(string))
    })))
  }))
  default = null
}

variable "binary_authorization_evaluation_mode" {
  description = "The configuration of cluster binary authorization."
  type        = string
  default     = null

  validation {
    condition     = can(regex("^(DISABLE|PROJECT_SINGLETON_POLICY_ENFORCE)?$", var.binary_authorization_evaluation_mode))
    error_message = "The evaluation mode must be either DISABLE or PROJECT_SINGLETON_POLICY_ENFORCE."
  }
}

variable "service_external_ips_config_enabled" {
  description = "The configuration of cluster service external IPs."
  type        = bool
  default     = null
}

variable "database_encryption" {
  description = "The configuration of cluster database encryption."
  type = map(object({
    state    = string
    key_name = string
  }))
  default = null

  validation {
    condition     = can(regex("^(DECRYPTED|ENCRYPTED)?$", var.database_encryption["state"]))
    error_message = "The database encryption state must be either DECRYPTED or ENCRYPTED."
  }
}

variable "description" {
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

variable "enabled_k8s_beta_apis" {
  description = "A list of Kubernetes Beta APIs to enable."
  type        = list(string)
  default     = null
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
  default     = 1
}

variable "ip_allocation_policy" {
  description = "The configuration of cluster IP allocation policy."
  type = map(object({
    cluster_ipv4_cidr_block       = optional(string)
    cluster_secondary_range_name  = optional(string)
    services_ipv4_cidr_block      = optional(string)
    services_secondary_range_name = optional(string)
    stack_type                    = optional(string)
    additional_pod_ranges_config = optional(map(object({
      pod_range_names = string
    })))
  }))
  default = null
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

variable "logging_config_enabled_components" {
  description = "The configuration of cluster logging."
  type        = list(string)
  default     = null

  validation {
    condition     = can(regex("^(SYSTEM_COMPONENTS|APISERVER|CONTROLLER_MANAGER|SCHEDULER|WORKLOADS)?$", var.logging_config_enabled_components))
    error_message = "The logging component must be either SYSTEM_COMPONENTS, APISERVER, CONTROLLER_MANAGER, SCHEDULER or WORKLOADS."
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

variable "maintenance_policy" {
  description = "The configuration of cluster maintenance policy."
  type = map(object({
    daily_maintenance_window = optional(map(object({
      start_time = string
    })))
    recurring_window = optional(map(object({
      window = optional(map(object({
        start_time = string
        end_time   = string
        recurrence = string
      })))
      maintenance_exclusion = optional(map(object({
        exclusion_name = string
        start_time     = string
        end_time       = string
        exclusion_options = optional(map(object({
          scope = string
        })))
      })))
    })))
  }))
  default = null

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?([+-]\\d{2}:\\d{2}|Z)$", var.maintenance_policy["recurring_window"]["window"]["start_time"]))
    error_message = "The timestamp must be in RFC3339 format"
  }

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?([+-]\\d{2}:\\d{2}|Z)$", var.maintenance_policy["recurring_window"]["window"]["end_time"]))
    error_message = "The timestamp must be in RFC3339 format"
  }

  validation {
    condition     = can(regex("^FREQ=(SECONDLY|MINUTELY|HOURLY|DAILY|WEEKLY|MONTHLY|YEARLY);(COUNT=\\d+|UNTIL=\\d{8}T\\d{6}Z|INTERVAL=\\d+)?(;BYSECOND=\\d+(,\\d+)*|;BYMINUTE=\\d+(,\\d+)*|;BYHOUR=\\d+(,\\d+)*|;BYDAY=((SU|MO|TU|WE|TH|FR|SA)(\\+|-)\\d+)?(,(SU|MO|TU|WE|TH|FR|SA)(\\+|-)\\d+)*|;BYMONTHDAY=\\d+(,\\d+)*|;BYYEARDAY=\\d+(,\\d+)*|;BYWEEKNO=\\d+(,\\d+)*|;BYMONTH=\\d+(,\\d+)*|;BYSETPOS=\\d+(,\\d+)*))*$", var.maintenance_policy["recurring_window"]["window"]["recurrence"]))
    error_message = "The recurrence field must be in RFC5545 format"
  }

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?([+-]\\d{2}:\\d{2}|Z)$", var.maintenance_policy["maintenance_exclusion"]["start_time"]))
    error_message = "The timestamp must be in RFC3339 format"
  }

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?([+-]\\d{2}:\\d{2}|Z)$", var.maintenance_policy["maintenance_exclusion"]["end_time"]))
    error_message = "The timestamp must be in RFC3339 format"
  }

  validation {
    condition     = can(regex("^(NO_UPGRADES|NO_MINOR_UPGRADES|NO_MINOR_OR_NODE_UPGRADES)?$", var.maintenance_policy["window"]["maintenance_exclusion"]["exclusion_options"]["scope"]))
    error_message = "The maintenance exclusion scope must be either NO_UPGRADES, NO_MINOR_UPGRADES or NO_MINOR_OR_NODE_UPGRADES."
  }
}

variable "master_auth_enabled" {
  description = "The configuration of cluster master auth."
  type        = bool
  default     = null
}

variable "master_authorized_networks_config" {
  description = "The configuration of cluster master authorized networks."
  type = map(object({
    cidr_blocks = optional(list(object({
      cidr_block   = optional(string)
      display_name = optional(string)
    })))
    gcp_public_cidrs_access_enabled = optional(bool)
  }))
  default = null
}

variable "min_master_version" {
  description = "The minimum version of the master. GKE will auto-update the master to new versions, so this does not guarantee the current master version. Use the read-only master_version field to obtain that."
  type        = string
  default     = null
}

variable "monitoring_config" {
  description = "The configuration of cluster monitoring."
  type = map(object({
    enable_components = optional(list(string))
    managed_prometheus = optional(map(object({
      enabled = bool
    })))
    advanced_datapath_observability_config = optional(map(object({
      enable_metrics = bool
      relay_mode     = optional(string)

    })))
  }))
  default = null

  validation {
    condition     = can(regex("^(SYSTEM_COMPONENTS|APISERVER|CONTROLLER_MANAGER|SCHEDULER|WORKLOADS)?$", var.monitoring_config["enable_components"]))
    error_message = "The monitoring component must be either SYSTEM_COMPONENTS, APISERVER, CONTROLLER_MANAGER, SCHEDULER or WORKLOADS."
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

variable "network_policy" {
  description = "The configuration of cluster network policy."
  type = map(object({
    provider = optional(string)
    enabled  = bool
  }))
  default = null
}

variable "node_version" {
  description = "The Kubernetes version of the nodes."
  type        = string
  default     = null
}

variable "notification_config" {
  description = "The configuration of cluster notification."
  type = map(object({
    pubsub = optional(map(object({
      enabled = bool
      topic   = optional(string)
      filter = optional(map(object({
        event_types = optional(list(string))
      })))
    })))
  }))
  default = null

  validation {
    condition     = can(regex("^projects/.+/topics/.+$", var.notification_config["pubsub"]["topic"]))
    error_message = "The topic must be in the format of projects/{project}/topics/{topic}."
  }

  validation {
    condition     = can(regex("^(UPGRADE_AVAILABLE_EVENT|UPGRADE_EVENT|SECURITY_BULLETIN_EVENT)?$", var.notification_config["pubsub"]["filter"]["event_types"]))
    error_message = "The event type must be either UPGRADE_AVAILABLE_EVENT, UPGRADE_EVENT or SECURITY_BULLETIN_EVENT."
  }
}

variable "confidential_nodes_enabled" {
  description = "Whether to enable confidential nodes for this cluster."
  type        = bool
  default     = null
}

variable "authenticator_groups_config_security_group" {
  description = "The configuration of cluster authenticator groups."
  type        = string
  default     = null

  validation {
    condition     = can(regex("*@.*", var.authenticator_groups_config_security_group))
    error_message = "The security group must be in the format of gke-security-groups@yourdomain.com."
  }
}

variable "private_cluster_config" {
  description = "The configuration of cluster private cluster."
  type = map(object({
    enable_private_nodes    = optional(bool)
    enable_private_endpoint = optional(bool)
    master_ipv4_cidr_block  = optional(string)
    master_global_access_config = optional(map(object({
      enabled = optional(bool)
    })))
  }))
  default = null
}

variable "project" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "release_channel" {
  description = "The configuration of cluster release channel."
  type        = string
  default     = null

  validation {
    condition     = can(regex("^(UNSPECIFIED|RAPID|REGULAR|STABLE)?$", var.release_channel))
    error_message = "The release channel must be either UNSPECIFIED, RAPID, REGULAR or STABLE."
  }
}

variable "remove_default_node_pool" {
  description = "Whether to remove the default node pool from the cluster."
  type        = bool
  default     = true
}

variable "resource_labels" {
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster."
  type        = map(string)
  default     = null
}

variable "cost_management_config_enabled" {
  description = "Whether the cost allocation feature is enabled."
  type        = bool
  default     = null
}

variable "resource_usage_export_config" {
  description = "The configuration of cluster resource usage export."
  type = map(object({
    enable_network_egress_metering       = optional(bool)
    enable_resource_consumption_metering = optional(bool)
    bigquery_dataset_id                  = string
  }))
  default = null
}

variable "subnetwork" {
  description = "The name or self_link of the Google Compute Engine subnetwork to which the cluster is connected."
  type        = string
  default     = null
}

variable "vertical_pod_autoscaling_enabled" {
  description = "The configuration of cluster vertical pod autoscaling."
  type        = bool
  default     = null
}

variable "workload_identity_config_pool" {
  description = "The configuration of cluster workload identity."
  type        = string
  default     = null
}

variable "enable_intranode_visibility" {
  description = "Whether Intra-node visibility is enabled for this cluster."
  type        = bool
  default     = null
}

variable "enable_l4_ilb_subsetting" {
  description = "Whether L4ILB Subsetting is enabled for this cluster."
  type        = bool
  default     = null
}

variable "private_ipv6_google_access" {
  description = "Whether Private IPv6 Google Access is enabled for this cluster."
  type        = bool
  default     = null
}

variable "datapath_provider" {
  description = "The configuration of cluster datapath provider."
  type        = string
  default     = null

  validation {
    condition     = can(regex("^(LEGACY_DATAPATH|ADVANCED_DATAPATH)?$", var.datapath_provider))
    error_message = "The datapath provider must be either LEGACY_DATAPATH or ADVANCED_DATAPATH."
  }
}

variable "default_snat_status_disabled" {
  description = "Whether default_snat_status is disabled for this cluster."
  type        = bool
  default     = null
}

variable "dns_config" {
  description = "The configuration of cluster DNS."
  type = map(object({
    cluster_dns        = optional(string)
    cluster_dns_scope  = optional(string)
    cluster_dns_domain = optional(string)
  }))
  default = null

  validation {
    condition     = can(regex("^(PROVIDER_UNSPECIFIED|PLATFORM_DEFAULT|CLOUD_DNS)?$", var.dns_config["cluster_dns"]))
    error_message = "The cluster DNS must be either PROVIDER_UNSPECIFIED, PLATFORM_DEFAULT or CLOUD_DNS."
  }

  validation {
    condition     = can(regex("^(DNS_SCOPE_UNSPECIFIED|CLUSTER_SCOPE|VPC_SCOPE)?$", var.dns_config["cluster_dns_scope"]))
    error_message = "The cluster DNS scope must be either DNS_SCOPE_UNSPECIFIED, CLUSTER_SCOPE or VPC_SCOPE."
  }
}

variable "gateway_api_config_channel" {
  description = "Which Gateway Api channel should be used."
  type        = string
  default     = null

  validation {
    condition     = can(regex("^(CHANNEL_DISABLED|CHANNEL_EXPERIMENTAL|CHANNEL_STANDARD)?$", var.gateway_api_config_channel))
    error_message = "The gateway api channel must be either CHANNEL_DISABLED, CHANNEL_EXPERIMENTAL or CHANNEL_STANDARD."
  }
}

variable "security_posture_config" {
  description = "The configuration of cluster security posture."
  type = map(object({
    mode               = optional(string)
    vulnerability_mode = optional(string)
  }))
  default = null

  validation {
    condition     = can(regex("^(DISABLED|BASIC)?$", var.security_posture_config["mode"]))
    error_message = "The security posture mode must be either DISABLED or BASIC."
  }

  validation {
    condition     = can(regex("^(VULNERABILITY_DISABLED|VULNERABILITY_BASIC)?$", var.security_posture_config["vulnerability_mode"]))
    error_message = "The security posture vulnerability mode must be either VULNERABILITY_DISABLED or VULNERABILITY_BASIC."
  }
}

## Start of node.tf variables

variable "node_pool" {
  description = "The configuration of cluster node pool."
  type = map(object({
    cluster  = optional(string)
    location = optional(string)
    autoscaling = optional(map(object({
      min_node_count       = optional(number)
      max_node_count       = optional(number)
      total_min_node_count = optional(number)
      total_max_node_count = optional(number)
      location_policy      = optional(string)
    })))
    initial_node_count = optional(number)
    management = optional(map(object({
      auto_repair  = optional(bool)
      auto_upgrade = optional(bool)
    })))
    max_pods_per_node = optional(number)
    node_locations    = optional(list(string))
    name              = optional(string)
    name_prefix       = optional(string)
    node_config = optional(map(object({
      disk_size_gb                             = optional(number)
      disk_type                                = optional(string)
      ephemeral_storage_local_ssd_config_count = optional(number)
      local_nvme_ssd_block_config_count        = optional(number)
      logging_variant                          = optional(string)
      gcfs_config_enabled                      = optional(bool)
      gvnic_enabled                            = optional(bool)
      image_type                               = optional(string)
      labels                                   = optional(map(string))
      resource_labels                          = optional(map(string))
      local_ssd_count                          = optional(number)
      machine_type                             = optional(string)
      metadata                                 = optional(map(string))
      min_cpu_platform                         = optional(string)
      oauth_scopes                             = optional(list(string))
      preemptible                              = optional(bool)
      reservation_affinity = optional(map(object({
        consume_reservation_type = string
        key                      = optional(string)
        values                   = optional(list(string))
      })))
      spot            = optional(bool)
      service_account = optional(string)
      shielded_instance_config = optional(map(object({
        enable_secure_boot          = optional(bool)
        enable_integrity_monitoring = optional(bool)
      })))
      tags = optional(list(string))
      taint = optional(list(object({
        key    = string
        value  = string
        effect = string
      })))
      workload_metadata_config_mode = optional(string)
      kubelet_config = optional(object({
        cpu_manager_policy   = optional(string)
        cpu_cfs_quota        = optional(bool)
        cpu_cfs_quota_period = optional(string)
        pod_pids_limit       = optional(string)
      }))
      linux_node_config_sysctls = optional(map(string))
      node_group                = optional(string)
      sole_tenant_config = optional(map(object({
        node_affinity = optional(map(object({
          key      = string
          operator = string
          values   = list(string)
        })))
      })))
      advanced_machine_features_threads_per_core = optional(number)
    })))
    network_config = optional(object({
      create_pod_range     = optional(bool)
      enable_private_nodes = optional(bool)
      pod_ipv4_cidr_block  = optional(string)
    }))
    node_count = optional(number)
    upgrade_settings = optional(map(object({
      max_surge       = optional(string)
      max_unavailable = optional(string)
      strategy        = optional(string)
      blue_green_settings = optional(map(object({
        standard_rollout_policy = optional(map(object({
          batch_percentage    = optional(number)
          batch_node_count    = optional(number)
          batch_soak_duration = optional(string)
        })))
      })))
      node_pool_soak_duration = optional(string)
    })))
    version = optional(string)
    placement_policy = optional(map(object({
      type        = optional(string)
      policy_name = optional(string)
    })))
  }))

  validation {
    condition     = can(regex("^(BALANCED|ANY)?$", var.node_pool["autoscaling"]["location_policy"]))
    error_message = "The autoscaling location policy must be either BALANCED or ANY."
  }

  validation {
    condition     = can(regex("^((n1|n2|e2|e2-micro|e2-small|e2-medium|e2-standard)-[a-z]+[0-9]+-[a-z]+[0-9]+)$", var.node_pool["node_config"]["machine_type"]))
    error_message = "The machine type must be a valid Google Machine Type."
  }

  validation {
    condition     = can(regex("^(Intel|AMD|Cascade Lake|Skylake|Broadwell|Haswell|Sandy Bridge|Ivy Bridge|SandyBridge|IvyBridge|Haswell-2|Broadwell-2|Skylake-2|CascadeLake-2|AMD EPYC Rome)$", var.node_pool["node_config"]["min_cpu_platform"]))
    error_message = "The min_cpu_platform must be a valid Google Cloud CPU platform."
  }

  validation {
    condition     = can(regex("^(UNSPECIFIED|NO_RESERVATION|ANY_RESERVATION|SPECIFIC_RESERVATION)?$", var.node_pool["node_config"]["reservation_affinity"]["consume_reservation_type"]))
    error_message = "The consume_reservation_type must be either UNSPECIFIED, NO_RESERVATION, ANY_RESERVATION or SPECIFIC_RESERVATION."
  }

  validation {
    condition     = can(regex("^compute.googleapis.com/[a-z0-9-]+$", var.node_pool["node_config"]["reservation_affinity"]["key"]))
    error_message = "The reservation_affinity key must be in the format compute.googleapis.com/[reservation_name]."
  }

  validation {
    condition     = can(regex("^([a-z](?:[-a-z0-9]{0,61}[a-z0-9])?)$", var.node_pool["node_config"]["service_account"]))
    error_message = "The service account must be a valid Google Cloud service account email."
  }

  validation {
    condition     = can(regex("^(NO_SCHEDULE|PREFER_SCHEDULE|NO_EXECUTE)?$", var.node_pool["node_config"]["taint"]["effect"]))
    error_message = "The taint effect must be either NO_SCHEDULE, PREFER_SCHEDULE or NO_EXECUTE."
  }

  validation {
    condition     = can(regex("^(MODE_UNSPECIFIED|GCE_METADATA|GKE_METADATA)$", var.node_pool["node_config"]["workload_metadata_config_mode"]))
    error_message = "The workload metadata config mode must be either MODE_UNSPECIFIED, GCE_METADATA or GKE_METADATA."
  }

  validation {
    condition     = can(regex("^(none|static)?$", var.node_pool["node_config"]["kubelet_config"]["cpu_manager_policy"]))
    error_message = "The kubelet_config cpu_manager_policy must be either none or static."
  }

  validation {
    condition     = can(regex("^[1-9][0-9]*[nusmhd]{1}$", var.node_pool["node_config"]["kubelet_config"]["cpu_cfs_quota_period"]))
    error_message = "The kubelet_config cpu_cfs_quota_period must be a positive duration with time units: ns, us, ms, s, m, h."
  }

  validation {
    condition     = can(regex("^(102[4-9]|10[3-9][0-9]|[2-3][0-9]{3}|419[0-3][0-9]|419430[0-4])$", var.node_pool["node_config"]["kubelet_config"]["pod_pids_limit"]))
    error_message = "The kubelet_config pod_pids_limit must be between 1024 and 4194304."
  }

  validation {
    condition     = can(regex("^(COMPACT)$", var.node_pool["placement_policy"]["type"]))
    error_message = "The placement_policy type must be COMPACT."
  }
}

## Cloud router

variable "router_name" {
  description = "The name of the router."
  type        = string
  default     = null
}
