resource "google_project_service" "registry-gcp-service" {
  service = "artifactregistry.googleapis.com"
  project = var.project
  disable_on_destroy = false
}
