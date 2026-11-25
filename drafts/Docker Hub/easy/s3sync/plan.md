# s3sync — implementation plan
> Source: ./draft.md · Target: apps/s3sync/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Application | AWS CLI v1 from PyPI `awscli`, latest `1.46.3` (PyPI JSON API, uploaded 2026-11-05). `requires_python >=3.10`; the classifiers list Python up to 3.14, not 3.15. |
| Renovate | `datasource=pypi depName=awscli versioning=pep440` |
| License | Apache-2.0 (PyPI metadata). The wrapper repo `what-name/docker-s3sync` has no declared license (derived from `joch/docker-s3backup`, GPL-3.0); we do not copy its code, so the image LICENSE is Apache-2.0. |
| Source URL | https://github.com/aws/aws-cli (tag `1.46.3` has `__version__` 1.46.3; the default branch is `v2`). The draft's source is the wrapper repo https://github.com/what-name/docker-s3sync (last push 2022-10-07). |
| Per-arch download | Not applicable: pure-Python package installed with pip (arm64 and amd64). AWS CLI v2 is not on PyPI; the draft says awscli via pip, so v1. |
| Checksum source | pip index; optional `--require-hashes` from https://pypi.org/project/awscli/ (UNVERIFIED, not fetched). |
| Wrapper reviewed | https://github.com/what-name/docker-s3sync/blob/6c971229927957435bfd04239ba21085235fdd95/Dockerfile (`debian:latest`, `cron python3 python3-magic python3-pip`, pip `setuptools wheel awscli`, `/data`, `/root/.aws`, entrypoint `/run.sh start`) and `run.sh`. |
| Wrapper env (run.sh) | `ACCESS_KEY` (becomes `AWS_ACCESS_KEY_ID`), `SECRET_KEY` (becomes `AWS_SECRET_ACCESS_KEY`), `REGION` (becomes `AWS_DEFAULT_REGION`), `S3PATH`, `CRON_SCHEDULE` (default `0 * * * *`), `S3SYNCPARAMS`. Command: `/usr/local/bin/aws s3 sync /data/ $S3PATH $S3SYNCPARAMS`. Lock file `/tmp/aws-s3.lock`, log `/var/log/cron.log`. |
| Ports | None. |

## 2. Target layout

```
apps/s3sync/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (credentials come from env, nothing to seed). No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Pip package on the python base, install into `/app/venv`. Closest siblings: `apps/bazarr`, `apps/changedetection` (the venv install pattern). A sibling plan, `s3backup`, uses the same layout with s3cmd.

## 4. Dockerfile

1. `ARG VERSION`, `USER root`.
2. `ENV HOME=/config AWS_SHARED_CREDENTIALS_FILE=/tmp/aws-credentials AWS_CONFIG_FILE=/tmp/aws-config` (keeps any CLI writes off `/app` and `/config`; unset if not needed).
3. Install at build time into the bundled venv:
```sh
/app/venv/bin/pip install --no-cache-dir "awscli==${VERSION}"
/app/venv/bin/aws --version
mkdir -p /usr/share/licenses/awscli
# copy LICENSE.txt from the installed package dist-info, or fetch it from the aws-cli repo at tag ${VERSION}
```
   No apt packages (pure Python; `python-magic` and `cron` of the wrapper are not needed). Check the base for `groff`/`less`; the `aws help` command is not needed.
4. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /config`, `VOLUME /config`.
5. No `EXPOSE`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "s3sync" }
variable "VERSION" {
  // renovate: datasource=pypi depName=awscli
  default = "1.46.3"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/aws/aws-cli" }
```
Standard four targets and `group "default"` copied from `apps/bazarr/docker-bake.hcl`; `image-all` amd64 + arm64. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/aws/aws-cli"
ports:
  []
env:
  - name: ACCESS_KEY
    default: ""
    required: false
  - name: INTERVAL_SECONDS
    default: "3600"
    required: false
  - name: REGION
    default: ""
    required: false
  - name: RUN_ONCE
    default: "false"
    required: false
  - name: S3PATH
    default: ""
    required: false
  - name: S3SYNCPARAMS
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
`ACCESS_KEY`, `SECRET_KEY`, `REGION`, `S3PATH`, `S3SYNCPARAMS` are the wrapper's names; `INTERVAL_SECONDS`, `RUN_ONCE`, `SOURCE_DIR` are new ContainerForge variables replacing `CRON_SCHEDULE`. The standard `AWS_*` variables are also honored natively by the CLI. Extra persistence: `/data` is the read-only source mount (the chart's `/data/example`). No dependencies.

## 7. start.sh

```sh
#!/usr/bin/env bash
set -euo pipefail
SOURCE_DIR="${SOURCE_DIR:-/data}"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-3600}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-${ACCESS_KEY:-}}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-${SECRET_KEY:-}}"
[ -n "${REGION:-}" ] && export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-${REGION}}"
# unset empty credentials so the CLI falls back to its normal credential chain
[ -n "${AWS_ACCESS_KEY_ID}" ] || unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
if [ -z "${S3PATH:-}" ]; then
  echo "S3PATH is not set; nothing to sync. Idling." >&2
  exec sleep infinity
fi
read -r -a params <<< "${S3SYNCPARAMS:-}"
sync_once() { /app/venv/bin/aws s3 sync "${SOURCE_DIR%/}/" "${S3PATH}" ${params[@]+"${params[@]}"}; }
if [ "${RUN_ONCE:-false}" = "true" ]; then exec /app/venv/bin/aws s3 sync "${SOURCE_DIR%/}/" "${S3PATH}" ${params[@]+"${params[@]}"}; fi
while true; do sync_once || echo "sync failed, retrying in ${INTERVAL_SECONDS}s" >&2; sleep "${INTERVAL_SECONDS}" & wait $!; done
```
- Credentials are passed via the environment, never in a file or argv (the wrapper wrote them in plain text into `/etc/cron.d`).
- The sequential loop removes the need for the wrapper's lock file (a stale lock blocked later runs there). Add a SIGTERM trap that kills the sleep.
- Custom endpoints (MinIO) via `S3SYNCPARAMS="--endpoint-url http://..."`.
- Bind addresses: not applicable (no server).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /app/venv/bin/aws
- /start.sh
```
No ports, so no tcp/http probe. The test has no env, so the sync path is not covered; optionally add a `runners` entry (`entrypoint: /app/venv/bin/aws`, `cmd: --version`, `expectedOutput: aws-cli/1.46`) once the output format is checked.

## 9. Rootless and read-only-rootfs adaptations

- Draft/chart: runAsUser 0, readOnlyRootFilesystem false, extra mount `/data/example` read-only. Target: user `apps`, read-only rootfs.
- Wrapper wrote `/root/.aws`, `/etc/cron.d/s3sync`, `/var/log/cron.log`, `/tmp/aws-s3.lock`. Remap: no cron, no log file (stdout), config/credential file paths to `/tmp` via `AWS_*_FILE`, `HOME=/config`.
- Mounted sync source must be readable by the `apps` user (draft caveat); mount `:ro`.

## 10. Risks, caveats and open questions

- AWS CLI v1 is the older line; the draft explicitly uses `pip:awscli`, and v2 has no PyPI package. If v2 is wanted instead, it needs the official zip installer (x86_64 and aarch64 URLs, signature) and a different plan.
- UNVERIFIED: awscli 1.46.x on Python 3.15; if the dependency pins (botocore, urllib3) break, pick the nearest older python base tag that exists.
- It is a loop job, not a service; `CRON_SCHEDULE` is dropped, `RUN_ONCE=true` supports CronJobs. A rootless cron-style scheduler could be added later.
- `aws s3 sync --delete` in `S3SYNCPARAMS` removes remote objects; not a default.
- Overlaps with `s3backup` (s3cmd); keep both because the TrueCharts charts are separate.
- Lack of a license on the wrapper repo is irrelevant as no wrapper code is reused.
- No arm64 blocker.

## 11. Build and test steps

```sh
cd apps/s3sync
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name s3sync-probe --read-only --tmpfs /tmp -v s3sync-probe-config:/config s3sync:1.46.3
docker logs -f s3sync-probe   # no env: expect the "Idling" message and a running container
docker rm -f s3sync-probe
# functional path against MinIO or a real bucket, source mounted :ro
docker run --rm --read-only --tmpfs /tmp -e RUN_ONCE=true -e S3PATH=s3://bucket/path/ -e ACCESS_KEY=... -e SECRET_KEY=... -e REGION=us-east-1 \
  -e S3SYNCPARAMS="--endpoint-url http://minio:9000" -v ./src:/data:ro s3sync:1.46.3
docker volume rm s3sync-probe-config
forgetool containers test --image s3sync:1.46.3 --config ./apps/s3sync/container-test.yaml
```

## 12. PR checklist

- Branch `feat/add-s3sync`, commit and PR title `feat(s3sync): add new container`, target `main`.
- PR template filled; Notes contain `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested until run: Python 3.15 compatibility, real sync against S3 or MinIO, arm64, the `runners` version check. List the ones that were not run.
