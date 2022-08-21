output "endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

output "cluster_ca_certificate" {
  value = google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate
}

output "cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "region" {
  value = var.location
}

output "project_id" {
  value = var.project_id
}