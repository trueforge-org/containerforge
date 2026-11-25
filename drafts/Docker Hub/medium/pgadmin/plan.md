# pgadmin — implementation plan
> Source: ./draft.md · Target: apps/pgadmin/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 9.19 (PyPI `info.version`, uploaded 2026-10-29T15:36:19 UTC). Docker Hub `dpage/pgadmin4:9.19` last updated 2026-10-29. Source: https://pypi.org/pypi/pgadmin4/json and https://hub.docker.com/v2/repositories/dpage/pgadmin4/tags/9.19 |
| Renovate | `// renovate: datasource=pypi depName=pgadmin4 versioning=pep440` on `VERSION` (the wheel is the artifact). Exact renovate config not confirmed on a fetched page (UNVERIFIED). |
| License | PostgreSQL Licence (PyPI `license` field, https://pypi.org/pypi/pgadmin4/json). SPDX id `PostgreSQL` is the expected identifier, UNVERIFIED as an SPDX mapping. GitHub API reports `NOASSERTION` for pgadmin-org/pgadmin4 (https://api.github.com/repos/pgadmin-org/pgadmin4). Confirm against the repo `LICENSE` file before writing `LICENSE`. |
| Source URL | https://github.com/pgadmin-org/pgadmin4 |
| Download | `pgadmin4-9.19-py3-none-any.whl` (the only file listed for 9.19 on PyPI; no sdist). Pure Python wheel, so the same file serves amd64 and arm64. Exact PyPI file URL and hash not read (UNVERIFIED). |
| Per-arch download | amd64: same wheel. arm64: same wheel (no native code in the wheel). |
| Checksum source | PyPI JSON `digests` for the wheel (sha256). Not read in this run (UNVERIFIED value); use `pip install --require-hashes` with the hash from the PyPI JSON, or verify the digest in the Dockerfile. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/pgadmin-org/pgadmin4/REL-9_19/Dockerfile. Stages: `alpine:latest` (app-builder, tool-builder), `python:3-alpine` (env-builder, final), `postgres:13-alpine` to `postgres:18-alpine` (pg13-builder to pg18-builder, binary sources only). Final stage: `WORKDIR /pgadmin4`, `ENV PYTHONPATH=/pgadmin4`, `EXPOSE 80 443`, `VOLUME /var/lib/pgadmin`, `USER 5050`, `ENTRYPOINT ["/entrypoint.sh"]`, no CMD. Grants `CAP_NET_BIND_SERVICE` to a copy of Python. |
| Upstream entrypoint | `/entrypoint.sh` (source `pkg/docker/entrypoint.sh` in the repo). Not fetched in this run (UNVERIFIED contents). |
| Bind address and port | Set in `run_pgadmin.py` and `gunicorn_config.py` (not fetched). The HTTP port for our build is chosen by us (see section 4). |
| Data paths | `/var/lib/pgadmin` (upstream volume, owned by `pgadmin`), `/run/pgadmin` (runtime dir), `/pgadmin4` (app), `/venv` (Python venv), `/usr/local/pgsql-13..18` (pg client tools). |
| Env vars | Upstream names `PYTHONPATH=/pgadmin4`. Admin login env vars `PGADMIN_DEFAULT_EMAIL` and `PGADMIN_DEFAULT_PASSWORD` are expected from upstream docs and the draft, but are NOT confirmed on a fetched page (UNVERIFIED; read them from `pkg/docker/entrypoint.sh` before writing `settings.yaml`). |
| Arm64 | Wheel is architecture-independent. Docker Hub `dpage/pgadmin4:9.19` lists amd64 and arm64 (upstream image). |
| Dependencies | None to start. PostgreSQL client tools are used only by backup and restore features. |

Draft says the chart runs as uid 5050 with `runAsNonRoot: true`. Upstream Dockerfile confirms `USER 5050`, so this matches.

## 2. Target layout

- `apps/pgadmin/Dockerfile`
- `apps/pgadmin/docker-bake.hcl`
- `apps/pgadmin/settings.yaml`
- `apps/pgadmin/container-test.yaml`
- `apps/pgadmin/start.sh`

No `defaults/`, `etc/`, `scripts/` or `health/` needed: pgAdmin creates its own config in `/config` on first start (see section 7). Never use `root/`. No `DOWNSTREAM_CHANGES.md`: this app is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Fits because pgAdmin is a pure Python web app and the python base already provides Python 3.15 and `pip`. The upstream image uses `python:3-alpine` (musl); the ContainerForge build must use the glibc Ubuntu-based python base (rule: musl builds do not run here). Closest sibling: `apps/bazarr` (python base, apt packages, `USER apps` and `COPY --chmod=0755 . /`).

## 4. Dockerfile

1. Header: `# renovate` comment is in `docker-bake.hcl`. Dockerfile takes `ARG VERSION` (must match bake default `9.19`) and `ARG TARGETARCH`.
2. `USER root` for installs only.
3. Install runtime apt packages, pinned to what the base archive provides, without recommends:
   - `libpq5` (pgAdmin's psycopg driver; check against the base image first, install only if absent).
   - `libmagic1` (file type detection; draft says inferred, verify with `ldd` on the venv in the test step).
   - Optional: `postgresql-client-18` (or the matching client) so backup and restore work. Decision to make, see section 10. Do not add it silently.
4. Install the wheel into a venv under `/app/pgadmin/venv` at build time (writes only at build, never at runtime; rule: `/app` is read-only at runtime):
   ```dockerfile
   ARG VERSION
   RUN /usr/local/bin/python -m venv --system-site-packages /app/pgadmin/venv \
       && curl -fsSL -o /tmp/pgadmin4.whl "https://files.pythonhosted.org/packages/.../pgadmin4-${VERSION}-py3-none-any.whl" \
       && echo "<sha256>  /tmp/pgadmin4.whl" | sha256sum -c - \
       && /app/pgadmin/venv/bin/pip install --no-cache-dir /tmp/pgadmin4.whl gunicorn \
       && rm -f /tmp/pgadmin4.whl
   ```
   UNVERIFIED: `/usr/local/bin/python` path and the hard-coded `python3.15` site-packages path in `start.sh`; the base already ships `/app/venv` (python-runtime rule: read-only, use directly), so installing into `/app/venv` at build time is the simpler alternative. The exact PyPI wheel URL and sha256 must be read from the PyPI JSON (section 1, UNVERIFIED) before this step is written. Do NOT invent the hash.
5. Ship the license. The wheel's `LICENSE` (or the repo `LICENSE`) goes to `/usr/share/licenses/pgadmin/LICENSE`, `COPY` or `unzip` from the wheel dist-info (UNVERIFIED path inside the wheel).
6. `ENV PIP_CACHE_DIR=/tmp/pip-cache` (rule: caches in `/tmp`). Clean `/tmp/*` and apt lists after install.
7. Permissions: `chown -R root:root /app/pgadmin && chmod -R 755 /app/pgadmin` (bazarr pattern: runtime user cannot modify the app).
8. Final tail (bazarr and changedetection pattern):
   ```dockerfile
   ENV PGADMIN_HTTP_PORT=5050   # used by start.sh, not a pgAdmin variable (see section 7)
   USER apps
   COPY --chmod=0755 . /
   EXPOSE 5050
   VOLUME /config
   WORKDIR /config
   ```
   `EXPOSE` uses our port, not upstream's 80/443 (section 9).
9. No `ENTRYPOINT` override; the `start.sh` `exec` is the process (python-runtime and start-script rules).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "pgadmin"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=pgadmin4 versioning=pep440
  default = "9.19"
}

variable "LICENSE" {
  default = "PostgreSQL"
}

variable "SOURCE" {
  default = "https://github.com/pgadmin-org/pgadmin4"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

`LICENSE` value must be confirmed against the repo license (section 1). Validate with `docker buildx bake --print` from `apps/pgadmin/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/pgadmin-org/pgadmin4"
ports:
  - port: 5050
    protocol: tcp
    required: true
env:
  - name: PGADMIN_DEFAULT_EMAIL
    default: "admin@example.com"
    required: true
  - name: PGADMIN_DEFAULT_PASSWORD
    default: "change-me"
    required: true
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Ports: 5050 only (our listener). Upstream 80/443 are not used; do not list them.
- `PGADMIN_DEFAULT_EMAIL` and `PGADMIN_DEFAULT_PASSWORD` are UNVERIFIED names and defaults. Confirm the names in `pkg/docker/entrypoint.sh` before finalising. Defaults must match `start.sh` (rule). The `required: true` flag needs a non-empty default or a start-script fallback (settings rule); the defaults above are placeholders only. A baked default password is a shipped secret (start-script rule: no secrets in images): UNVERIFIED design, decide whether `start.sh` generates a random password on first run (logged once) or the variable is mandatory with no default.
- `dependencies: []` (no ContainerForge app required).
- Do not add env vars the app does not read.

## 7. start.sh

Idempotent, runs on an empty `/config`, writes only to `/config` and `/tmp`:

```bash
#!/usr/bin/env bash

mkdir -p /config/data /config/storage /tmp/pgadmin

export PGADMIN_CONFIG_DATA_DIR=/config/data
export PGADMIN_CONFIG_SESSION_DIR=/tmp/pgadmin/sessions
export PGADMIN_CONFIG_STORAGE_DIR=/config/storage
export PGADMIN_CONFIG_LOG_FILE=/tmp/pgadmin/pgadmin.log

# Seed admin credentials on every start so changing them in settings applies.
# Names are UNVERIFIED until read from upstream entrypoint.

cd /app/pgadmin

exec /app/pgadmin/venv/bin/gunicorn \
    --bind 0.0.0.0:5050 \
    --workers 1 \
    --threads 25 \
    --config /app/pgadmin/venv/lib/python3.15/site-packages/pgadmin4/gunicorn_config.py \
    pgadmin4:app
```

Notes:
- `PGADMIN_CONFIG_*` names are UNVERIFIED. pgAdmin reads `config_local.py` and `config_system`, so the reliable path is to write a `config_local.py` under `/config` only when missing, setting `DATA_DIR`, `SQLITE_PATH`, `STORAGE_DIR`, `SESSION_DB_PATH` and `LOG_FILE` to `/config` or `/tmp`. Verify in the wheel before choosing.
- The gunicorn config path and WSGI entry (`pgadmin4:app`) are UNVERIFIED (upstream `gunicorn_config.py` was not fetched). Read them from the installed wheel in the build step and use the real paths.
- Bind `0.0.0.0` (start-script network rule), `exec` so signals reach gunicorn.
- Admin account: pgAdmin needs the setup step to create the first user. Upstream entrypoint does this from the env vars; our `start.sh` must reproduce it (UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5050'
http:
- port: '5050'
  path: /misc/ping
filePaths:
- /app/pgadmin/venv/bin/gunicorn
- /app/pgadmin/venv/lib
- /usr/share/licenses/pgadmin/LICENSE
```

- `tcp` and `http` cover the one port in settings. `/misc/ping` is a pgAdmin endpoint but UNVERIFIED; check it returns 200 on a fresh `/config` (if not, use `/` and record the status).
- `filePaths` covers the venv and license. Upstream `/entrypoint.sh` path does not exist in our image.
- Test runs without env vars, so the admin-seeding path is not covered by the test. Add the seeding file to `filePaths` (the generated `config_local.py` path) and run the seeding path manually per section 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/lib/pgadmin` (volume, owned by `pgadmin`, uid 5050) | `/config` (persistent, owned by `apps`). Settings volume `/config`. |
| `/run/pgadmin` (runtime dir) | `/tmp/pgadmin` (ephemeral). |
| `/pgadmin4` (app) | `/app/pgadmin` (read-only at runtime; built once). |
| `/venv` | `/app/pgadmin/venv` (built once; never written at runtime). |
| `/usr/local/pgsql-NN` (client tools) | Not copied. Use `apt` `postgresql-client-*` if backups are required (section 10). |
| Ports 80 and 443 with `CAP_NET_BIND_SERVICE` | Port 5050 unprivileged, no capability. |
| Upstream `USER 5050` | `USER apps` (rule). Chart `runAsUser 5050` is replaced by the ContainerForge `apps` user. |
| Upstream `EXPOSE 80 443` | `EXPOSE 5050`. |

Chart security expectations (draft): non-root yes (5050), read-only-rootfs no, privileged no, fsGroup 5050. Target for ContainerForge: rootless `apps` user, read-only-rootfs compatible (writes only to `/config` and `/tmp`), no privileged. Chart's `readOnlyRootFilesystem: false` is not inherited.

## 10. Risks, caveats and open questions

- Upstream Dockerfile is Alpine/musl. Our build must use the glibc Ubuntu-based python base. Any musl-only wheel would fail. The pgAdmin wheel is pure Python, so this is expected to hold (UNVERIFIED for its optional dependencies).
- Admin setup: the first login needs the default admin email and password. Without them the UI cannot be used (draft). `start.sh` must seed them on each start and must not overwrite an existing user (start-script rule).
- Upstream runs as uid 5050. The chart does not pin that, so file ownership under `/config` must be checked on an empty volume and on restart.
- Backup and restore use `pg_dump`, `pg_restore`, `psql`. Upstream ships clients for PG 13 to 18. Decision needed: skip (document as a limitation) or install `postgresql-client` from the Ubuntu archive. This plan defaults to skip, to keep the image small.
- Port binding: we move to 5050. Users with chart-level `80`/`443` expectations need the new port documented.
- Blockers: none fatal found. No GPU, no privileged need. Draft's `Role: main`, `Difficulty: medium` stand.
- Unverified items to resolve before writing files: `PGADMIN_DEFAULT_*` names, gunicorn config path and WSGI entry, PyPI wheel URL and sha256, LICENSE SPDX id, `/misc/ping` health path.

## 11. Build and test steps

From `apps/pgadmin/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty-config run (fresh volume every round):
   ```sh
   docker volume create pgadmin-probe-config
   docker run --rm -d --name pgadmin-probe --read-only --tmpfs /tmp \
     -e PGADMIN_DEFAULT_EMAIL=... -e PGADMIN_DEFAULT_PASSWORD=... \
     -v pgadmin-probe-config:/config pgadmin:9.19
   docker logs -f pgadmin-probe
   ```
   Expected readiness signal: gunicorn line `Listening at: http://0.0.0.0:5050` (UNVERIFIED wording) and the process still running after the startup window. Cleanup: `docker rm -f pgadmin-probe; docker volume rm pgadmin-probe-config`.
4. Repeat step 3 on an existing volume to confirm restart works.
5. Seeding check: confirm the admin login works through `curl` to `/` with the credentials (manual; the test suite does not set env vars).
6. `forgetool containers test --image pgadmin:9.19 --config ./container-test.yaml`.
7. Note arm64 is not built unless amd64 fails.

## 12. PR checklist

- Branch `feat/add-pgadmin`, commit `feat(pgadmin): add new container`, PR title matches.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, checkboxes only where true.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows status.
- Say what was not tested (arm64, backups, seeding path if not exercised).
- Confirm `docker buildx bake --print` exit 0 and the test result before checking the "Built container locally" box.
