# linkding — implementation plan
> Source: ./draft.md · Target: apps/linkding/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v1.47.0, published 2026-09-13 (draft tag `1.47.0` matches). Source: https://api.github.com/repos/sissbruecker/linkding/releases/latest |
| Renovate | `datasource=github-releases depName=sissbruecker/linkding versioning=semver` (the tag is `v1.47.0`, so the source URL adds the `v`) |
| License | MIT. Source: https://api.github.com/repos/sissbruecker/linkding |
| Source URL | https://github.com/sissbruecker/linkding |
| Download | Source archive `https://github.com/sissbruecker/linkding/archive/refs/tags/v${VERSION}.tar.gz`. Upstream has no release assets, so there is no prebuilt binary. |
| Checksum source | None published by upstream. UNVERIFIED: no checksum to check against. Mitigation: the tag is fetched over HTTPS from GitHub; record the archive SHA256 in the PR description for review. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/sissbruecker/linkding/24b5ad6/docker/default.Dockerfile: stages `node:22-alpine` (frontend and uBlock), `python:3.13.7-slim-trixie` (build-deps, linkding). Frontend `npm ci` and `npm run build`. Python `uv 0.8.13` and `uv sync --no-dev --group postgres`. ICU extension compiled for SQLite 3.43.0. `CMD ["./bootstrap.sh"]`, no ENTRYPOINT, EXPOSE 9090, WORKDIR `/etc/linkding`, no USER, no VOLUME. The `linkding-plus` stage (Chromium, single-file) is not part of this app. |
| Bootstrap reviewed | https://raw.githubusercontent.com/sissbruecker/linkding/v1.47.0/bootstrap.sh: creates `data/`, `data/favicons`, `data/previews`, `data/assets`; runs `generate_secret_key`, `migrate`, `enable_wal`, `create_initial_superuser`, `migrate_tasks`; then `chown -R www-data: /etc/linkding/data`; then `exec uwsgi --http $LD_SERVER_HOST:$LD_SERVER_PORT uwsgi.ini`, with background tasks under a daemonized `supervisord -c supervisord-tasks.conf` unless `LD_DISABLE_BACKGROUND_TASKS=True`. `LD_SUPERVISOR_MANAGED=True` takes the `supervisord-all.conf` path. |
| Env vars (real) | `LD_SERVER_HOST` (default `[::]`), `LD_SERVER_PORT` (default `9090`), `LD_SUPERVISOR_MANAGED`, `LD_DISABLE_BACKGROUND_TASKS`, `LD_CONTEXT_PATH` (used by the upstream healthcheck), `UWSGI_MAX_FD=4096`, `VIRTUAL_ENV=/etc/linkding/.venv`. |
| Admin creation | UNVERIFIED: `create_initial_superuser` reads its username, email and password from environment variables defined in the management command (not fetched). Exact names must be confirmed before settings.yaml lists them. |
| Port | 9090/tcp |
| Data paths (upstream) | `/etc/linkding/data` (SQLite database, favicons, previews, assets). |
| arm64 | UNVERIFIED for the upstream image. The source build with the python slim base is arch-neutral. |

## 2. Target layout

- `apps/linkding/Dockerfile`
- `apps/linkding/docker-bake.hcl`
- `apps/linkding/settings.yaml`
- `apps/linkding/container-test.yaml`
- `apps/linkding/start.sh` (replaces upstream `bootstrap.sh`, because the upstream one runs `chown` as root and `uwsgi` as the main process)

No `defaults/`, `etc/` or `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Upstream builds on `python:3.13.7`. Pinning 3.15.2 follows the brief's base table. UNVERIFIED: that linkding's dependency set installs on Python 3.15 (check `requires-python` and the `uv.lock` in the build step; if not, fall back to a 3.13-series base in `apps/python` tags and record the reason). Closest sibling: `apps/bazarr` or other Python web apps built from a pinned tarball with `/app/venv` (the base venv is read-only per the python-runtime rules).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`. `ENV LD_SERVER_HOST=[::] LD_SERVER_PORT=9090 UWSGI_MAX_FD=4096`.
2. Frontend build stage `FROM node:22-alpine` is not reused: the base is glibc Ubuntu-style and the `node` runtime is needed only during the build. Instead, install Node in the build step from the `python` base only if it is present, otherwise use a separate `FROM` build stage with `node:22-bookworm-slim` pinned by digest. UNVERIFIED: whether `apps/python` ships Node; if not, use a multi-stage build with `FROM node:22-slim@sha256:<digest>` as the frontend stage and `COPY --from=` the built `static` files.
3. Download the source: `curl -fsL https://github.com/sissbruecker/linkding/archive/refs/tags/v${VERSION}.tar.gz -o /tmp/linkding.tar.gz` and `tar xzf ... -C /app/linkding --strip-components=1`. Keep the archive out of the image (`rm /tmp/linkding.tar.gz`).
4. Frontend: `npm ci && npm run build` in `/app/linkding` (from the upstream node stage). Use `--cache /tmp/npm-cache` or `NPM_CONFIG_CACHE=/tmp/npm`.
5. Python deps: install `uv==0.8.13` into `/app/venv`, then `uv sync --no-dev --frozen` pointed at the base venv (`UV_PROJECT_ENVIRONMENT=/app/venv`) or `uv export --frozen --no-dev --no-hashes > /tmp/req.txt` followed by `/app/venv/bin/pip install -r /tmp/req.txt`. UNVERIFIED which of these works with the base venv; pick the one that keeps `/app/venv` the only environment.
6. ICU extension: the upstream `libicu.so` build is needed only for the ICU collation in SQLite. Port it from the upstream stage (compile in a build stage, `COPY --from=build /out/libicu.so /usr/local/lib/`), or check whether the base already has `libicu-dev` (the `webgrabplus` sibling relies on the base's ICU). UNVERIFIED which path the app expects.
7. Collect static files: `python manage.py collectstatic --noinput` run during build with `DJANGO_SETTINGS_MODULE` default. Then `chmod -R g=u /app/linkding` (group-writable only where needed).
8. Data remap: `ln -s /config/data /app/linkding/data` at build time, so the relative `data/` path in bootstrap resolves to `/config/data`.
9. Licence: `cp /app/linkding/LICENSE /usr/share/licenses/linkding/LICENSE`.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 9090
VOLUME /config
WORKDIR /app/linkding
```

Do not set `HEALTHCHECK` in the Dockerfile; the harness probes ports from `settings.yaml`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "linkding"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=sissbruecker/linkding versioning=semver
  default = "1.47.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/sissbruecker/linkding"
}
```

Then the standard `group "default"`, `target "image"` (args `VERSION`, OCI labels `source` and `licenses`), `image-local`, `image-all` (linux/amd64, linux/arm64), copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/sissbruecker/linkding"
ports:
  - port: 9090
    protocol: tcp
    required: false
env:
  - name: LD_SERVER_HOST
    default: "[::]"
    required: false
  - name: LD_SERVER_PORT
    default: "9090"
    required: false
  - name: LD_DISABLE_BACKGROUND_TASKS
    default: "False"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Admin account env names are UNVERIFIED (section 1). Add them to `env` only once confirmed, with `required: false` (first-run creation is optional; the admin can be created by shell).
- `dependencies`: none (SQLite by default; the postgres group is optional and not built in).
- Do not list `LD_SUPERVISOR_MANAGED`: not used by the start script.

## 7. start.sh

Replicates the upstream `bootstrap.sh` steps without the `chown`, so it works as `apps` and under a read-only rootfs.

```bash
#!/usr/bin/env bash

mkdir -p /config/data/favicons /config/data/previews /config/data/assets

cd /app/linkding || exit 1

python manage.py generate_secret_key
python manage.py migrate
python manage.py enable_wal
python manage.py create_initial_superuser || true
python manage.py migrate_tasks

export LD_SERVER_HOST="${LD_SERVER_HOST:-[::]}"
export LD_SERVER_PORT="${LD_SERVER_PORT:-9090}"

exec uwsgi --http "${LD_SERVER_HOST}:${LD_SERVER_PORT}" uwsgi.ini
```

- `create_initial_superuser || true`: this only tolerates "already exists" on restarts. UNVERIFIED that the command exits non-zero only for that case; if it exits non-zero for other reasons, the `|| true` hides them. Prefer checking the output first.
- `generate_secret_key` must not regenerate on restart (UNVERIFIED): if it does, sessions break. Confirm in the run.
- Background tasks: the upstream daemonized `supervisord-tasks.conf` is skipped here unless it is needed; run the `tasks` path explicitly only if `LD_DISABLE_BACKGROUND_TASKS` is not `True` (see section 10). UNVERIFIED: whether `migrate_tasks` alone is enough for Huey to run in-process.
- Idempotent on empty `/config`: creates the `data` tree and runs migrations each start.
- `exec` the final `uwsgi` so it gets signals.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '9090'
http:
- port: '9090'
  path: /health
filePaths:
- /app/linkding/manage.py
- /app/linkding/static
- /usr/share/licenses/linkding/LICENSE
```

- `/health` is the path the upstream Dockerfile healthcheck uses (`${LD_CONTEXT_PATH}health`), so the probe matches upstream. UNVERIFIED that `/health` returns 200 on first start before a superuser exists.
- `timeoutSeconds: 180`: migrations plus static setup on an empty `/config`. Compare with `apps/bazarr` for the Python family.
- Tests run without env, so the upstream default `[::]` bind is what is probed. Check the bind address from outside the container during the run (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/etc/linkding/data` (SQLite, favicons, previews, assets) | Build-time symlink `/app/linkding/data` -> `/config/data`. `start.sh` creates the tree under `/config`. |
| `/etc/linkding/data` ownership (`chown www-data:`) | Dropped. The `apps` user owns `/config`. |
| `uwsgi` and supervisor sockets/logs | UNVERIFIED: `uwsgi.ini` and `supervisord-tasks.conf` may write pidfiles or sockets next to the app. Check the `--read-only --tmpfs /tmp` run log. If they write under `/app/linkding`, point them at `/tmp`. |
| Python bytecode | `PYTHONDONTWRITEBYTECODE=1` (set in `ENV`) so nothing is written into `/app/venv`. |
| Build caches (uv, pip, npm) | `UV_CACHE_DIR=/tmp/uv`, `PIP_NO_CACHE_DIR=1`, `NPM_CONFIG_CACHE=/tmp/npm`, removed in the same layer. |

Draft expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. This image runs as `apps` and works with a read-only rootfs on paper. The chart's extra persistence is `/etc/linkding/data`, which becomes `/config/data` here. Existing users must move their data to `/config/data`.

## 10. Risks, caveats and open questions

- Admin account creation: upstream has no interactive setup. The draft says it is done from a shell; this plan keeps `create_initial_superuser` at start so an env-driven admin works once the variable names are confirmed. Until then, the admin is created with `docker exec`.
- Two processes: uWSGI plus the Huey task runner. Upstream runs the tasks under a daemonized supervisord. This plan starts uWSGI as PID 1 and must confirm that tasks run (background-task log lines appear). If they do not, add a supervisor config under `/tmp` or a minimal supervisor in `start.sh`, as the draft caveat says.
- Python 3.15 support for all linkding dependencies is UNVERIFIED (section 3).
- ICU extension is needed for SQLite collation; if the base does not have it, the app may start but a feature (search/sorting) may differ. UNVERIFIED impact.
- arm64: UNVERIFIED for the source build and the ICU compile step.
- Upstream releases carry no checksum: the archive hash is recorded in the PR instead.
- Blockers: none known (no musl-only, no GPU, not privileged, not a dependency on another container).

## 11. Build and test steps

```sh
cd apps/linkding
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name linkding-probe --read-only --tmpfs /tmp \
  -v linkding-probe-config:/config linkding:1.47.0
docker logs -f linkding-probe
forgetool containers test --image linkding:1.47.0 --config ./apps/linkding/container-test.yaml
docker rm -f linkding-probe; docker volume rm linkding-probe-config
```

- Expected readiness signal: uWSGI log line `spawned uWSGI worker` and the `listening on` line with the bind address, plus `/health` returning 200.
- Check that `/config/data/` holds the SQLite database after the first start and that a restart keeps it.
- Check from outside the container (`-p 9090:9090`) that the `[::]` bind is reachable.
- arm64 only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-linkding`, commit and PR title `feat(linkding): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Untested to state honestly: the build on arm64, the Python 3.15 compatibility, the ICU extension, the admin env names, the background-task process model, and the `/health` status on an empty `/config`.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
