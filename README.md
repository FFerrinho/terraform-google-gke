## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_container_cluster.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_compute_zones.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_project.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addons_config"></a> [addons\_config](#input\_addons\_config) | The addons configuration for the cluster. | <pre>object({<br>    disable_horizontal_pod_autoscaling = bool<br>    disable_http_load_balancing        = bool<br>    disable_network_policy_config      = bool<br>    enable_gcp_filestore_csi_driver    = bool<br>    enable_gcs_fuse_csi_driver         = bool<br>    cloudrun_config = optional(object({<br>      disable_cloudrun_config = bool<br>      load_balancer_type      = string<br>    }))<br>  })</pre> | <pre>{<br>  "cloudrun_config": null,<br>  "disable_horizontal_pod_autoscaling": false,<br>  "disable_http_load_balancing": false,<br>  "disable_network_policy_config": false,<br>  "enable_gcp_filestore_csi_driver": false,<br>  "enable_gcs_fuse_csi_driver": false<br>}</pre> | no |
| <a name="input_allow_net_admin"></a> [allow\_net\_admin](#input\_allow\_net\_admin) | If NET\_ADMIN is enabled for the cluster. | `bool` | `false` | no |
| <a name="input_authenticator_groups_config"></a> [authenticator\_groups\_config](#input\_authenticator\_groups\_config) | The authenticator groups configuration for the cluster. | <pre>object({<br>    security_group = string<br>  })</pre> | `null` | no |
| <a name="input_cluster_autoscaling"></a> [cluster\_autoscaling](#input\_cluster\_autoscaling) | The cluster autoscaling configuration for the cluster. | <pre>object({<br>    enable_cluster_autoscaling = bool<br>    resource_limits = optional(set(object({<br>      resource_type = string<br>      minimum       = number<br>      maximum       = number<br>    })))<br>    auto_auto_provisioning_defaults = optional(object({<br>      service_account = optional(string)<br>      disk_size_gb    = optional(number)<br>      disk_type       = optional(string)<br>      image_type      = optional(string)<br>      management = optional(object({<br>        auto_upgrade = bool<br>        auto_repair  = bool<br>      }))<br>      upgrade_settings = optional(object({<br>        strategy        = string<br>        max_surge       = number<br>        max_unavailable = number<br>      }))<br>    }))<br>  })</pre> | <pre>{<br>  "auto_auto_provisioning_defaults": {<br>    "management": null,<br>    "upgrade_settings": {<br>      "max_surge": 1,<br>      "max_unavailable": 0,<br>      "strategy": "SURGE"<br>    }<br>  },<br>  "enable_cluster_autoscaling": false,<br>  "resource_limits": null<br>}</pre> | no |
| <a name="input_cluster_description"></a> [cluster\_description](#input\_cluster\_description) | The description of the cluster. | `string` | `null` | no |
| <a name="input_cluster_location"></a> [cluster\_location](#input\_cluster\_location) | The location of the cluster. This can be a region or a zone. | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster. | `string` | n/a | yes |
| <a name="input_cluster_subnetwork"></a> [cluster\_subnetwork](#input\_cluster\_subnetwork) | The subnetwork for the cluster. | `string` | n/a | yes |
| <a name="input_default_node_config"></a> [default\_node\_config](#input\_default\_node\_config) | Parameters for the default node pool. | <pre>object({<br>    preemptible     = optional(bool)<br>    spot            = optional(bool)<br>    service_account = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_dns_config"></a> [dns\_config](#input\_dns\_config) | The DNS configuration for the cluster. | <pre>object({<br>    additive_vpc_scope_dns_domain = optional(string)<br>    cluster_dns                   = string<br>    cluster_dns_scope             = optional(string)<br>    cluster_dns_domain            = optional(string)<br>  })</pre> | <pre>{<br>  "additive_vpc_scope_dns_domain": null,<br>  "cluster_dns": "PLATFORM_DEFAULT",<br>  "cluster_dns_domain": null,<br>  "cluster_dns_scope": null<br>}</pre> | no |
| <a name="input_enable_autopilot"></a> [enable\_autopilot](#input\_enable\_autopilot) | If autopilot is enabled for the cluster. | `bool` | `false` | no |
| <a name="input_enable_cluster_deletion_protection"></a> [enable\_cluster\_deletion\_protection](#input\_enable\_cluster\_deletion\_protection) | If Terraform is allowed to delete the cluster. | `bool` | `false` | no |
| <a name="input_gateway_api_channel"></a> [gateway\_api\_channel](#input\_gateway\_api\_channel) | Enables GKE Gateway API support. | `string` | `"CHANNEL_STANDARD"` | no |
| <a name="input_initial_node_count"></a> [initial\_node\_count](#input\_initial\_node\_count) | The initial node count for the cluster. | `number` | `1` | no |
| <a name="input_ip_allocation_policy"></a> [ip\_allocation\_policy](#input\_ip\_allocation\_policy) | The IP allocation policy configuration for the cluster. | <pre>object({<br>    cluster_secondary_range_name  = string<br>    services_secondary_range_name = string<br>    cluster_ipv4_cidr_block       = string<br>    services_ipv4_cidr_block      = string<br>    stack_type                    = string<br>  })</pre> | n/a | yes |
| <a name="input_kubernetes_release_channel"></a> [kubernetes\_release\_channel](#input\_kubernetes\_release\_channel) | The Kubernetes release channel for the cluster. | `string` | `"UNSPECIFIED"` | no |
| <a name="input_maintenance_policy"></a> [maintenance\_policy](#input\_maintenance\_policy) | The maintenance policy configuration for the cluster. | <pre>object({<br>    daily_maintenance_window = optional(object({<br>      start_time = string<br>    }))<br>    recurring_window = optional(object({<br>      start_time = string<br>      end_time   = string<br>      recurrence = string<br>    }))<br>    maintenance_exclusion = optional(set(object({<br>      exclusion_name = string<br>      start_time     = string<br>      end_time       = string<br>      exclusion_options = optional(object({<br>        scope = string<br>      }))<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_master_authorized_networks_config"></a> [master\_authorized\_networks\_config](#input\_master\_authorized\_networks\_config) | The master authorized networks configuration for the cluster. | <pre>object({<br>    cidr_blocks = optional(set(object({<br>      cidr_block   = string<br>      display_name = string<br>    })))<br>    gcp_public_cidrs_access_enabled = bool<br>  })</pre> | <pre>{<br>  "cidr_blocks": null,<br>  "gcp_public_cidrs_access_enabled": false<br>}</pre> | no |
| <a name="input_max_pods_per_node"></a> [max\_pods\_per\_node](#input\_max\_pods\_per\_node) | The maximum number of pods per node for the cluster. | `number` | `null` | no |
| <a name="input_min_master_version"></a> [min\_master\_version](#input\_min\_master\_version) | The minimum master version for the cluster. | `string` | `null` | no |
| <a name="input_network"></a> [network](#input\_network) | The network for the cluster. | `string` | n/a | yes |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | The network policy configuration for the cluster. | <pre>object({<br>    provider = string<br>    enabled  = bool<br>  })</pre> | `null` | no |
| <a name="input_networking_mode"></a> [networking\_mode](#input\_networking\_mode) | The networking mode for the cluster. | `string` | `"VPC_NATIVE"` | no |
| <a name="input_node_config"></a> [node\_config](#input\_node\_config) | The node configuration for the cluster. | <pre>object({<br>    disk_size_gb        = optional(number)<br>    disk_type           = optional(string)<br>    image_type          = optional(string)<br>    machine_type        = optional(string)<br>    preemptible_enabled = optional(bool) # Deprecated, if required, evaluate using spot instead.<br>    spot_enabled        = optional(bool)<br>    service_account     = optional(string)<br>    tags                = set(string)<br>    node_group          = optional(string)<br>    gcfs_config_enabled = bool<br>    gvnic_enabled       = bool<br>    taint = optional(set(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    })))<br>  })</pre> | <pre>{<br>  "disk_size_gb": null,<br>  "disk_type": null,<br>  "gcfs_config_enabled": false,<br>  "gvnic_enabled": true,<br>  "image_type": null,<br>  "machine_type": null,<br>  "node_group": null,<br>  "preemptible_enabled": null,<br>  "service_account": null,<br>  "spot_enabled": null,<br>  "tags": null,<br>  "taint": null<br>}</pre> | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | The number of nodes in the node pool. | `number` | `null` | no |
| <a name="input_node_locations"></a> [node\_locations](#input\_node\_locations) | The location for the nodes. When defining this value, the cluster location is omitted. | `set(string)` | `null` | no |
| <a name="input_node_pool"></a> [node\_pool](#input\_node\_pool) | A map to create node pools attached to the cluster. | <pre>map(object({<br>    initial_node_count = number<br>    node_locations     = set(string)<br>    node_pool_name     = string<br>  }))</pre> | `null` | no |
| <a name="input_node_pool_auto_config"></a> [node\_pool\_auto\_config](#input\_node\_pool\_auto\_config) | The node pool auto configuration for the cluster with autopilot. | <pre>object({<br>    node_kubelet_config = optional(object({<br>      insecure_kubelet_readonly_port_enabled = string<br>    }))<br>    resource_manager_tags = optional(map(string))<br>    network_tags          = optional(set(string))<br>  })</pre> | `{}` | no |
| <a name="input_node_pool_auto_repair_enabled"></a> [node\_pool\_auto\_repair\_enabled](#input\_node\_pool\_auto\_repair\_enabled) | If node pool auto repair is enabled for the cluster. | `bool` | `true` | no |
| <a name="input_node_pool_auto_upgrade_enabled"></a> [node\_pool\_auto\_upgrade\_enabled](#input\_node\_pool\_auto\_upgrade\_enabled) | If node pool auto upgrade is enabled for the cluster. | `bool` | `false` | no |
| <a name="input_node_pool_autoscaling"></a> [node\_pool\_autoscaling](#input\_node\_pool\_autoscaling) | The node pool autoscaling configuration for the cluster. | <pre>object({<br>    min_node_count       = number<br>    max_node_count       = number<br>    total_min_node_count = number<br>    total_max_node_count = number<br>    location_policy      = string<br>  })</pre> | <pre>{<br>  "location_policy": "BALANCED",<br>  "max_node_count": 1,<br>  "min_node_count": 1,<br>  "total_max_node_count": 1,<br>  "total_min_node_count": 1<br>}</pre> | no |
| <a name="input_node_pool_defaults"></a> [node\_pool\_defaults](#input\_node\_pool\_defaults) | The node pool defaults configuration for the cluster. | <pre>object({<br>    insecure_kubelet_readonly_port_enabled = string<br>    gcfs_config_enabled                    = bool<br>  })</pre> | <pre>{<br>  "gcfs_config_enabled": false,<br>  "insecure_kubelet_readonly_port_enabled": "FALSE"<br>}</pre> | no |
| <a name="input_node_pool_name_prefix"></a> [node\_pool\_name\_prefix](#input\_node\_pool\_name\_prefix) | The prefix of the node pool name. This will preffix the random unique name if node\_pool\_name is not provided. | `string` | `null` | no |
| <a name="input_private_cluster_config"></a> [private\_cluster\_config](#input\_private\_cluster\_config) | The private cluster configuration for the cluster. | <pre>object({<br>    enable_private_nodes         = bool<br>    enable_private_endpoint      = bool<br>    master_ipv4_cidr_block       = optional(string)<br>    private_endpoint_subnetwork  = optional(string)<br>    master_global_access_enabled = bool<br>  })</pre> | <pre>{<br>  "enable_private_endpoint": false,<br>  "enable_private_nodes": false,<br>  "master_global_access_enabled": false,<br>  "master_ipv4_cidr_block": null,<br>  "private_endpoint_subnetwork": null<br>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID where the resources will be provisioned. | `string` | n/a | yes |
| <a name="input_remove_default_node_pool"></a> [remove\_default\_node\_pool](#input\_remove\_default\_node\_pool) | If the default node pool should be removed. | `bool` | `true` | no |
| <a name="input_resource_labels"></a> [resource\_labels](#input\_resource\_labels) | The resource labels for the cluster. | `map(string)` | <pre>{<br>  "provisioned_by": "terraform"<br>}</pre> | no |
| <a name="input_secret_manager_enabled"></a> [secret\_manager\_enabled](#input\_secret\_manager\_enabled) | If secret manager is enabled for the cluster. | `bool` | `false` | no |
| <a name="input_service_external_ips_config"></a> [service\_external\_ips\_config](#input\_service\_external\_ips\_config) | The service external IPs configuration for the cluster. | <pre>object({<br>    enabled = bool<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_upgrade_settings"></a> [upgrade\_settings](#input\_upgrade\_settings) | The upgrade settings for the cluster. | <pre>object({<br>    max_surge       = number<br>    max_unavailable = number<br>  })</pre> | <pre>{<br>  "max_surge": 1,<br>  "max_unavailable": 0<br>}</pre> | no |
| <a name="input_vertical_pod_autoscaling_enabled"></a> [vertical\_pod\_autoscaling\_enabled](#input\_vertical\_pod\_autoscaling\_enabled) | If vertical pod autoscaling is enabled for the cluster. | `bool` | `false` | no |
| <a name="input_workload_identity_config"></a> [workload\_identity\_config](#input\_workload\_identity\_config) | The workload identity configuration for the cluster. | <pre>object({<br>    workload_pool = string<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | The client certificate used to authenticate to the Kubernetes cluster |
| <a name="output_client_key"></a> [client\_key](#output\_client\_key) | The client key used to authenticate to the Kubernetes cluster |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | The CA certificate of the Kubernetes cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | The endpoint of the Kubernetes cluster |
| <a name="output_cluster_ipv4_cidr"></a> [cluster\_ipv4\_cidr](#output\_cluster\_ipv4\_cidr) | The IP address range of the Kubernetes pods |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the Kubernetes cluster |
| <a name="output_deprecation_warnings"></a> [deprecation\_warnings](#output\_deprecation\_warnings) | n/a |
| <a name="output_node_pools"></a> [node\_pools](#output\_node\_pools) | The list of node pools in the Kubernetes cluster |
| <a name="output_services_ipv4_cidr"></a> [services\_ipv4\_cidr](#output\_services\_ipv4\_cidr) | The IP address range of the Kubernetes services |
