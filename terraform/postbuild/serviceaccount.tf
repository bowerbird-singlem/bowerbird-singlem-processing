resource "google_service_account" "cloudrun_invoker" {
  account_id   = "bb-singlem-proc-cr-invoker"
  project = var.project
}

resource "google_service_account" "lifesciences_executor" {
  account_id   = "bb-singlem-proc-ls-executor"
  project = var.project
}

resource "google_project_iam_binding" "lifesciences_executor_can_do_anything" {
  project = var.project
  role    = "roles/editor"
  members = [
    "serviceAccount:${google_service_account.lifesciences_executor.email}"
  ]
}

resource "google_project_iam_binding" "lifesciences_executor_can_use_storage" {
  project = var.project
  role    = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${google_service_account.lifesciences_executor.email}"
  ]
}
