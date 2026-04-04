### PageManager — Terraform: Segredos e Variáveis

Este documento descreve os segredos e variáveis usados pelo workflow `pagemanager-terraform.yml`.

#### Segredos obrigatórios (Actions → Secrets and variables → Repository secrets)
- `GCP_SA_KEY`: JSON da Service Account do GCP com permissões para o projeto.
- `TF_VAR_project_id`: ID do projeto no provedor.
- `TF_VAR_n8n_encryption_key`: Chave de criptografia do n8n.
- `TF_VAR_n8n_basic_auth_password`: Senha do Basic Auth do n8n.
- `TF_VAR_neon_db_host`: Host do banco (Neon).
- `TF_VAR_neon_db_user`: Usuário do banco (Neon).
- `TF_VAR_neon_db_password`: Senha do banco (Neon).
- `TF_VAR_gemini_api_key`: API key do Gemini.
- `TF_VAR_openai_api_key`: API key do OpenAI.
- `TF_VAR_linkedin_access_token`: Access token do LinkedIn.
- `TF_VAR_linkedin_member_urn`: Member URN do LinkedIn.

#### Variáveis opcionais (recomendado usar Actions → Secrets and variables → Repository variables)
- `TF_VAR_region`: Região de implantação.
- `TF_VAR_service_name`: Nome do serviço.
- `TF_VAR_timezone`: Timezone da aplicação.
- `TF_VAR_webhook_path`: Caminho do webhook (n8n).
- `TF_VAR_n8n_basic_auth_user`: Usuário do Basic Auth do n8n.
- `TF_VAR_neon_db_name`: Nome do banco (Neon).

Observação: As entradas `TF_VAR_*` são lidas automaticamente pelo Terraform como variáveis. Você também pode optar por gerar um arquivo `.auto.tfvars.json` temporário durante o workflow (o repositório já ignora `*.tfvars`).

#### Como configurar
1. No GitHub, acesse Settings → Security → Secrets and variables → Actions.
2. Em "Secrets", adicione todos os segredos obrigatórios listados acima.
3. Em "Variables", adicione as variáveis opcionais conforme seu ambiente.
4. Opcional: use "Environments" para isolar valores por ambiente (ex.: `staging`, `production`) e referenciá-los no job.

#### Referência
- Workflow: `.github/workflows/pagemanager-terraform.yml`
- Passos principais: `terraform init`, `validate`, `plan` (gera `plan.txt`) e comentário automático no PR com o plano.

