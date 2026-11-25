# baserow — implementation plan
> Source: ./draft.md · Target: apps/baserow/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts
| Item | Value |
|---|---|
| Version | 2.4.3 (release published 14 Nov; matches chart tag) |
| Renovate | datasource=github-releases, depName=baserow/baserow, versioning=semver (tags bare `2.4.3`) |
| License | MIT for the core; `premium/` and `enterprise/` directories carry a separate Baserow license (UNVERIFIED this session; check LICENSE and premium/LICENSE before choosing the bake LICENSE; if premium code is shipped, LICENSE must say so, or remove those dirs) |
| Source | https://github.com/baserow/baserow |
| Download | https://github.com/baserow/baserow/archive/refs/tags/${VERSION}.tar.gz (source; build backend with uv and frontend with yarn/node). Alternative: `COPY --from=baserow/backend:2.4.3` and `baserow/web-frontend:2.4.3`, which are Debian trixie glibc images (not musl) but Python 3.14.7 vs our python:3.15.2 base. UNVERIFIED which is practical |
| Checksum | none published: UNVERIFIED |
| Upstream Dockerfile reviewed | deploy/all-in-one/Dockerfile @d897b90 (python:3.14.7-slim-trixie; Caddy 2.11.4; supervisor; su-exec; node/yarn 1.22.22 copied from frontend; entrypoint /baserow.sh start; DATA_DIR=/baserow/data; ports 80 and 25) |
| Env vars (docs) | BASEROW_PUBLIC_URL, BASEROW_CADDY_ADDRESSES, DATABASE_URL or DATABASE_HOST/PORT/NAME/USER/PASSWORD (+_FILE), REDIS_URL or REDIS_HOST/PORT/USER/PASSWORD/PROTOCOL, SECRET_KEY(_FILE), BASEROW_ENCRYPTION_KEY, DISABLE_VOLUME_CHECK, BASEROW_AMOUNT_OF_GUNICORN_WORKERS, BASEROW_AMOUNT_OF_WORKERS, BASEROW_RUN_MINIMAL |
| Data | /baserow/data (SECRET_KEY auto-generated in /baserow/data/.secret; plugins in /baserow/data/plugins; caddy certs in /baserow/data/caddy) |

## 2. Target layout
Dockerfile, docker-bake.hcl, settings.yaml, container-test.yaml, start.sh, defaults/ (Caddyfile, supervisord.conf). This container is the all-in-one "prod-lite" shape (no embedded Postgres/Redis), using postgresql ✅ and valkey ✅ siblings. No DOWNSTREAM_CHANGES.md.

## 3. Base image
`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (draft Reason; Django backend is main). Node is needed for the Nuxt frontend at runtime (SSR) and build: use python-node (`ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`) instead for the final stage. Risk: Baserow targets Python 3.14; verify 3.15 compatibility of pinned deps (psycopg, Pillow, etc.) before committing. Closest siblings: apps/budge, apps/changedetection (python-node), apps/caddy (Caddy exists; reuse binary pattern).

## 4. Dockerfile
1. Stage `build` (python-node): download source tarball, `uv` sync backend into /app/venv-style location (**/app/venv is owned by the base; check python-runtime rules: install deps into a dedicated /app/baserow/venv at build time, never mutate /app/venv at runtime**), then `yarn install --frozen-lockfile && yarn build` for web-frontend with `NODE_OPTIONS=--max-old-space-size=4096`, caches in /tmp.
2. Final stage python-node: `USER root`; apt: `supervisor gettext xmlsec1 libpq5 postgresql-client` (postgresql-client version must be compatible with the pg server, UNVERIFIED), `tini` only if not in base; Caddy binary copied from ghcr.io/trueforge-org/caddy image or downloaded (Caddy 2.11.4 upstream; check apps/caddy Dockerfile for the pattern).
3. COPY --from=build backend, premium, enterprise (only if license allows), web-frontend build to /app/baserow.
4. Licenses to /usr/share/licenses/baserow/.
5. ENV: `DATA_DIR=/config`, `BASEROW_PLUGIN_DIR=/config/plugins`, `UV_CACHE_DIR=/tmp/baserow_uv_cache`, `PYTHONUNBUFFERED=1`, `DJANGO_SETTINGS_MODULE=baserow.config.settings.base`, `PYTHONPATH` for backend/premium/enterprise src, `HOME=/config`, `PYTHONPYCACHEPREFIX=/tmp/pycache`, `XDG_DATA_HOME=/config/caddy`, `XDG_CONFIG_HOME=/tmp` (matches section 9).
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`.

## 5. docker-bake.hcl
APP=baserow; VERSION "2.4.3" with `// renovate: datasource=github-releases depName=baserow/baserow versioning=semver`; LICENSE per section 1 (MIT if premium/enterprise excluded); SOURCE https://github.com/baserow/baserow. Standard targets + default; image-all amd64+arm64. `docker buildx bake --print`.

## 6. settings.yaml
Header, schema_version 1, upstream_env_url = SOURCE. ports: 8080/tcp (container; upstream 80; 25 only for email receiver, omit). env (names from the install docs above, defaults matching start.sh): TZ; BASEROW_PUBLIC_URL (default "http://localhost:8080", required true); DATABASE_HOST, DATABASE_PORT "5432", DATABASE_NAME "baserow", DATABASE_USER "baserow", DATABASE_PASSWORD (required true, no default; start.sh must fail clearly or generate), REDIS_HOST, REDIS_PORT "6379", REDIS_PASSWORD, SECRET_KEY (auto-generated into /config/.secret when empty, so required false), BASEROW_AMOUNT_OF_WORKERS, BASEROW_AMOUNT_OF_GUNICORN_WORKERS. volumes: /config required true (maps upstream /baserow/data). dependencies: postgresql ✅, valkey ✅ (hard).

## 7. start.sh
```bash
#!/usr/bin/env bash
set -e
mkdir -p /config/plugins /tmp/caddy /tmp/supervisor
[ -s /config/.secret ] || { [ -n "${SECRET_KEY}" ] || head -c 48 /dev/urandom | base64 | tr -d '\n' > /config/.secret; }
export SECRET_KEY="${SECRET_KEY:-$(cat /config/.secret)}"
# wait for postgres and valkey, then migrate on every start (upstream does this in the backend entrypoint)
cp /defaults/Caddyfile /tmp/caddy/Caddyfile; cp /defaults/supervisord.conf /tmp/supervisor/supervisord.conf
exec supervisord -n -c /tmp/supervisor/supervisord.conf   # runs backend (gunicorn/uvicorn), celery workers, beat, web-frontend, caddy
```
Use the backend's real entrypoint commands (`docker-entrypoint.sh` args such as backend-healthcheck/migrate; exact names UNVERIFIED, read deploy/all-in-one/baserow.sh and backend/docker/docker-entrypoint.sh at implementation). DB/Redis passwords come from env every start and are never written to the supervisord file (pass via environment, not process args). Caddy listens on 0.0.0.0:8080 via `BASEROW_CADDY_ADDRESSES=:8080`.

## 8. container-test.yaml
Header; `timeoutSeconds: 300` (long first start with migrations; larger than bookstack's 240). Tests run with no env and no DB, so this qualifies for the DB narrowing exception (hard postgres dependency, will not start without it, no sidecar primitive): keep `tcp` off 8080 only if the process stays up without DB (UNVERIFIED), otherwise use `mainRunner: enabled: false` like apps/bookstack and `runners`: `test -d /app/baserow/backend`, `test -x /usr/local/bin/caddy`, `python --version`, `node --version`, `filePaths` for license files. Comment: `# narrowed: requires external postgresql and valkey; full functional test not feasible in single-container suite`. Protocol step 3 (run and logs) remains mandatory and must show waiting-for-database retries with the process alive.

## 9. Rootless and read-only-rootfs adaptations
| Upstream write path | Remap |
|---|---|
| /baserow/data (+ .secret, plugins, caddy certs) | /config |
| /baserow/venv, uv cache | venv built into /app at build time (read-only), cache /tmp/baserow_uv_cache |
| Caddy storage and autosave | XDG_DATA_HOME=/config/caddy, XDG_CONFIG_HOME=/tmp |
| supervisord pid/log/socket | /tmp/supervisor |
| port 80 and su-exec user switching | 8080, everything as apps (no su-exec) |
| embedded postgres/redis | not shipped (siblings) |
Draft expects runAsUser 0 and NET_BIND_SERVICE; this plan avoids both. Nuxt/Node temp dirs to /tmp.

## 10. Risks, caveats and open questions
- Largest build in this batch: Django, Nuxt frontend, celery workers, Caddy, supervisor; first start runs migrations.
- Python 3.15 vs upstream 3.14.7 is the key risk; fallback: build a dedicated python 3.14 stage (open question).
- License of premium/enterprise code (decide ship or strip).
- Exact supervisor program list and backend entrypoint commands UNVERIFIED.
- Hard DB dependency => narrowed tests (annotated). No arch blockers (arch-neutral code, wasmtime/mox binaries per arch must be checked: upstream copies them from the backend image, UNVERIFIED whether built for arm64).

## 11. Build and test steps
```sh
cd apps/baserow
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker network create baserow-probe-net
# start postgresql and valkey images on that network, then:
docker run --rm -d --name baserow-probe --network baserow-probe-net --read-only --tmpfs /tmp -v baserow-probe-config:/config -e DATABASE_HOST=... -e DATABASE_PASSWORD=... -e REDIS_HOST=... baserow:2.4.3
docker logs -f baserow-probe   # expect migrations complete, gunicorn/uvicorn started, caddy serving :8080, no repeated tracebacks
docker rm -f baserow-probe; docker volume rm baserow-probe-config
forgetool containers test --image baserow:2.4.3 --config ./apps/baserow/container-test.yaml
```
Also run the bare protocol command (no DB) to confirm retry-and-stay-alive behaviour.

## 12. PR checklist
- Branch feat/add-baserow; commit `feat(baserow): add new container`; PR template; `🤖 This PR is AI generated.` in Notes.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: everything not built/run; arm64; Python 3.15 compatibility; supervisor program set; premium license decision. Mention the DB-dependency narrowing in the PR.
