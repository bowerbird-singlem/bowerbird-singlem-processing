resource "google_service_account" "cloudrun_invoker" {
  account_id   = "bb-singlem-proc-cr-invoker"
  project = var.project
}

# get new sra runs cloudrun 

resource "google_service_account" "get_new_sra_runs_executor" {
  account_id   = "bb-sing-proc-get-new-sra"
  project = var.project
}

resource "google_project_iam_binding" "get_new_sra_runs_executor_bigquery_role" {
  project = var.project
  role    = "roles/editor"
  members = [
    "serviceAccount:${google_service_account.get_new_sra_runs_executor.email}"
  ]
}

# run singlem analysis cloudrun

resource "google_service_account" "run_singlem_analysis_executor" {
  account_id   = "bb-sing-proc-run-singlem"
  project = var.project
}

