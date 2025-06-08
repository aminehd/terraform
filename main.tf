terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
  default = "us-central1"
}

# Enable Cloud Run API
resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

# Cloud Run service
resource "google_cloud_run_v2_service" "app" {
  name     = "leetcode-harvester"
  location = var.region

  template {
    containers {
      image = "gcr.io/${var.project_id}/leetcode-harvester:latest"
      
      ports {
        container_port = 8080
      }
    }
  }

  depends_on = [google_project_service.run]
}

# Allow public access
resource "google_cloud_run_v2_service_iam_member" "public" {
  location = google_cloud_run_v2_service.app.location
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Output the URL
output "url" {
  value = google_cloud_run_v2_service.app.uri
}

