resource "google_artifact_registry_repository" "repository" {
    provider = google-beta
    location = var.region
    repository_id = var.repository
    format = "DOCKER"
    depends_on = [
      google_project_service.registry-gcp-service,
      google_project_service.service-usage-gcp-service
    ]
}
