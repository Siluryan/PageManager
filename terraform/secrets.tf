resource "google_secret_manager_secret" "n8n_encryption_key" {
  secret_id = "${var.service_name}-encryption-key"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "n8n_encryption_key" {
  secret      = google_secret_manager_secret.n8n_encryption_key.id
  secret_data = var.n8n_encryption_key
}

resource "google_secret_manager_secret" "n8n_basic_auth_password" {
  secret_id = "${var.service_name}-ui-password"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "n8n_basic_auth_password" {
  secret      = google_secret_manager_secret.n8n_basic_auth_password.id
  secret_data = var.n8n_basic_auth_password
}

resource "google_secret_manager_secret" "neon_db_password" {
  secret_id = "${var.service_name}-neon-db-password"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "neon_db_password" {
  secret      = google_secret_manager_secret.neon_db_password.id
  secret_data = var.neon_db_password
}

resource "google_secret_manager_secret" "neon_db_host" {
  secret_id = "${var.service_name}-neon-db-host"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "neon_db_host" {
  secret      = google_secret_manager_secret.neon_db_host.id
  secret_data = var.neon_db_host
}

resource "google_secret_manager_secret" "neon_db_user" {
  secret_id = "${var.service_name}-neon-db-user"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "neon_db_user" {
  secret      = google_secret_manager_secret.neon_db_user.id
  secret_data = var.neon_db_user
}

resource "google_secret_manager_secret" "neon_db_name" {
  secret_id = "${var.service_name}-neon-db-name"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "neon_db_name" {
  secret      = google_secret_manager_secret.neon_db_name.id
  secret_data = var.neon_db_name
}

resource "google_secret_manager_secret" "gemini_api_key" {
  secret_id = "${var.service_name}-gemini-key"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "gemini_api_key" {
  secret      = google_secret_manager_secret.gemini_api_key.id
  secret_data = var.gemini_api_key
}

resource "google_secret_manager_secret" "openai_api_key" {
  secret_id = "${var.service_name}-openai-key"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "openai_api_key" {
  secret      = google_secret_manager_secret.openai_api_key.id
  secret_data = var.openai_api_key
}

resource "google_secret_manager_secret" "linkedin_access_token" {
  secret_id = "${var.service_name}-linkedin-token"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "linkedin_access_token" {
  secret      = google_secret_manager_secret.linkedin_access_token.id
  secret_data = var.linkedin_access_token
}