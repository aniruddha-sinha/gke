variable "project_id" {
  type        = string
  description = "The project ID where the GKE cluster will be created"
}

variable "autopilot_enabled" {
  type        = bool
  description = "Defaults to false : create standard Cluster else create autopilot GKE cluster"
  default     = false
}

variable "location" {
  type        = string
  description = "defaults to us-central1-a which is a zonal cluster; this location does accept region thereby making it a regional cluster"
  default     = "us-central1"
}

variable "service_account_id" {
  type        = string
  description = "service account id"
}

variable "custom_labels" {
  type        = map(string)
  description = "custom labels which can be passed into the cluster"
  default     = {}
}

variable "network_tags" {
  type        = list(string)
  description = "network tags"
  default     = []
}

variable "master_auth_ip_whitelisting_name" {
  type        = string
  description = "the name of the whitelisted address block"
}

variable "public_ip_address_of_the_system" {
  type        = string
  description = "the laptops public ip address which will be using the cluster"
}

variable "preemptible" {
  type        = bool
  description = "does the node need to be preemptible?"
  default     = true
}

variable "node_machine_type" {
  type        = string
  description = "machine type of the node in the node pool"
  default     = "n1-standard-1"
}

variable "node_disk_size_in_gb" {
  type        = string
  description = "size of the disk in Gigabytes"
  default     = "50"
}