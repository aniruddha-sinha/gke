data "google_service_account" "custom_service_account" {
  account_id = var.service_account_id
  project    = var.project_id
}

data "google_compute_network" "gke_network" {
  name    = "vpc-${var.project_id}"
  project = var.project_id
}

data "google_compute_subnetwork" "gke_subnetwork" {
  name    = "subnet-us-0"
  project = var.project_id
  region  = var.region_preference
}

resource "google_container_cluster" "gke_cluster" {
  provider                 = google-beta
  name                     = var.autopilot_enabled ? "gke-autopilot-${var.project_id}" : "gke-standard-${var.project_id}"
  project                  = var.project_id
  location                 = (var.cluster_type == "region" || var.autopilot_enabled) ? var.region_preference : var.zone_preference
  initial_node_count       = var.autopilot_enabled ? null : 1
  remove_default_node_pool = var.autopilot_enabled ? null : true #if autopilot enabled this parameter must not exist thereby nullifying
  network                  = data.google_compute_network.gke_network.name
  subnetwork               = data.google_compute_subnetwork.gke_subnetwork.name
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  /*
    Enable autopilot conflicts with remove default node pool
    therefore nullifying the boolean variable if the autopilot mode is turned off
  */
  enable_autopilot = var.autopilot_enabled ? true : null

  /*
    The block below *** ip_allocation_policy {} *** is the Workaround for the following error
    Error: googleapi: Error 400: Max pods constraint on node pools for Autopilot clusters should be 32., badRequest
    */
  ip_allocation_policy {}

  // Enable workload identity
  dynamic "workload_identity_config" {
    for_each = var.autopilot_enabled ? [] : [1]
    content {
      workload_pool = format("%s.svc.id.goog", var.project_id)
    }
  }

  /* Enable network policy configurations (like Calico) - for some reason this
   has to be in here twice. */
  dynamic "network_policy" {
    for_each = var.autopilot_enabled ? [] : [1]
    content {
      enabled = true
    }
  }

  // Configure the cluster to have private nodes and private control plane access only
  private_cluster_config {
    enable_private_endpoint = "false"
    enable_private_nodes    = "true"
    master_ipv4_cidr_block  = "172.16.0.16/28"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = "false"
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      display_name = var.master_auth_ip_whitelisting_name
      cidr_block   = format("%s/32", var.public_ip_address_of_the_system)
    }
  }
}

resource "google_container_node_pool" "node_pool" {
  provider   = google-beta
  count      = var.autopilot_enabled ? 0 : 1
  name       = "gke-node-pool-${var.project_id}"
  project    = var.project_id
  location   = (var.cluster_type == "region" || var.autopilot_enabled) ? var.region_preference : var.zone_preference
  cluster    = google_container_cluster.gke_cluster.name
  node_count = 3

  node_config {
    preemptible  = var.preemptible
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size_in_gb
    image_type   = "COS"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = data.google_service_account.custom_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}