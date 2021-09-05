resource "google_cloud_run_service" "get_new_sra_runs" {
  name     = "bb-singlem-proc-get-new-sra-runs"
  location = var.region

  template {
    spec {
      containers {
        image = "us-central1-docker.pkg.dev/maximal-dynamo-308105/${var.repository}/${var.service}"
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

