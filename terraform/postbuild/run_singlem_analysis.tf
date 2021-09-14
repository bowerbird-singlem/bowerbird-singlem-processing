resource "google_pubsub_topic" "run_singlem_analysis_requests" {
  name = "bb-singlem-processing-run-singlem-analysis-requests"
  project = var.project
  depends_on = [
    google_project_service.pubsub-gcp-service,
  ]
}

resource "google_pubsub_topic" "run_singlem_analysis_updates" {
  name = "bb-singlem-processing-run-singlem-analysis-updates"
  project = var.project
  depends_on = [
    google_project_service.pubsub-gcp-service,
  ]
}

resource "google_service_account" "run_singlem_analysis_executor" {
  account_id   = "bb-sing-proc-run-singlem"
  project = var.project
}

resource "google_project_iam_binding" "run_singlem_analysis_executor_can_run_lifesciences" {
  project = var.project
  role    = "roles/lifesciences.workflowsRunner"
  members = [
    "serviceAccount:${google_service_account.run_singlem_analysis_executor.email}"
  ]
}

resource "google_service_account_iam_binding" "run_singlem_analysis_executor_can_impersonate_lifesciences_executor" {
  service_account_id = google_service_account.lifesciences_executor.name
  role               = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.run_singlem_analysis_executor.email}",
  ]
}

resource "google_cloud_run_service" "run_singlem_analysis" {
  name     = "bb-singlem-proc-run-singlem-analysis"
  location = var.region

  template {
    spec {
      container_concurrency = 1 
      containers {
        image = "us-central1-docker.pkg.dev/maximal-dynamo-308105/${var.repository}/run-singlem-analysis"
      }
      service_account_name = "${google_service_account.run_singlem_analysis_executor.email}"
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "1"
      }
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

resource "google_cloud_run_service_iam_binding" "run_singlem_analysis_binding" {
  location = google_cloud_run_service.run_singlem_analysis.location
  project = google_cloud_run_service.run_singlem_analysis.project
  service = google_cloud_run_service.run_singlem_analysis.name
  role = "roles/run.invoker"
  members  = concat(var.members, ["serviceAccount:${google_service_account.cloudrun_invoker.email}"])
  depends_on = [
    google_project_service.cloudrun-gcp-service,
  ]
}

resource "google_pubsub_subscription" "run_singlem_analysis_requests_subscription" {
  name  = "bb-singlem-processing-run-singlem-analysis-requests-subscription"
  topic = google_pubsub_topic.run_singlem_analysis_requests.name

  ack_deadline_seconds = 20

  push_config {
    push_endpoint = "${google_cloud_run_service.run_singlem_analysis.status[0].url}/newtask"
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

resource "google_pubsub_subscription" "run_singlem_analysis_updates_subscription" {
  name  = "bb-singlem-processing-run-singlem-analysis-updates-subscription"
  topic = google_pubsub_topic.run_singlem_analysis_updates.name

  ack_deadline_seconds = 20

  push_config {

    push_endpoint = "${google_cloud_run_service.run_singlem_analysis.status[0].url}/taskupdate"
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
