# PageManager

n8n no **Cloud Run** + **Neon** + **Cloud Scheduler**: RSS → filtro → Gemini (título + post + hashtags) → DALL-E → LinkedIn (perfil, `w_member_social`).

## Pré-requisitos

| Item | Link |
|------|------|
| GCP, Terraform, Docker | — |
| Neon | https://neon.tech |
| Gemini | https://aistudio.google.com/app/apikey |
| OpenAI | https://platform.openai.com/api-keys |
| LinkedIn (Share on LinkedIn) | https://www.linkedin.com/developers/apps |

## LinkedIn

1. App com produto **Share on LinkedIn**. Redirect: `http://localhost:8765/callback`
2. `cd pagemanager && pip install requests && python3 scripts/get_linkedin_token.py` (com `LINKEDIN_CLIENT_ID` / `LINKEDIN_CLIENT_SECRET`)

## Neon + Terraform

1. Projeto Neon → host, user, password, database (`neondb`).
2. `cd terraform && cp terraform.tfvars.example terraform.tfvars` → preencher.
3. `terraform init && terraform apply` (CI: usar backend remoto p.ex. GCS para estado partilhado)
4. No n8n (URL do output): importar `n8n/workflows/linkedin_post.json`, path do webhook = `webhook_path` do tfvars, **ativar** o workflow.

Neon: Terraform grava host/user/db/password no **Secret Manager**; Cloud Run monta por secret.

Teste do agendador: `gcloud scheduler jobs run pagemanager-n8n-saturday-trigger --location=southamerica-east1`

**GitHub Actions:** `.github/workflows/pagemanager-terraform.yml` — PR: `plan`; dispatch: `plan` ou `apply`. Segredos no cabeçalho do YAML.

## Local

```bash
cp .env.example .env   # preencher chaves
docker compose up -d   # http://localhost:5678
```

Postgres local: `DB_POSTGRESDB_SSL_ENABLED=false`. Não uses `DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false` neste compose (conflito com o driver do n8n).

Importar o JSON do workflow e ativar. **Dedupe** (`staticData`) só persiste em execuções **não manuais** (webhook/scheduler com workflow ativo).

## Renovar token LinkedIn

```bash
echo -n "NOVO_TOKEN" | gcloud secrets versions add pagemanager-n8n-linkedin-token --data-file=-
```

(`pagemanager-n8n` = `service_name` padrão.)

## Estrutura

```
pagemanager/
├── scripts/
│  └── get_linkedin_token.py
├── docker-compose.yml
├── n8n/workflows/linkedin_post.json
└── terraform/
```

© 2026 Guilherme Rogério Ramos Dias. Todos os direitos reservados.
