resource "google_service_account" "cloudrun_invoker" {
  account_id   = "bowerbird-singlem-processing-cloudrun-invoker"
  project = var.project
}

resource "google_service_account" "cloudrun_executor" {
  account_id   = "bowerbird-singlem-processing-cloudrun-executor"
  project = var.project
}

resource "google_project_iam_binding" "cloudrun_executor_biquery_role" {
  project = var.project
  role    = "roles/editor"
  members = [
    "serviceAccount:${google_service_account.cloudrun_executor.email}"
  ]
}
