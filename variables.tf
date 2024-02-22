variable "name" {
  description = "The name for the GKE cluster."
  type        = string
}

variable "location" {
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
  type = set(string)
  default = []
}

variable "deletion_protection" {
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
  description = "The IP address range for the pods in this cluster."
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
    horizontal_pod_autoscaling = object({
      disabled = bool
    })
    http_load_balancing = object({
      disabled = bool
    })
    network_policy_config = object({
      disabled = bool 
    })
    gcp_filestore_csi_driver_config = object({
      enabled = bool
    })
    gcs_fuse_csi_driver_config = object({
      enabled = bool
    })
    cloudrun_config = object({
      disabled = bool
      load_balancer_type = string
    })
  })
  default = null
}

variable "database_encryption" {
  description = "The database encryption config for the GKE cluster."
  type = object({
    state = string
    key_name = string
  })
  default = null
}
