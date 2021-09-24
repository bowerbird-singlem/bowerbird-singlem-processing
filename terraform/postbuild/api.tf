resource "google_project_service" "cloudrun-gcp-service" {
  service = "run.googleapis.com"
  project = var.project
  disable_on_destroy = false
}
resource "google_project_service" "pubsub-gcp-service" {
  service = "pubsub.googleapis.com"
  project = var.project
  disable_on_destroy = false
}
resource "google_project_service" "bigquery-gcp-service" {
  service = "bigquery.googleapis.com"
  project = var.project
  disable_on_destroy = false
}

resource "google_project_service" "iam-gcp-service" {
  service = "iam.googleapis.com"
  project = var.project
  disable_on_destroy = false
}

resource "google_project_service" "lifesciences-gcp-service" {
  service = "lifesciences.googleapis.com"
  project = var.project
  disable_on_destroy = false
}

