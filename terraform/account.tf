resource "google_service_account" "n8n_runner" {
  account_id   = "${var.service_name}-runner"
  display_name = "PageManager n8n Cloud Run Runner"
}

resource "google_service_account" "scheduler" {
  account_id   = "${var.service_name}-scheduler"
  display_name = "PageManager n8n Cloud Scheduler"
}