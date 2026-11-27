# Upstream README: libredb/libredb-studio (commit 58adba536f0283fecb7b761053cb2401dd7187eb)

Source URL(s) + date: https://raw.githubusercontent.com/libredb/libredb-studio/58adba536f0283fecb7b761053cb2401dd7187eb/README.md (fetched 2026-11-27). Release page https://github.com/libredb/libredb-studio/releases/tag/1.3.0 (HTML, fetched 2026-11-27; published 2026-11-10T19:50:10Z; asset links not present in static HTML, so bundle names not confirmed here).

## Run
- `docker run -p 3000:3000 ghcr.io/libredb/libredb-studio:latest` (zero-config).
- First run with no JWT_SECRET/ADMIN_PASSWORD: generated, stored in `<data dir>/auth-bootstrap.json` (mode 0600), admin password printed once to log (`docker logs`).
- Explicit env always wins. `AUTH_BOOTSTRAP=off` = strict mode (recommended for production).
- Self-set JWT_SECRET under 32 chars: server exits 1 at startup.

## Env vars (README table, key rows)
| Var | Req | Note |
| --- | --- | --- |
| ADMIN_EMAIL | no | default admin@libredb.org |
| ADMIN_PASSWORD | auto | auto-generated unless AUTH_BOOTSTRAP=off |
| USER_EMAIL | no | default user@libredb.org |
| USER_PASSWORD | no | lower-privilege user exists only when set |
| JWT_SECRET | auto | min 32 chars |
| AUTH_BOOTSTRAP | no | `off` = strict |
| AUTH_COOKIE_SECURE | no | `false` drops Secure flag (plain HTTP LAN) |
| NEXT_PUBLIC_AUTH_PROVIDER | no | `local` (default) or `oidc` |
| OIDC_ISSUER / OIDC_CLIENT_ID / OIDC_CLIENT_SECRET | when oidc | |
| OIDC_ADMIN_ROLES | no | default `admin` |
| OIDC_ROLE_CLAIM | no | e.g. `realm_access.roles` |
| OIDC_SCOPE | no | default `openid profile email` |
| LLM_PROVIDER | no | gemini, openai, ollama, custom |
| LLM_API_KEY / LLM_MODEL / LLM_API_URL | no | ollama default `http://localhost:11434/v1` |
| LLM_MODEL_EFFORT | no | openai only |
| STORAGE_PROVIDER | no | `local` (default), `sqlite`, `postgres` |
| STORAGE_SQLITE_PATH | no | e.g. `/app/data/libredb-storage.db` |
| STORAGE_POSTGRES_URL | when postgres | |
| SEED_CONFIG_PATH | no | default `/app/config/seed-connections.yaml` |
| SEED_CACHE_TTL_MS | no | default 60000 |

## Other
- Helm chart is the supported route for OpenShift (per Dockerfile comment).
- Persistence doc: SQLite on a volume at `/app/data`.
- Database-compose files exist upstream (not used here).

## Gotchas
- Release asset names and checksums not confirmed here (see plan).
