# NocoDB quickstart install (Docker)

**Source:** https://nocodb.com/docs/product-docs/getting-started/installation (fetched 2026-11-26; found by guessed URL after the category page 404'd)

## Images / containers
| Service | Image / role |
|---|---|
| nocodb | nocodb/nocodb:latest (web app + API) |
| worker | nocodb/nocodb:latest (background jobs: imports, exports, automations) |
| db | PostgreSQL (metadata + user data), no tag listed |
| redis | Redis (cache + job queue), no tag listed |

## Install
- Script: `curl -fsSL https://install.nocodb.com/noco.sh | bash -s -- --quick`
- Manual: copy `docker-compose.yml` from GitHub `docker-compose/examples/quickstart-demo` into empty dir; `docker compose up -d`
- Ops (in `nocodb/`): logs `docker compose logs -f nocodb`; stop `docker compose down`; update `docker compose pull && docker compose up -d`
- Prereqs: Docker Desktop or Docker Engine. First run pulls images (minutes).

## Ports / paths
- Web UI http://localhost:8080
- Named volumes: postgres_data, redis_data, nocodb_data (persist across `down`)
- Installer writes files into `nocodb/` directory.

## Env vars
- None listed on this page (custom setups deferred to "Custom infrastructure" page).

## Not documented on page
- Healthcheck, container user, env var names beyond the above.
- Single-server install adds Traefik with Let's Encrypt.
- First signed-up account becomes super admin.
- Managed Postgres, external Redis, custom SSL: Custom infrastructure page (not fetched).
