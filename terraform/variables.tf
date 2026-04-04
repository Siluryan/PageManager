variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "southamerica-east1"
}

variable "service_name" {
  type    = string
  default = "pagemanager-n8n"
}

variable "timezone" {
  type    = string
  default = "America/Sao_Paulo"
}

variable "webhook_path" {
  type    = string
  default = "pagemanager-post"
}

variable "n8n_encryption_key" {
  type      = string
  sensitive = true
}

variable "n8n_basic_auth_user" {
  type    = string
  default = "admin"
}

variable "n8n_basic_auth_password" {
  type      = string
  sensitive = true
}

variable "neon_db_host" {
  type = string
}

variable "neon_db_name" {
  type    = string
  default = "neondb"
}

variable "neon_db_user" {
  type = string
}

variable "neon_db_password" {
  type      = string
  sensitive = true
}

variable "gemini_api_key" {
  type      = string
  sensitive = true
}

variable "openai_api_key" {
  type      = string
  sensitive = true
}

variable "linkedin_access_token" {
  type      = string
  sensitive = true
}

variable "linkedin_member_urn" {
  type = string
}
