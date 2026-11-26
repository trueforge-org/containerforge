# docs.pwpush.com (installation and env vars)

Sources:
- https://docs.pwpush.com: landing page only. Install/env details NOT present (counted as failure: no content).
- https://docs.pwpush.com/docs/installation/ (follow-up): fetched.

## Images
- pglombardo/pwpush (main, linux/amd64); pglombardo/pwpush-public-gateway (external push delivery only)
- Tags: vX.X.X, stable (recommended prod), latest, nightly (dev)

## Ports
- No TLS_DOMAIN: HTTP 5100 (publish 5100:5100)
- Built-in HTTP proxy in container: HTTP_PORT default 80 -> forwards to TARGET_PORT 5100
- TLS_DOMAIN: Let's Encrypt on 80/443; docker run examples publish 80:80, 443:443
- Kubernetes: app serves HTTP on 5100 (TARGET_PORT), TLS at Ingress
- Health path referenced: /up (Railway, Render)

## Env vars
| Name | Default | Purpose |
| --- | --- | --- |
| TLS_DOMAIN | unset | Let's Encrypt domain |
| HTTP_PORT | 80 | built-in proxy port (set e.g. 5100 if permission denied) |
| TARGET_PORT | 5100 | app port behind proxy |
| DATABASE_URL | SQLite3 | DB; postgres://user:pass@host:5432/db format |
| SECRET_KEY_BASE | none | secret; set for cloud deploys |
| PWPUSH_MASTER_KEY | none | secret; set for cloud deploys |
| PWP__NO_WORKER | unset | 1 = web only (default runs web + worker) |
| PWP__... | see docker-compose.yml | app settings |

## Volumes / user / healthcheck
- Compose keeps SQLite DB in Docker volumes (paths not given). docker run without volume = ephemeral DB.
- User: not specified on this page (Dockerfile: pwpusher 1000).
- Healthcheck: defined in compose (not shown).
- Entrypoint runs db:migrate then Foreman (web + worker).
