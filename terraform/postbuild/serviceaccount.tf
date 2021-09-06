resource "google_service_account" "cloudrun_invoker" {
  account_id   = "bb-singlem-proc-cr-invoker"
  project = var.project
}
