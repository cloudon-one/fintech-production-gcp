output "cluster_name" {
  description = "The name of the cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_id" {
  description = "The ID of the cluster"
  value       = google_container_cluster.primary.id
}

output "cluster_endpoint" {
  description = "The IP address of the cluster endpoint"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  sensitive   = true
}

output "service_account_email" {
  description = "The email of the service account created for the cluster"
  value       = var.create_service_account ? google_service_account.gke_service_account[0].email : null
}

output "node_pools" {
  description = "List of node pools"
  value = {
    for name, pool in google_container_node_pool.node_pools : name => {
      name       = pool.name
      node_count = pool.node_count
      locations  = pool.location
    }
  }
}

output "instance_group_urls" {
  description = "Map of node pool names to their instance group URLs"
  value = {
    for name, pool in google_container_node_pool.node_pools : name => pool.instance_group_urls
  }
} 