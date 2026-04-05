locals {
  n8n_public_base = trimsuffix(trimspace(var.n8n_public_url), "/")
  n8n_uri         = local.n8n_public_base != "" ? local.n8n_public_base : trimsuffix(trimspace(google_cloud_run_v2_service.n8n.uri), "/")
}
