# ctfd — implementation plan
> Source: ./draft.md · Target: apps/ctfd/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | 3.8.9, GitHub release published 2026-10-22T15:58:06Z. Draft pin 3.8.9 matches | `gh api repos/CTFd/CTFd/releases/tags/3.8.9` |
| Tag commit | `5f345fbaa424e6a22b51addf7f27430927879ae2` | `gh api repos/CTFd/CTFd/git/refs/tags/3.8.9` |
| Chart image | `ghcr.io/ctfd/ctfd:3.8.9@sha256:84aff1e50b6a6f931b5da90c6f5b7c623ba4583217a9b00e9d4c1b7c53b9739f` (digest not checked against the registry: `UNVERIFIED`) | https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ctfd/values.yaml line 4 |
| Renovate | `datasource=github-releases depName=CTFd/CTFd versioning=semver` (convention; `UNVERIFIED` for this repo) | `docs` standard |
| License | Apache-2.0 (GitHub API SPDX). LICENSE file fetched | `gh api repos/CTFd/CTFd`, https://raw.githubusercontent.com/CTFd/CTFd/3.8.9/LICENSE |
| Source archive | https://github.com/CTFd/CTFd/archive/refs/tags/3.8.9.tar.gz. No checksum is published by upstream: `UNVERIFIED`. Verify by commit SHA instead (see section 4) | draft |
| Upstream Dockerfile | Two stages on `python:3.11-slim-bookworm`; `build` makes `/opt/venv` and runs pip; `release` copies code, creates user `ctfd` UID 1001, mkdir `/var/log/CTFd` and `/var/uploads`, `USER 1001`, `EXPOSE 8000`, `ENTRYPOINT /opt/CTFd/docker-entrypoint.sh` | https://raw.githubusercontent.com/CTFd/CTFd/3.8.9/Dockerfile |
| Upstream entrypoint | Reads `WORKERS` (1), `WORKER_CLASS` (gevent), `ACCESS_LOG` (-), `ERROR_LOG` (-), `WORKER_TEMP_DIR` (/dev/shm), `SECRET_KEY`, `SKIP_DB_PING` (false). Runs `python ping.py` unless `SKIP_DB_PING` is set, then `flask db upgrade`, then `exec gunicorn 'CTFd:create_app()' --bind 0.0.0.0:8000 ...` | https://raw.githubusercontent.com/CTFd/CTFd/3.8.9/docker-entrypoint.sh |
| Secret key rule | Without `SECRET_KEY` and without `.ctfd_secret_key` in the working directory, one worker is allowed; more than one worker needs `SECRET_KEY` | docker-entrypoint.sh |
| Python deps | gunicorn `==23.0.0` pinned in requirements.txt; other pins not extracted in this run (read the full file when writing the Dockerfile) | https://raw.githubusercontent.com/CTFd/CTFd/3.8.9/requirements.txt |
| Ports | 8000/tcp | Dockerfile EXPOSE, entrypoint bind |
| Upstream write paths | `/var/log/CTFd` (logs), `/var/uploads` (uploads); the chart mounts them as `/logs` and `/uploads` through `UPLOAD_FOLDER` and `LOG_FOLDER` | Dockerfile; chart values lines 28-29, 68-74 |
| Chart env | `UPLOAD_FOLDER`, `LOG_FOLDER`, plus valkey credentials from secret `valkeycreds` and `env-secrets` | chart values lines 24-57 |
| Chart user | `runAsUser: 0`, `readOnlyRootFilesystem: false` | chart values lines 61-63 |
| Dependencies | valkey, enabled in the chart (optional for CTFd); `apps/valkey` exists in this repo | chart values lines 65-66 |
| Setup | First-run setup wizard in the web UI (draft, `UNVERIFIED`: not fetched) | draft |

Not verified in this run: the `DATABASE_URL` environment variable name and the default database location in `CTFd/config.py` (the grep returned nothing). See section 10.

## 2. Target layout

Files in `apps/ctfd/`:

- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required (the entrypoint logic: secret key, `/config` seeding, `flask db upgrade`, `exec gunicorn`).
- `defaults/`, `etc/`: not needed.
- `DOWNSTREAM_CHANGES.md`: not needed, not a `FROM` base.

## 3. Base image

- FROM: `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (brief's python line; used by `apps/bazarr`).
- Why: a pure Python Flask app run by gunicorn, which is the `python` family per the table in `copilot-instructions.md`. The base ships `/app/venv`.
- Closest sibling: `apps/bazarr` (python base, `USER apps`, `COPY --chmod=0755 . /`, `/config` volume, `exec` start).
- Version note: upstream builds on Python 3.11 and CTFd 3.8.9 is tested there. Python 3.15 compatibility of the pinned requirements is `UNVERIFIED` and must be checked in the build (see section 10).

## 4. Dockerfile

Steps:

1. `ARG VERSION` (3.8.9, matches bake default). `ARG VENDOR`.
2. `USER root`.
3. Source: `ARG VERSION` is used to fetch the code, then verify the commit. Do this as a `RUN` that clones or downloads, and check the tag commit `5f345fbaa424e6a22b51addf7f27430927879ae2` (for example `git -c advice.detachedHead=false clone --depth 1 --branch 3.8.9`, then `git rev-parse HEAD` must equal the expected SHA). This replaces a checksum, since upstream publishes none for the tag archive. Put the expected SHA in the Dockerfile as an `ARG` pinned with the version, or fail the build on mismatch.
4. Build-only tools (`build-essential`, `libffi-dev`, `libssl-dev`) only if a requirement has no wheel for the base's Python. Check first: install them only when needed, and remove them in the same `RUN`. Runtime libs `libffi8` and `libssl3` are likely already in the base (check `dpkg -l` on the base before adding).
5. Install the code to `/app/CTFd` (not `/opt/CTFd`, to match ContainerForge's `/app` convention). `chown -R root:root /app/CTFd`, `chmod -R 755` (read-only at runtime).
6. Install Python deps into `/app/venv` at build time: `/app/venv/bin/python -m pip install --no-cache-dir -r /app/CTFd/requirements.txt` and the plugin requirements loop from upstream. This is a build-time write, which is allowed. Keep pip cache in `/tmp` (`PIP_CACHE_DIR=/tmp/pip`), and remove it at the end of the `RUN`.
7. Do not write to `/app` at runtime (read-only rule).
8. `mkdir -p /config` and set the ownership for `apps`.
9. `COPY --chmod=0755 start.sh /start.sh`.
10. `ENV` defaults only when needed by the image (no secrets): `CTFD_LOG_DIR`, etc. are not needed; the runtime paths come from start.sh.
11. `EXPOSE 8000/tcp`.
12. `USER apps`, `COPY --chmod=0755 . /`, `ENTRYPOINT ["/start.sh"]`.

`/app/venv` is the read-only venv from the base. Installing into it at build time follows `python-runtime.instructions.md` (the rule is about runtime writes). If the base's `/app/venv` is not the one used by the runtime, use it through `PATH`. Confirm in the build.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "ctfd"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=CTFd/CTFd versioning=semver
  default = "3.8.9"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/CTFd/CTFd"
}
```

- `VERSION` must equal the Dockerfile `ARG VERSION` (3.8.9).
- Targets: `docker-metadata-action`, `image`, `image-local` (`${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`, since the code is pure Python; arm64 build is `UNVERIFIED`), `group "default" { targets = ["image-local"] }`.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/CTFd/CTFd"
ports:
  - port: 8000
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: SECRET_KEY
    default: ""
    required: false
  - name: WORKERS
    default: "1"
    required: false
  - name: WORKER_CLASS
    default: "gevent"
    required: false
  - name: SKIP_DB_PING
    default: "false"
    required: false
  - name: UPLOAD_FOLDER
    default: "/config/uploads"
    required: false
  - name: LOG_FOLDER
    default: "/config/logs"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: valkey
```

- `SECRET_KEY`: optional with `default: ""`. start.sh generates one into `/config` when it is empty and reuses it on the next start (see section 7), so `required` stays false.
- `DATABASE_URL`: add it only after the name and default are confirmed in `CTFd/config.py` (`UNVERIFIED`). Do not invent it.
- `opt_dependencies` lists valkey (optional for caching and sessions). Use the same key that other apps with optional deps use; check `apps/*/settings.yaml` for `opt_dependencies` before committing. `apps/valkey` exists, so the entry is valid.
- Do not list `/uploads` or `/logs` as volumes: the chart paths are remapped to `/config` (section 9).

## 7. start.sh

Behaviour (bash, `set -euo pipefail`):

1. Export `PYTHONPATH=/app/CTFd`, `PATH=/app/venv/bin:$PATH`, `TMPDIR=/tmp`, `PIP_CACHE_DIR=/tmp/pip`.
2. `mkdir -p /config/uploads /config/logs` only when missing (idempotent, empty `/config` start).
3. Secret key: if `SECRET_KEY` is empty, read `/config/.secret_key`. If that is missing, generate a random key (`python -c 'import secrets; print(secrets.token_hex(32))'`) and write it to `/config/.secret_key` with mode 0600. Export `SECRET_KEY`. Do not put the key in the process list or logs.
4. Set `UPLOAD_FOLDER` and `LOG_FOLDER` defaults to `/config/uploads` and `/config/logs` (already in settings.yaml).
5. Working directory: `cd /config`. Gunicorn runs from `/config` so no write lands in `/app`. `.ctfd_secret_key` in cwd is not used (`/config` has `.secret_key` from step 3, and `SECRET_KEY` is exported).
6. Database: if `DATABASE_URL` is set, use it. The default location is `UNVERIFIED` (see section 10). Do not write the DB under `/app`.
7. Apply the same ping rule as upstream: run `python /app/CTFd/ping.py` unless `SKIP_DB_PING` is set to a value other than `false` or empty.
8. Run `flask db upgrade` from `/app/CTFd` with `FLASK_APP` set as upstream does (`UNVERIFIED`: the upstream entrypoint does not set `FLASK_APP`; check the CTFd package default in the build).
9. `exec gunicorn 'CTFd:create_app()' --bind 0.0.0.0:8000 --workers "${WORKERS}" --worker-tmp-dir "${WORKER_TEMP_DIR:-/tmp}" --worker-class "${WORKER_CLASS}" --access-logfile "${ACCESS_LOG:--}" --error-logfile "${ERROR_LOG:--}"`, with the same argument shape as upstream. Use `/tmp` for `WORKER_TEMP_DIR` (upstream default is `/dev/shm`, which is not in the read-only model).
10. Bind to `0.0.0.0:8000` (required by the rules: listen on all interfaces).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
  - port: '8000'
    path: /
tcp:
  - port: '8000'
filePaths:
  - /start.sh
  - /app/CTFd/CTFd/__init__.py
```

- `tcp` on 8000 (settings port).
- `http` on `/`: CTFd redirects to the setup wizard on first run. The expected status is `UNVERIFIED`: check the response on a real run and set the check to match (for example a redirect acceptance, if forgetool supports it). Do not accept a broken server.
- `timeoutSeconds`: no sibling sets it (`apps/bazarr` has none). Set it to cover `flask db upgrade` on a fresh `/config` (`UNVERIFIED`).
- No DB dependency. The app starts with SQLite (if the DB default is SQLite, `UNVERIFIED`), so the DB-dependency narrowing exception does not apply. Valkey is optional, so the test runs without it.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | Target |
| --- | --- |
| Code in `/opt/CTFd` | `/app/CTFd` (read-only) |
| `/opt/venv` (build stage) | `/app/venv` (bundled by base; deps installed at build time) |
| User `ctfd` UID 1001 | `apps` (base user) |
| `/var/log/CTFd` | `/config/logs` (`LOG_FOLDER`) |
| `/var/uploads` | `/config/uploads` (`UPLOAD_FOLDER`) |
| `.ctfd_secret_key` in cwd | `/config/.secret_key` plus `SECRET_KEY` export |
| `WORKER_TEMP_DIR=/dev/shm` | `/tmp` |
| cwd `/opt/CTFd` | cwd `/config` |

Chart expectations (draft): chart runs as UID 0 and `readOnlyRootFilesystem` false. Target runs as `apps` and works with `--read-only --tmpfs /tmp`.

Persistence: uploads and logs both go to `/config` (not `/uploads` and `/logs`). The chart's two PVCs become two folders under one `/config` volume.

## 10. Risks, caveats and open questions

10.1 Python version: upstream 3.11. Target base 3.15.2. Check each pinned package in `requirements.txt` has a wheel for 3.15 on amd64 and arm64, or build it. `UNVERIFIED`.

10.2 Database URL: the env var name and default DB path were not confirmed (grep of `CTFd/config.py` returned nothing this run). Fetch `CTFd/config.py` again, find `DATABASE_URL` and its default, and add it to settings.yaml only after that. If the default is a path under the code directory, it must be redirected to `/config` (read-only rule).

10.3 Valkey (optional): the env var names for cache and session URLs are `UNVERIFIED`. The chart uses secret `valkeycreds`, its key names are not in the chart values, so do not name env vars from it.

10.4 Upstream image tag digest in the chart is not checked against the registry (`UNVERIFIED`). The build uses the source tag, not the chart digest.

10.5 Setup wizard: first run needs manual setup in the web UI (draft). No automation is planned here.

10.6 Plugin requirements: upstream installs plugin requirements in a loop. Plan does the same at build time. Any plugin that writes at runtime into `/app` would fail under read-only rootfs (`UNVERIFIED`, not in scope for the default image).

10.7 `flask db upgrade` on each start is upstream behaviour and writes the DB in `/config`. That is intended, and it is idempotent.

## 11. Build and test steps

From `apps/ctfd/`:

1. `docker buildx bake --print` (exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty `/config` start on read-only rootfs:
   ```sh
   docker run --rm -d --name ctfd-probe --read-only --tmpfs /tmp \
     -v ctfd-probe-config:/config ${APP}:${VERSION}
   docker logs -f ctfd-probe
   ```
   Pass: process stays up, `flask db upgrade` completes, log shows `Starting CTFd` then gunicorn `Listening at: http://0.0.0.0:8000` (readiness signal to confirm, `UNVERIFIED` exact text). No fatal errors. Cleanup: `docker rm -f ctfd-probe; docker volume rm ctfd-probe-config`.
4. Second start with the same `/config` volume: confirm `.secret_key` is reused and no re-seed overwrites data.
5. `forgetool containers test --image <image>:<version> --config ./apps/ctfd/container-test.yaml`.
6. Round limit 10, then record `unfixable`.

## 12. PR checklist

- Branch `feat/add-ctfd`, commit and PR title `feat(ctfd): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, check only applicable boxes.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Say what was not tested (for example, arm64 build, the DB default, the Python 3.15 wheels) if they were not run. Do not check "Built container locally" unless it was built.
- Bake print passed; image-local built; empty `/config` start and second start; assertions unchanged; scratch containers and volumes removed.
