resource "google_pubsub_topic" "get_new_sra_runs_requests" {
  name = "bb-singlem-processing-get-new-sra-runs-requests"
  project = var.project
  depends_on = [
    google_project_service.pubsub-gcp-service,
  ]
}

resource "google_cloud_run_service" "get_new_sra_runs" {
  name     = "bb-singlem-proc-get-new-sra-runs"
  location = var.region

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/maximal-dynamo-308105/${var.repository}/get-new-sra-runs"
      }
      service_account_name = "${google_service_account.get_new_sra_runs_executor.email}"
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  depends_on = [
    google_project_service.cloudrun-gcp-service,    
  ]
}

resource "google_cloud_run_service_iam_binding" "binding" {
  location = google_cloud_run_service.get_new_sra_runs.location
  project = google_cloud_run_service.get_new_sra_runs.project
  service = google_cloud_run_service.get_new_sra_runs.name
  role = "roles/run.invoker"
  members  = concat(var.members, ["serviceAccount:${google_service_account.cloudrun_invoker.email}"])
  depends_on = [
    google_project_service.cloudrun-gcp-service,
  ]
}

resource "google_pubsub_subscription" "get_new_sra_runs_requests_subscription" {
  name  = "bb-singlem-processing-get-new-sra-runs-requests-subscription"
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
