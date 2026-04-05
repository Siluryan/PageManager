resource "google_cloud_scheduler_job" "n8n_saturday_trigger" {
  name             = "${var.service_name}-saturday-trigger"
  description      = "PageManager — sábado 12:00 BRT"
  schedule         = "0 12 * * 6"
  time_zone        = "America/Sao_Paulo"
  attempt_deadline = "180s"

  retry_config {
    retry_count          = 2
    min_backoff_duration = "30s"
    max_backoff_duration = "120s"
  }

  http_target {
    http_method = "POST"
    uri         = "${local.n8n_uri}/webhook/${var.webhook_path}"

    body = base64encode(jsonencode({
      source  = "cloud-scheduler"
      trigger = "saturday-post"
    }))

    headers = {
      "Content-Type" = "application/json"
    }

    oidc_token {
      service_account_email = google_service_account.scheduler.email
      audience              = local.n8n_uri
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_cloud_run_v2_service.n8n,
  ]
}