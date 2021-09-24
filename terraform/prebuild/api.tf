resource "google_project_service" "registry-gcp-service" {
  service = "artifactregistry.googleapis.com"
  project = var.project
  disable_on_destroy = false
}

resource "google_project_service" "service-usage-gcp-service" {
  service = "serviceusage.googleapis.com"
  project = var.project
  disable_on_destroy = false
}

