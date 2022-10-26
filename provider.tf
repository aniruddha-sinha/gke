terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.41.0, < 5.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}