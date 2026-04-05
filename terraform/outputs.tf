output "n8n_url" {
  value = google_cloud_run_v2_service.n8n.uri
}

output "n8n_webhook_url" {
  value = "${google_cloud_run_v2_service.n8n.uri}/webhook/${var.webhook_path}"
}

output "cloud_scheduler_job" {
  value = google_cloud_scheduler_job.n8n_saturday_trigger.name
}

output "n8n_service_account" {
  value = google_service_account.n8n_runner.email
}

output "scheduler_service_account" {
  value = google_service_account.scheduler.email
}

output "secret_manager_secrets" {
  value = {
    encryption_key        = google_secret_manager_secret.n8n_encryption_key.secret_id
    ui_password           = google_secret_manager_secret.n8n_basic_auth_password.secret_id
    neon_db_host          = google_secret_manager_secret.neon_db_host.secret_id
    neon_db_user          = google_secret_manager_secret.neon_db_user.secret_id
    neon_db_name          = google_secret_manager_secret.neon_db_name.secret_id
    neon_db_password      = google_secret_manager_secret.neon_db_password.secret_id
    gemini_key            = google_secret_manager_secret.gemini_api_key.secret_id
    openai_key            = google_secret_manager_secret.openai_api_key.secret_id
    linkedin_access_token = google_secret_manager_secret.linkedin_access_token.secret_id
  }
}