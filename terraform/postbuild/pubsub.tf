resource "google_pubsub_topic" "get_new_sra_runs_requests" {
  name = "bowerbird_singlem_processing_get_new_sra_runs_requests"
  project = var.project
  depends_on = [
    google_project_service.pubsub-gcp-service,
  ]
}

resource "google_pubsub_subscription" "get_new_sra_runs_requests_subscription" {
  name  = "bowerbird_singlem_processing_get_new_sra_runs_requests_subscription"
  topic = google_pubsub_topic.get_new_sra_runs_requests.name

  ack_deadline_seconds = 20

  push_config {
    push_endpoint = google_cloud_run_service.get_new_sra_runs.status[0].url
    oidc_token {
      service_account_email = google_service_account.cloudrun_invoker.email
    }

    attributes = {
      x-goog-version = "v1"
    }
  }
  depends_on = [
    google_project_service.pubsub-gcp-service,
  ]
}
