# romm — implementation plan
> Source: ./draft.md · Target: apps/romm/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest release | 5.4.1, published 2026-10-22 (no release assets; source comes from the tag) | https://api.github.com/repos/rommapp/romm/releases/tags/5.4.1 |
| Chart image | `ghcr.io/rommapp/romm:5.4.1@sha256:8677fb7b81b1d3db20b849e989a1dadc2a11159e51eb34a2acdcb01102274edf` | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/romm/values.yaml |
| Renovate | `datasource=github-releases depName=rommapp/romm versioning=semver` | judgement from the tag format |
| SPDX license | AGPL-3.0 | https://api.github.com/repos/rommapp/romm |
| Checksum source | None on the release. Image digest from the chart only | release metadata, chart values |
| Architectures | `UNVERIFIED`: GHCR arch list not fetched. Source build is arch-neutral (Python and npm) | n/a |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/rommapp/romm/5.4.1/docker/Dockerfile | fetched |
| Upstream stages | Alpine/musl only: `python:${PYTHON_VERSION}-alpine` (runtime), `node:...-alpine` (frontend and rom_patcher), `ghcr.io/astral-sh/uv` (uv), `nginx:...-alpine` (production), `emscripten/emsdk` (gme build) | same Dockerfile |
| Backend install | `uv sync --frozen --no-cache` into `/src/.venv`; `PATH=/src/.venv/bin:$PATH`; `PYTHONPATH=/backend` | same Dockerfile |
| Frontend | `npm ci --ignore-scripts` then `npm run build` into `/var/www/html` | same Dockerfile |
| APK (runtime) | `bash libarchive-tools libmagic mariadb-connector-c libpq nodejs 7zip tzdata valkey valkey-cli` | same Dockerfile |
| Entrypoint | `ENTRYPOINT ["/docker-entrypoint.sh"]`, `CMD ["/init"]`; init scripts from `docker/init_scripts` | same Dockerfile |
| User | Creates `romm` uid/gid 1000, never switches to it (no `USER`) | same Dockerfile |
| EXPOSE / VOLUME | `EXPOSE 8080 6379/tcp`; `VOLUME ["/romm", "/redis-data"]` | same Dockerfile |
| Writes at build/runtime | `/src/.venv`, `/var/www/html`, `/etc/nginx/conf.d` and `/etc/gunicorn` (made world-writable), `/romm`, `/redis-data` | same Dockerfile |
| Env vars (chart, active) | `ROMM_PORT=10680`, `ROMM_BASE_URL`, `LOGLEVEL=INFO`, `ROMM_DB_DRIVER=postgresql`, `DB_HOST`, `DB_PORT=5432`, `DB_NAME`, `DB_USER`, `DB_PASSWD` (secret), `REDIS_HOST`, `REDIS_PORT=6379`, `REDIS_USERNAME=default`, `REDIS_PASSWORD` (secret), `SCAN_WORKERS=4`, `IGDB_CLIENT_ID`, `IGDB_CLIENT_SECRET` (secret), `ROMM_AUTH_SECRET_KEY` (secret, placeholder in chart) | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/romm/values.yaml |
| Ports | Chart `service.main` port 10680 http. Upstream EXPOSE 8080. Which port 5.4.1 binds to is `UNVERIFIED`; the chart sets `ROMM_PORT`, so the app reads it | chart values, Dockerfile |
| Persistence (chart) | `/romm/library`, `/romm/resources`, `/romm/config`, `/romm/assets` | chart values |
| Dependencies (chart) | postgresql (user `romm`, db `romm`) and valkey. Both exist in this repo: `apps/postgresql` and `apps/valkey` | chart values, repo listing |
| Chart security | runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false | chart values |

Not verified: whether 5.4.1 reads `ROMM_PORT` and binds to it, the exact `/romm/*` env var overrides, and whether the upstream image's embedded Valkey starts in this app (`valkey` is in the APK list, so `UNVERIFIED`).

## 2. Target layout

Files under `apps/romm/`:

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`: required
- `etc/`: needed for the nginx and gunicorn config the image expects. Add only the files that the rootless run needs (reason: upstream writes to `/etc/nginx/conf.d` and `/etc/gunicorn`, which are not writable as `apps`)
- `defaults/`: not needed by default
- `root/`: never used
- `DOWNSTREAM_CHANGES.md`: not needed

## 3. Base image

- `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` as the runtime (copy exactly from the brief). The python base already runs as `apps`, so no `USER` change is needed for the runtime.
- Frontend build: a separate `node` build stage. Use `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS frontend-build`, as `apps/changedetection` and other node apps in this repo do (there is no `apps/python-node` folder). Do not run `npm` in the runtime stage.
- The upstream `FROM python:...-alpine` and `nginx:...-alpine` are musl; they cannot be copied. The nginx binary is built from source in the upstream file with `ngx_http_zip_module`. Either reproduce that in a build stage on ubuntu or drop the zip module if not needed (`UNVERIFIED`).
- Closest sibling: `apps/bazarr` (python backend), `apps/python` (base) and the python-runtime rules.
- Base reuse: the ubuntu base is the foundation of python, so do not re-install packages `python` already has.

## 4. Dockerfile

Step list:

1. `ARG VERSION` (5.4.1), `ARG PIP_VERSION`, `ARG UV_VERSION`; `USER root` for installs.
2. Frontend build stage: the node-capable `python-node` stage from section 3, `npm ci --ignore-scripts --no-audit --no-fund` and `npm run build` from the 5.4.1 source tarball (`https://github.com/rommapp/romm/archive/refs/tags/5.4.1.tar.gz`). Verify the download against a pinned SHA256 (self-computed, since no upstream checksum is on the release).
3. Backend build stage: `uv sync --frozen --no-cache` into `/app/venv` (not `/src/.venv`). Store the venv under `/app/venv`, never write to it at runtime (python-runtime rule).
4. APT packages, pinned where they matter and not already in the python base: `libmagic1`, `libarchive-tools`, `mariadb-client-core` or `libmariadb-dev` (check the sibling `bazarr`/`bookstack` for the set they install), `libpq5`, `tzdata`, `p7zip-full` (`7zip` on Alpine). `nodejs` is only needed if the rom_patcher runs at runtime (`UNVERIFIED`); otherwise build it in a build stage.
5. Copy the backend source to `/app/backend`, frontend `dist` to `/app/frontend` (or nginx root), and the init scripts from `docker/init_scripts` into `/`.
6. Valkey: the upstream image installs `valkey` into the runtime. Do not install it in romm; the chart uses the `apps/valkey` sibling. Remove it from the port.
7. Set `ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PYTHONPATH=/app/backend PATH=/app/venv/bin:$PATH`. Do not bake `SCREENSCRAPER_DEV_*` into `ENV`; take them at runtime only.
8. Cleanup: `rm -rf /var/lib/apt/lists/* /tmp/*`.
9. `chown -R apps:apps /app`; `chmod -R 755 /app`. Keep `/app` read-only at runtime (the directory itself is owned by root in a build; check the sibling).
10. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 10680` (matches the settings.yaml port; `UNVERIFIED` which port 5.4.1 binds), `VOLUME /config`, `CMD ["/start.sh"]`.

Do not carry over `VOLUME ["/romm", "/redis-data"]`. Map `/romm/*` to `/config/...` in `start.sh` instead.

## 5. docker-bake.hcl

Same layout as `apps/adguardhome-sync/docker-bake.hcl`, with:

- `APP` = `romm`
- `VERSION` = `5.4.1`, `// renovate: datasource=github-releases depName=rommapp/romm versioning=semver`
- `PYTHON_VERSION` / `NODE_VERSION` if separate variables are used, each with its own renovate comment (datasource `docker`, depName `python` / `node`)
- `LICENSE` = `AGPL-3.0`
- `SOURCE` = `https://github.com/rommapp/romm`

Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/rommapp/romm"`.
- `ports`: `10680` tcp `required: true` (chart port). If the app binds to 8080 instead, list 8080 and say which in the PR (`UNVERIFIED`).
- `env`: `ROMM_PORT` default `10680`; `ROMM_BASE_URL` default `http://localhost:10680`; `LOGLEVEL` default `INFO`; `ROMM_DB_DRIVER` default `postgresql`; `DB_HOST`, `DB_PORT` (5432), `DB_NAME`, `DB_USER`, `DB_PASSWD` (`required: true`, no default that is a real password); `REDIS_HOST`, `REDIS_PORT` (6379), `REDIS_USERNAME` (default), `REDIS_PASSWORD`; `ROMM_AUTH_SECRET_KEY` (`required: true`, no insecure default, `start.sh` must refuse to start without it or generate one into `/config` on first run); `TZ` default `Etc/UTC`. Only list variables the app reads.
- `volumes`: `/config` `required: true`. The chart paths `/romm/library`, `/romm/resources`, `/romm/config`, `/romm/assets` map to `/config/romm/...` (`start.sh`), so they are not listed as separate volumes.
- `dependencies`: `postgresql` (hard, `apps/postgresql` exists, mark ✅), `valkey` (`apps/valkey` exists, mark ✅, put under `opt_dependencies` if optional in the app).

## 7. start.sh

- Idempotent. Create `/config/romm/{library,resources,config,assets}` only when missing (`mkdir -p`), and link them into `/app/...` paths the app expects, or set env vars so the app reads them from `/config` (verify the path env names, `UNVERIFIED`).
- Do not write to `/app`. Caches (`XDG_CACHE_HOME`, pip, uv) go to `/tmp`.
- Refuse to start if `ROMM_AUTH_SECRET_KEY` is empty or equal to the placeholder, with a clear log line. Do not print the secret.
- Wait for postgresql and valkey with a bounded retry (log each attempt). Do not block forever.
- Bind to `0.0.0.0` for the web port.
- Final command: `exec` the gunicorn or uvicorn process from `/app/venv/bin`, reading `ROMM_PORT`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: requires external postgresql and valkey; full functional test not feasible in single-container suite
tcp:
- port: '10680'
filePaths:
- /app/venv/bin/python
```

The `tcp` probe is kept because every settings.yaml port needs one, but it only passes if the server listens without env vars; if `start.sh` refuses to start without `ROMM_AUTH_SECRET_KEY`, the probe fails. Resolve by letting `start.sh` generate the key into `/config` on first run (settings.yaml option above), or drop the probe with a stated reason (UNVERIFIED which is chosen).

- Every port in `settings.yaml` needs a probe.
- The app needs `DB_PASSWD` and `ROMM_AUTH_SECRET_KEY` to start cleanly, so the test has no env vars and the process may not start past the secret check. This is the DB-dependency exception (see the build and test protocol); run the env-set path by hand. Do not weaken the check.
- `timeoutSeconds` is `UNVERIFIED`; choose a value from the python sibling (`apps/bazarr`).

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (uid from base). Port 10680 is above 1024.
- Upstream chart runs as root (`runAsUser 0`). The rootless image uses `USER apps` and no root-only paths.
- Upstream writes that must move: `/etc/nginx/conf.d` and `/etc/gunicorn` (chmod a+w upstream) → `/tmp` or `/config` via env or copied config; `/romm` and `/redis-data` (declared volumes) → `/config/romm/*`; `/var/www/html` (frontend) is read-only from `/app`; nginx temp and logs → `/tmp`.
- Valkey and the DB stay in their own sibling containers.
- Read-only rootfs: `/app` read-only, `/tmp` is tmpfs, `/config` is the only persistent path.

## 10. Risks, caveats and open questions

- Multi-process: the upstream image runs `/init` with nginx, gunicorn and background tasks. Supervising these under a read-only rootfs is the main work. `UNVERIFIED`: whether 5.4.1 needs nginx at all in a trueforge layout.
- An external DB must exist before first start (inferred from the draft; confirmed by the chart's postgresql dependency).
- ROM library must be mounted and populated by the user; metadata API keys (IGDB, ScreenScraper) are entered manually (manual setup).
- The admin account is created in the web UI after first start (manual setup).
- The upstream image sets `SCREENSCRAPER_DEV_ID` and `SCREENSCRAPER_DEV_PASSWORD` in the image metadata; do not replicate that.
- arm64: `UNVERIFIED`. The `emsdk` build stage is amd64 only in upstream (`--platform=linux/amd64` and `arm64` both present); `gme-build` needs a per-arch decision.
- Checksum: no upstream checksum on the release; pin a self-computed SHA256 for the source tarball.

## 11. Build and test steps

```sh
cd apps/romm
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name romm-probe --read-only --tmpfs /tmp \
  -e ROMM_AUTH_SECRET_KEY=test-only-not-for-prod -e DB_PASSWD=unused \
  -v romm-probe-config:/config romm:5.4.1
docker logs -f romm-probe
docker rm -f romm-probe; docker volume rm romm-probe-config

forgetool containers test --image romm:5.4.1 --config ./apps/romm/container-test.yaml
```

Expected readiness signal: the app logs that it is listening on `10680` (`UNVERIFIED` exact text), or, without a DB, a bounded "waiting for database" line with the process still alive. The test with no env vars must stay in the secret-missing path (see section 8). Run with an empty `/config` each round. Also run once with a real postgresql and valkey from `apps/postgresql` and `apps/valkey` in a compose-style network to get the full readiness signal (manual, not in CI).

## 12. PR checklist

- Branch `feat/add-romm`, commit `feat(romm): add new container`, target `main`.
- PR title matches the commit.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`; Notes has `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what was not tested: arm64, the full run against postgresql and valkey, the IGDB and ScreenScraper metadata flows, and any step not run.
- Confirm `docker buildx bake --print` ran and scratch resources were removed.
