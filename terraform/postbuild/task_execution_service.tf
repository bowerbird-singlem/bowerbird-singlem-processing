resource "google_pubsub_topic" "task_execution_requests" {
  name = "bb-core-task-execution-requests"
  project = var.project
}

resource "google_pubsub_topic" "task_execution_updates" {
  name = "bb-core-task-execution-updates"
  project = var.project
}

resource "google_cloud_tasks_queue" "task_execution_update_tasks" {
  name = "bb-core-task-execution-updates"
  location = "us-central1"
}


resource "random_id" "task_execution_executor_id" {
  byte_length = 4
}

resource "google_service_account" "task_execution_executor" {
  account_id   = "bb-core-task-run${random_id.task_execution_executor_id.dec}"
  project = var.project
}

resource "google_project_iam_member" "task_execution_executor_can_run_lifesciences" {     
  project = var.project
  role    = "roles/lifesciences.workflowsRunner"
  member = "serviceAccount:${google_service_account.task_execution_executor.email}"
}

resource "google_project_iam_member" "task_execution_executor_can_use_storage" {
  project = var.project
  role    = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.task_execution_executor.email}"
}

resource "google_project_iam_member" "task_execution_executor_can_send_pubsub_messages" {
  project = var.project
  role    = "roles/pubsub.admin"
  member = "serviceAccount:${google_service_account.task_execution_executor.email}"
}

resource "google_service_account_iam_member" "task_execution_executor_can_impersonate_lifesciences_executor" {
  service_account_id = google_service_account.lifesciences_executor.name
  role               = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.task_execution_executor.email}"
}

resource "google_cloud_run_service" "task_execution_service" {
  name     = "bb-core-task-execution"
  location = var.region

  template {
    spec {
      container_concurrency = 10
      containers {
        image = "us-central1-docker.pkg.dev/${var.project}/${var.repository}/task-execution-service"
      }
      service_account_name = "${google_service_account.task_execution_executor.email}"
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

resource "google_cloud_run_service_iam_binding" "task_execution_binding" {
  location = google_cloud_run_service.task_execution_service.location
  project = google_cloud_run_service.task_execution_service.project
  service = google_cloud_run_service.task_execution_service.name
  role = "roles/run.invoker"
  members  = concat(var.members, ["serviceAccount:${google_service_account.cloudrun_invoker.email}"])
  depends_on = [
    google_project_service.cloudrun-gcp-service,
  ]
}

resource "google_pubsub_subscription" "task_execution_requests_subscription" {
  name  = "bb-core-task-execution-requests-subscription"
  topic = google_pubsub_topic.task_execution_requests.name

  ack_deadline_seconds = 60

  push_config {
    push_endpoint = "${google_cloud_run_service.task_execution_service.status[0].url}/newtask"
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

resource "google_pubsub_subscription" "task_execution_updates_subscription" {
  name  = "bb-core-task-execution-updates-subscription"
  topic = google_pubsub_topic.task_execution_updates.name

  ack_deadline_seconds = 60

  push_config {

    push_endpoint = "${google_cloud_run_service.task_execution_service.status[0].url}/taskupdate"
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
