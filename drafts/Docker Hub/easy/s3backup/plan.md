# s3backup — implementation plan
> Source: ./draft.md · Target: apps/s3backup/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Application | s3cmd (PyPI `s3cmd`), latest `2.4.0` (uploaded 2023-12-12). No newer release seen on PyPI. |
| Renovate | `datasource=pypi depName=s3cmd versioning=pep440` (pypi default) |
| License | GPL-2.0-or-later (PyPI metadata "GNU GPL v2+"). The wrapper repo `joch/docker-s3backup` is GPL-3.0 but we do not copy its code. |
| Source URL | https://github.com/s3tools/s3cmd |
| Per-arch download | Not applicable: pure-Python PyPI package, installed with pip on both arches. |
| Checksum source | pip index metadata; no separate upstream checksum. Optionally pin with `pip install --require-hashes` using hashes copied from https://pypi.org/project/s3cmd/2.4.0/#files (UNVERIFIED, not fetched). |
| requires_python | Not specified in PyPI metadata. UNVERIFIED: compatibility with Python 3.15 (base image); check in the build step. |
| Wrapper reviewed | https://github.com/joch/docker-s3backup/blob/87e6354/Dockerfile: `debian:jessie`, `cron python python-magic python-pip`, `pip install s3cmd`, `/data`, config at `/root/.s3cfg`, entrypoint `/run.sh start`. Last updated 2019. |
| Wrapper env (README) | `ACCESS_KEY`, `SECRET_KEY`, `S3PATH`, `S3CMDPARAMS`, `CRON_SCHEDULE` (default `0 * * * *`). Volume: anything to back up mounted under `/data`. `run.sh` itself was not fetched, so the exact `s3cmd` invocation is UNVERIFIED (README says it uses `s3cmd sync`). |
| Ports | None. |

## 2. Target layout

```
apps/s3backup/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
- No `defaults/` (the s3cmd config is generated into `/tmp` from env at each start). No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

The draft suggests ubuntu plus pip; the python base already provides `/app/venv`, `pip` and the venv conventions in `python-runtime.instructions.md`. Closest siblings: `apps/bazarr` (python base) and `apps/changedetection` (pip install into `/app/venv`). Fallback if 3.15 breaks s3cmd: see section 10.

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. `ENV HOME=/config PIP_NO_CACHE_DIR=1` (pip cache must not land in `/config`; the base already sets `PIP_NO_CACHE_DIR=1`).
3. apt: `python-magic` equivalent only if wanted. s3cmd works without it (MIME guessing falls back to `mimetypes`); UNVERIFIED. Prefer pip `python-magic` plus apt `libmagic1` only if the sync of unknown types needs it; default plan: no apt packages.
4. Install into the bundled venv at build time as root:
```sh
/app/venv/bin/pip install --no-cache-dir "s3cmd==${VERSION}"
/app/venv/bin/s3cmd --version
mkdir -p /usr/share/licenses/s3cmd
# copy the license shipped inside the package (dist-info/licenses or COPYING) or fetch
# https://raw.githubusercontent.com/s3tools/s3cmd/v${VERSION}/LICENSE into /usr/share/licenses/s3cmd/
```
   Check `/app/venv` ownership after install; keep it read-only for `apps` at runtime (`chown -R root:root /app/venv` like bazarr, or leave as the base sets it).
5. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /config`, `VOLUME /config`.
6. No `EXPOSE` (no ports).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "s3backup" }
variable "VERSION" {
  // renovate: datasource=pypi depName=s3cmd
  default = "2.4.0"
}
variable "LICENSE" { default = "GPL-2.0-or-later" }
variable "SOURCE"  { default = "https://github.com/s3tools/s3cmd" }
```
Standard targets and `group "default"` from `apps/bazarr/docker-bake.hcl` (check it for the python family layout); `image-all` linux/amd64 + linux/arm64. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/s3tools/s3cmd"
ports:
  []
env:
  - name: ACCESS_KEY
    default: ""
    required: false
  - name: INTERVAL_SECONDS
    default: "3600"
    required: false
  - name: RUN_ONCE
    default: "false"
    required: false
  - name: S3CMDPARAMS
    default: ""
    required: false
  - name: S3PATH
    default: ""
    required: false
  - name: SECRET_KEY
    default: ""
    required: false
  - name: SOURCE_DIR
    default: "/data"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /data
    required: false
```
- `ACCESS_KEY`, `SECRET_KEY`, `S3PATH`, `S3CMDPARAMS` keep the names of the wrapper image (README). `INTERVAL_SECONDS`, `RUN_ONCE`, `SOURCE_DIR` are new ContainerForge-defined variables that replace `CRON_SCHEDULE` (no cron daemon under rootless). `required: false` so the image starts with no env (the container test has none); `start.sh` idles with a clear message when `S3PATH` is empty.
- No dependencies.

## 7. start.sh

```sh
#!/usr/bin/env bash
set -euo pipefail
SOURCE_DIR="${SOURCE_DIR:-/data}"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-3600}"
CFG=/tmp/s3cfg
umask 077
if [ -z "${S3PATH:-}" ]; then
  echo "S3PATH is not set; nothing to back up. Idling." >&2
  exec sleep infinity
fi
# credentials come from env and are written to /tmp only (never /config, never argv)
cat > "${CFG}" <<EOF
[default]
access_key = ${ACCESS_KEY:-}
secret_key = ${SECRET_KEY:-}
EOF
read -r -a params <<< "${S3CMDPARAMS:-}"
run_sync() { /app/venv/bin/s3cmd --config="${CFG}" sync "${SOURCE_DIR%/}/" "${S3PATH}" "${params[@]}"; }
if [ "${RUN_ONCE:-false}" = "true" ]; then exec /app/venv/bin/s3cmd --config="${CFG}" sync "${SOURCE_DIR%/}/" "${S3PATH}" "${params[@]}"; fi
while true; do run_sync || echo "sync failed, retrying in ${INTERVAL_SECONDS}s" >&2; sleep "${INTERVAL_SECONDS}" & wait $!; done
```
- Handle an empty `params` array safely under `set -u` (use `${params[@]+"${params[@]}"}`) and trap SIGTERM to kill the sleep.
- UNVERIFIED: a secret containing `%` or special characters in the ini file (s3cmd uses Python `ConfigParser`, interpolation behavior to be tested); if a problem, fall back to the `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` env path if s3cmd supports it (UNVERIFIED).
- Custom endpoints (MinIO etc.) are passed via `S3CMDPARAMS` (for example `--host=... --host-bucket=...`), per s3cmd docs; not verified here.
- The loop is sequential, so no lock file is needed (upstream sync wrapper had one).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /app/venv/bin/s3cmd
- /start.sh
```
No ports in `settings.yaml`, so no tcp/http probe. The test runs with no env, so the sync path (needs `S3PATH`, credentials) is not covered; optionally add a `runners` entry with `entrypoint: /app/venv/bin/s3cmd`, `cmd: --version`, `expectedOutput: "2.4.0"` after confirming the exact output format. Run the sync path manually, see section 11.

## 9. Rootless and read-only-rootfs adaptations

- Draft/chart: runAsUser 0, readOnlyRootFilesystem false. Target: user `apps`, read-only rootfs.
- Upstream writes `/root/.s3cfg` (home) and a cron/log file. Remap: config generated to `/tmp/s3cfg` with mode 600; `HOME=/config`; no cron, no log file (stdout only).
- Backup source mounted read-only at `/data` (draft caveat). The `apps` user must be able to read it; document that file ownership/permissions on the mount must allow it.
- s3cmd keeps no persistent state, so `/config` is mostly unused; the volume is declared for convention (and `HOME`).

## 10. Risks, caveats and open questions

- It is a looping job, not a service. `RUN_ONCE=true` allows use as a Kubernetes CronJob. `CRON_SCHEDULE` is not supported; decide whether to add a rootless scheduler (for example supercronic) later.
- Python 3.15 compatibility of s3cmd 2.4.0 (last released December 2023) is UNVERIFIED. If it fails, use `ghcr.io/trueforge-org/python` at a lower tag only if one exists, or install with apt `s3cmd` (pin the version and check it matches `VERSION`).
- Credentials in env are visible to anyone who can inspect the container; prefer secret mounts. The generated `/tmp/s3cfg` is mode 600.
- The wrapper image is unmaintained since 2019; this plan does not port its code, only its env names.
- s3cmd with `--delete-removed` in `S3CMDPARAMS` can delete remote data; not a default.
- No arm64 blockers (pure Python).

## 11. Build and test steps

```sh
cd apps/s3backup
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name s3backup-probe --read-only --tmpfs /tmp -v s3backup-probe-config:/config s3backup:2.4.0
docker logs -f s3backup-probe   # no env: expect "S3PATH is not set ... Idling." and the container stays running
docker rm -f s3backup-probe
# functional path: run with a local MinIO (or a real bucket), source dir mounted :ro at /data
docker run --rm --read-only --tmpfs /tmp -e RUN_ONCE=true -e S3PATH=s3://bucket/path/ -e ACCESS_KEY=... -e SECRET_KEY=... \
  -e S3CMDPARAMS="--host=minio:9000 --host-bucket=minio:9000 --no-ssl" -v ./src:/data:ro s3backup:2.4.0
docker volume rm s3backup-probe-config
forgetool containers test --image s3backup:2.4.0 --config ./apps/s3backup/container-test.yaml
```

## 12. PR checklist

- Branch `feat/add-s3backup`, commit and PR title `feat(s3backup): add new container`, target `main`.
- PR template filled; Notes contain `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested until run: Python 3.15 with s3cmd, the sync path against a real or MinIO endpoint, arm64, special characters in secrets, the `runners` version check. State which of these were not run.
