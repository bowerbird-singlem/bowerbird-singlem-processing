resource "google_service_account" "cloudrun_invoker" {
  account_id   = "bb-singlem-proc-cr-invoker"
  project = var.project
}

resource "google_service_account" "get_new_sra_runs_executor" {
  account_id   = "bb-singlem-proc-get-new-sra-runs"
  project = var.project
}

resource "google_project_iam_binding" "get_new_sra_runs_executor_biquery_role" {
  project = var.project
  role    = "roles/editor"
  members = [
    "serviceAccount:${google_service_account.get_new_sra_runs_executor.email}"
  ]
}
