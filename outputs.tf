locals {
  show_preemptible_warning = var.node_config != null && var.node_config.preemptible_enabled == true
}

output "deprecation_warnings" {
  value = local.show_preemptible_warning ? {
    preemptible = "⚠️ Warning: Preemptible VMs are being deprecated by Google. Please consider using Spot VMs instead by setting spot_enabled = true"
  } : null
}
