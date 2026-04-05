resource "google_cloud_run_v2_service" "n8n" {
  name     = var.service_name
  location = var.region

  template {
    service_account = google_service_account.n8n_runner.email

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    containers {
      image = "n8nio/n8n:latest"

      resources {
        limits = {
          cpu    = "1"
          memory = "2Gi"
        }
        startup_cpu_boost = true
      }

      ports {
        container_port = 5678
      }

      startup_probe {
        initial_delay_seconds = 15
        timeout_seconds       = 30
        period_seconds        = 10
        failure_threshold     = 12
        tcp_socket {
          port = 5678
        }
      }

      env {
        name  = "N8N_HOST"
        value = "0.0.0.0"
      }
      env {
        name  = "N8N_PORT"
        value = "5678"
      }
      env {
        name  = "N8N_PROTOCOL"
        value = "https"
      }
      env {
        name  = "GENERIC_TIMEZONE"
        value = var.timezone
      }
      env {
        name  = "N8N_BASIC_AUTH_ACTIVE"
        value = "true"
      }
      env {
        name  = "N8N_BASIC_AUTH_USER"
        value = var.n8n_basic_auth_user
      }
      env {
        name  = "N8N_BLOCK_ENV_ACCESS_IN_NODE"
        value = "false"
      }

      env {
        name  = "DB_TYPE"
        value = "postgresdb"
      }
      env {
        name  = "DB_POSTGRESDB_PORT"
        value = "5432"
      }
      env {
        name  = "DB_POSTGRESDB_SSL_ENABLED"
        value = "true"
      }
      env {
        name  = "DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED"
        value = "true"
      }

      env {
        name  = "DALLE_MODEL"
        value = "dall-e-3"
      }
      env {
        name  = "DALLE_SIZE"
        value = "1024x1024"
      }
      env {
        name  = "DALLE_QUALITY"
        value = "hd"
      }
      env {
        name  = "DALLE_STYLE"
        value = "natural"
      }
      env {
        name  = "LINKEDIN_MEMBER_URN"
        value = var.linkedin_member_urn
      }

      env {
        name = "N8N_ENCRYPTION_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.n8n_encryption_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "N8N_BASIC_AUTH_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.n8n_basic_auth_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "DB_POSTGRESDB_HOST"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.neon_db_host.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "DB_POSTGRESDB_USER"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.neon_db_user.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "DB_POSTGRESDB_DATABASE"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.neon_db_name.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "DB_POSTGRESDB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.neon_db_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "GEMINI_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.gemini_api_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "OPENAI_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.openai_api_key.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "LINKEDIN_ACCESS_TOKEN"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.linkedin_access_token.secret_id
            version = "latest"
          }
        }
      }
    }
  }

  depends_on = [google_project_service.required_apis]
}