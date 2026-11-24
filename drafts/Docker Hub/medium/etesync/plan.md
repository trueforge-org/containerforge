# etesync — implementation plan
> Source: ./draft.md · Target: apps/etesync/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

The plan targets the same version as the draft: the TrueCharts image `victorrds/etesync:0.14.2` is built from `etesync/server` tag `v0.14.2`, which is the newest tag upstream (tags `v0.13.0` to `v0.14.2` exist). The plan builds from the upstream source tag directly, not from the third-party `victor-rds/docker-etebase` image.

| Item | Value |
| --- | --- |
| Version | `0.14.2` (tag `v0.14.2` of `etesync/server`; the same version as the draft) |
| Renovate | `datasource=github-tags depName=etesync/server versioning=semver` |
| License | AGPL-3.0 (`LICENSE` is the GNU Affero GPL v3 text). SPDX: `AGPL-3.0-only`. |
| Source | https://github.com/etesync/server |
| Download | https://github.com/etesync/server/archive/refs/tags/v0.14.2.tar.gz (source archive, arch independent; dependencies come from PyPI wheels) |
| Checksum | None published for the tag archive. |
| Upstream Dockerfile reviewed | https://github.com/victor-rds/docker-etebase/blob/c06eb631/tags/base/Dockerfile (`python:3.12.4`, `git clone` of the tag, `pip install -r requirements.txt psycopg2-binary python-ldap`, `collectstatic`, user 373, `DATA_DIR=/data`, `PORT=3735`). The upstream project itself ships no Dockerfile in the form used by the chart. Its README documents `uvicorn etebase_server.asgi:application --host 0.0.0.0 --port 8000`. |

Facts read from `etebase_server/settings.py` at v0.14.2:

- Config file path from env `ETEBASE_EASY_CONFIG_PATH`, else `etebase-server.ini`, else `/etc/etebase-server/etebase-server.ini`. Sections: `[global]` (`secret_file`, `debug`, `static_root`, `media_root`, `static_url`, `media_url`, `language_code`, `time_zone`, `redis_uri`), `[allowed_hosts]`, `[database]` (keys uppercased and passed as Django DB settings, for example `engine`, `name`, `user`, `password`, `host`, `port`), `[database-options]`, `[ldap]`.
- Env vars: `ETEBASE_DB_PATH` (SQLite path when no ini `[database]`), `ETEBASE_EASY_CONFIG_PATH`, `DJANGO_STATIC_ROOT`, `DJANGO_MEDIA_ROOT`.
- `DEBUG` defaults to `True` when no ini; the ini must set `debug = false`.
- The secret file is auto-created with mode 0600 if missing (`get_secret_from_file` in `etebase_server/utils.py`).
- FastAPI mounts `STATIC_ROOT` at start (`StaticFiles(directory=...)`), so the directory must exist.
- Health-style endpoint: `GET /api/v1/authentication/is_etebase/` (route confirmed in `fastapi/routers/authentication.py`, prefix `/api/v1/authentication` in `fastapi/main.py`).
- Dependencies from `requirements.in/base.txt`: `django>=4.0,<5.0`, `msgpack`, `pynacl`, `fastapi>=0.104`, `pydantic>=2.0.0`, `typing_extensions`, `uvicorn[standard]`, `aiofiles`, `redis>=4.2.0rc1`. The generated `requirements.txt` was compiled for Python 3.12 (django 4.2.13, fastapi 0.111.0).

## 2. Target layout

```
apps/etesync/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (the ini is generated at start). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Python server installed by pip, so the python base fits (as the draft says). Closest sibling: `apps/apprise-api` (Django app from a GitHub tarball into `/app`, venv at `/app/venv`, wheels from the linuxserver wheel index) and `apps/bazarr`. Follow `python-runtime.instructions.md`.

## 4. Dockerfile

1. `FROM` from section 3, `ARG VERSION`, `ARG TARGETARCH` (omit if unused).
2. `USER root`.
3. `ENV HOME=/tmp DJANGO_STATIC_ROOT=/app/static DJANGO_MEDIA_ROOT=/config/media ETEBASE_DB_PATH=/config/db.sqlite3 ETEBASE_EASY_CONFIG_PATH=/tmp/etebase-server.ini`
4. One `RUN` layer:
   - `apt-get update && apt-get install -y --no-install-recommends libpq5 libffi8 ca-certificates` (runtime libs for `psycopg2-binary` are bundled in that wheel, so `libpq5` is probably unnecessary; keep only what the run test proves needed). Build tools (`build-essential`, `libffi-dev`, `libssl-dev`, `cargo`) are needed only when a wheel is missing for Python 3.15 and arm64; purge them afterwards. Do not re-install packages that the base already provides.
   - `mkdir -p /app/etesync /usr/share/licenses/etesync && curl -fsSL -o /tmp/etesync.tar.gz "https://github.com/etesync/server/archive/refs/tags/v${VERSION}.tar.gz" && tar xzf /tmp/etesync.tar.gz -C /app/etesync --strip-components=1`
   - `/app/venv/bin/pip install --no-cache-dir -r /app/etesync/requirements.txt psycopg2-binary` (the pinned file; if some pin lacks a Python 3.15 wheel, fall back to `-r /app/etesync/requirements.in/base.txt` plus `psycopg2-binary`, and note the resolved versions in the PR). `python-ldap` from the third-party image is omitted: LDAP is not requested by the draft (see section 10).
   - `cd /app/etesync && DJANGO_STATIC_ROOT=/app/static /app/venv/bin/python manage.py collectstatic --no-input` (needs a settings load, which creates `/app/etesync/secret.txt`; delete it right after: `rm -f /app/etesync/secret.txt`)
   - `cp /app/etesync/LICENSE /usr/share/licenses/etesync/LICENSE`
   - `chown -R apps:apps /app && chmod -R 755 /app`, `apt-get clean`, `rm -rf /var/lib/apt/lists/* /tmp/*`
5. `USER apps`
6. `COPY --chmod=0755 . /`
7. `WORKDIR /app/etesync`, `EXPOSE 8000`, `VOLUME /config`.

The `ENV ETEBASE_EASY_CONFIG_PATH` and `DJANGO_*` values are the real variable names read by `settings.py`.

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "etesync"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=etesync/server versioning=semver
  default = "0.14.2"
}

variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/etesync/server"
}
```

Plus `docker-metadata-action`, `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (amd64, arm64) and the default group, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/etesync/server"
ports:
  - port: 8000
    protocol: tcp
    required: true
env:
  - name: ETEBASE_ALLOWED_HOSTS
    default: "*"
    required: false
  - name: DATABASE_ENGINE
    default: "sqlite"
    required: false
  - name: POSTGRES_HOST
    default: ""
    required: false
  - name: POSTGRES_PORT
    default: "5432"
    required: false
  - name: POSTGRES_DB
    default: "etesync"
    required: false
  - name: POSTGRES_USER
    default: "etesync"
    required: false
  - name: POSTGRES_PASSWORD
    default: ""
    required: false
  - name: ETEBASE_REDIS_URI
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
  - name: valkey
```

`ETEBASE_ALLOWED_HOSTS`, `DATABASE_ENGINE`, `POSTGRES_*` and `ETEBASE_REDIS_URI` are wrapper variables defined and read by `start.sh`, which turns them into the ini file; they are not read directly by etesync. Names `ETEBASE_DB_PATH`, `ETEBASE_EASY_CONFIG_PATH`, `DJANGO_STATIC_ROOT` and `DJANGO_MEDIA_ROOT` are real upstream variables but are fixed in the Dockerfile and not exposed.

Dependencies: postgresql ✅ (`apps/postgresql` exists), valkey ✅ (`apps/valkey` exists). Both are optional because SQLite works by default; the draft lists them as chart dependencies.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/media

esc() { printf '%s' "${1//%/%%}"; }   # ConfigParser interpolation

ini="${ETEBASE_EASY_CONFIG_PATH:-/tmp/etebase-server.ini}"
umask 077
{
  echo "[global]"
  echo "secret_file = /config/secret.txt"
  echo "debug = false"
  echo "media_root = /config/media"
  echo "static_root = /app/static"
  [ -n "${ETEBASE_REDIS_URI:-}" ] && echo "redis_uri = $(esc "$ETEBASE_REDIS_URI")"
  echo "[allowed_hosts]"
  i=0
  IFS=',' read -ra hosts <<< "${ETEBASE_ALLOWED_HOSTS:-*}"
  for h in "${hosts[@]}"; do i=$((i+1)); echo "allowed_host${i} = $(esc "$h")"; done
  echo "[database]"
  if [ "${DATABASE_ENGINE:-sqlite}" = "postgresql" ]; then
    echo "engine = django.db.backends.postgresql"
    echo "name = $(esc "${POSTGRES_DB:-etesync}")"
    echo "user = $(esc "${POSTGRES_USER:-etesync}")"
    echo "password = $(esc "${POSTGRES_PASSWORD:-}")"
    echo "host = $(esc "${POSTGRES_HOST:?POSTGRES_HOST is required when DATABASE_ENGINE=postgresql}")"
    echo "port = $(esc "${POSTGRES_PORT:-5432}")"
  else
    echo "engine = django.db.backends.sqlite3"
    echo "name = /config/db.sqlite3"
  fi
} > "$ini"
export ETEBASE_EASY_CONFIG_PATH="$ini"

cd /app/etesync
/app/venv/bin/python manage.py migrate --no-input
exec /app/venv/bin/uvicorn etebase_server.asgi:application --host 0.0.0.0 --port 8000
```

- Idempotent: the secret file and SQLite DB are created only when missing (upstream creates `secret.txt` with 0600 on first load); `migrate` is a no-op when current.
- The ini is regenerated into `/tmp` (tmpfs, mode 0600) on every start, so changing the database password in the environment also applies on existing data, and the DB password is never stored in `/config`.
- Nothing is written to `/app`. `static_root` is read-only at runtime (built at image build time). `secret_file`, media and DB are in `/config`.
- Binds `0.0.0.0:8000` (an upstream README command).
- The final command is `exec uvicorn`. `allowed_hosts` default `*` mirrors a first-run setup; users should set real hostnames.
- The superuser is created manually: `docker exec -it <ctr> /app/venv/bin/python /app/etesync/manage.py createsuperuser` (upstream README step). Not automated, to keep credentials out of the environment and files.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120

http:
- port: '8000'
  path: /api/v1/authentication/is_etebase/

filePaths:
- /app/etesync/manage.py
- /app/static
- /app/venv/bin/uvicorn
- /usr/share/licenses/etesync/LICENSE
```

- The `http` probe covers port 8000 (the endpoint is a plain `GET` that needs no auth; expect 200).
- The test runs with no env vars, so it exercises the SQLite default. PostgreSQL and Valkey paths cannot be tested here and must be run by hand (section 11). Because Postgres is optional, the DB-dependency narrowing exception does not apply and no narrowing is used.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (`DATA_DIR`), `/data/secret.txt`, `/data/etebase-server.ini`, `/data/media` | `/config` (`secret.txt`, `media/`, `db.sqlite3`). The ini lives in `/tmp` (generated). |
| `/srv/etebase/static` (collectstatic output) | Built at image build time into `/app/static`, read-only at runtime. |
| `<app>/secret.txt` created by collectstatic at build | Deleted at the end of the build step. |
| `<app>/db.sqlite3` default | `ETEBASE_DB_PATH=/config/db.sqlite3` and the ini `[database]`. |
| Container user 373:373 (chart `runAsUser 373`, `fsGroup 373`) | Runs as `apps`. Existing data from the TrueCharts volume (`/data`) must be mounted at `/config` and be readable by the `apps` UID (the chart's data is owned by 373). |
| `readOnlyRootFilesystem: false` (chart) | Read-only rootfs supported; only `/config` and `/tmp` are written. |

The draft's extra persistence (`/data` PVC and a read-only `/data/secret.txt` secret file) maps to `/config`. To keep an existing secret, place it at `/config/secret.txt` before the first start.

## 10. Risks, caveats and open questions

- **Python 3.15 compatibility (UNVERIFIED).** `requirements.txt` was compiled on Python 3.12 (django 4.2.13, fastapi 0.111.0, pydantic 2.x with `pydantic-core`, `pynacl`, `cffi 1.16`, `httptools`, `uvloop`). Wheels for 3.15 may be missing, which forces compiler packages or an unpinned resolve. The third-party image uses Python 3.12.4.
- Third-party image: the draft's Dockerfile is from `victor-rds`, not upstream. This plan builds from upstream source and only borrows its structure; the entrypoint and ini template of that image (not found at the tested path) were not reviewed, so the `start.sh` here is original and unproven.
- LDAP: the third-party image installs `python-ldap`; this plan omits it. Add `libldap2-dev libsasl2-dev` build deps and `python-ldap` if LDAP support is required (UNVERIFIED need).
- A superuser must be created manually after the first start (upstream requirement). Users also need an HTTPS reverse proxy; the server does not terminate TLS.
- `allowed_hosts` default `*` is permissive; document setting it. `debug = false` is forced.
- Valkey (`redis_uri`) is optional, used for realtime sync. UNVERIFIED which redis URI format etesync expects beyond `redis://host:6379`; the upstream example is `redis://localhost:6379`.
- `uvicorn` is started single-process; upstream suggests a production deployment with a proxy but does not require extra workers.
- No amd64/arm64 blocker is known beyond wheel availability.

## 11. Build and test steps

```sh
cd apps/etesync
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name etesync-probe --read-only --tmpfs /tmp \
  -v etesync-probe-config:/config etesync:0.14.2
docker logs -f etesync-probe

# from the repo root
forgetool containers test \
  --image etesync:0.14.2 \
  --config ./apps/etesync/container-test.yaml

docker rm -f etesync-probe; docker volume rm etesync-probe-config
```

Readiness signal: Django migrations complete (`Applying ... OK`), then uvicorn logs `Uvicorn running on http://0.0.0.0:8000` and `Application startup complete`; `curl http://localhost:8000/api/v1/authentication/is_etebase/` returns 200; `/config/secret.txt` and `/config/db.sqlite3` exist. Also test by hand: restart the container (secret unchanged), a run with `-e DATABASE_ENGINE=postgresql -e POSTGRES_HOST=...` against `apps/postgresql`, and `createsuperuser`.

## 12. PR checklist

- Branch `feat/add-etesync`, commit and PR title `feat(etesync): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only what applies.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Mention the data path change (`/data` to `/config`) and the UID change (373 to `apps`) in the PR.
- Pre-completion: bake `--print` exits 0, `ARG VERSION` equals the bake default, final `USER apps`, `COPY --chmod=0755 . /`, empty-`/config` start on `--read-only --tmpfs /tmp`.
- Untested until run: the build (pip resolution on 3.15), PostgreSQL and Valkey paths, arm64, the manual superuser step and the forgetool run. State this in the PR and leave "Built container locally" unchecked if not done.
