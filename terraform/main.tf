terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "n8n_runner" {
  account_id   = "${var.service_name}-runner"
  display_name = "PageManager n8n Cloud Run Runner"
}

resource "google_project_iam_member" "n8n_secretmanager" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.n8n_runner.email}"
}

resource "google_service_account" "scheduler" {
  account_id   = "${var.service_name}-scheduler"
  display_name = "PageManager n8n Cloud Scheduler"
}

resource "google_cloud_run_v2_service_iam_member" "scheduler_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.n8n.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler.email}"
}

resource "google_secret_manager_secret" "n8n_encryption_key" {
  secret_id = "${var.service_name}-encryption-key"
  replication { auto {} }
}
resource "google_secret_manager_secret_version" "n8n_encryption_key" {
  secret      = google_secret_manager_secret.n8n_encryption_key.id
  secret_data = var.n8n_encryption_key
}

resource "google_secret_manager_secret" "n8n_basic_auth_password" {
  secret_id = "${var.service_name}-ui-password"
  replication { auto {} }
}
resource "google_secret_manager_secret_version" "n8n_basic_auth_password" {
  secret      = google_secret_manager_secret.n8n_basic_auth_password.id
  secret_data = var.n8n_basic_auth_password
}

resource "google_secret_manager_secret" "neon_db_password" {
  secret_id = "${var.service_name}-neon-db-password"
  replication { auto {} }
}
resource "google_secret_manager_secret_version" "neon_db_password" {
  secret      = google_secret_manager_secret.neon_db_password.id
  secret_data = var.neon_db_password
}

resource "google_secret_manager_secret" "neon_db_host" {
  secret_id = "${var.service_name}-neon-db-host"
  replication { auto {} }
}
resource "google_secret_manager_secret_version" "neon_db_host" {
  secret      = google_secret_manager_secret.neon_db_host.id
  secret_data = var.neon_db_host
}

resource "google_secret_manager_secret" "neon_db_user" {
  secret_id = "${var.service_name}-neon-db-user"
  replication { auto {} }
}
resource "google_secret_manager_secret_version" "neon_db_user" {
  secret      = google_secret_manager_secret.neon_db_user.id
  secret_data = var.neon_db_user
}

resource "google_secret_manager_secret" "neon_db_name" {
  secret_id = "${var.service_name}-neon-db-name"
  replication { auto {} }
}
resource "google_secret_manager_secret_version" "neon_db_name" {
  secret      = google_secret_manager_secret.neon_db_name.id
  secret_data = var.neon_db_name
}

resource "google_secret_manager_secret" "gemini_api_key" {
  secret_id = "${var.service_name}-gemini-key"
  replication { auto {} }
}
resource "google_secret_manager_secret_version" "gemini_api_key" {
  secret      = google_secret_manager_secret.gemini_api_key.id
  secret_data = var.gemini_api_key
}

resource "google_secret_manager_secret" "openai_api_key" {
  secret_id = "${var.service_name}-openai-key"
  replication { auto {} }
}
resource "google_secret_manager_secret_version" "openai_api_key" {
  secret      = google_secret_manager_secret.openai_api_key.id
  secret_data = var.openai_api_key
}

resource "google_secret_manager_secret" "linkedin_access_token" {
  secret_id = "${var.service_name}-linkedin-token"
  replication { auto {} }
}
resource "google_secret_manager_secret_version" "linkedin_access_token" {
  secret      = google_secret_manager_secret.linkedin_access_token.id
  secret_data = var.linkedin_access_token
}

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
          memory = "512Mi"
        }
        startup_cpu_boost = true
      }

      ports {
        container_port = 5678
      }

      env { name = "N8N_HOST";              value = "0.0.0.0" }
      env { name = "N8N_PORT";              value = "5678" }
      env { name = "N8N_PROTOCOL";          value = "https" }
      env { name = "GENERIC_TIMEZONE";      value = var.timezone }
      env { name = "N8N_BASIC_AUTH_ACTIVE"; value = "true" }
      env { name = "N8N_BASIC_AUTH_USER";   value = var.n8n_basic_auth_user }
      env { name = "N8N_BLOCK_ENV_ACCESS_IN_NODE"; value = "false" }

      env { name = "DB_TYPE";                   value = "postgresdb" }
      env { name = "DB_POSTGRESDB_PORT";       value = "5432" }
      env { name = "DB_POSTGRESDB_SSL_ENABLED"; value = "true" }
      env { name = "DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED"; value = "true" }

      env { name = "DALLE_MODEL";              value = "dall-e-3" }
      env { name = "DALLE_SIZE";               value = "1024x1024" }
      env { name = "DALLE_QUALITY";           value = "hd" }
      env { name = "DALLE_STYLE";              value = "natural" }
      env { name = "LINKEDIN_MEMBER_URN"; value = var.linkedin_member_urn }

      # Segredos via Secret Manager
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

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.n8n.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

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
    uri         = "${google_cloud_run_v2_service.n8n.uri}/webhook/${var.webhook_path}"

    body = base64encode(jsonencode({
      source  = "cloud-scheduler"
      trigger = "saturday-post"
    }))

    headers = {
      "Content-Type" = "application/json"
    }

    oidc_token {
      service_account_email = google_service_account.scheduler.email
      audience              = google_cloud_run_v2_service.n8n.uri
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_cloud_run_v2_service.n8n,
  ]
}
