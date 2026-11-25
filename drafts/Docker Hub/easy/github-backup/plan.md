# github-backup — implementation plan
> Source: ./draft.md · Target: apps/github-backup/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Which project | The draft names `lnxd/github-backup` (Alpine 3.9, Unraid-oriented, repo archived 2022-09-06, MIT) but the binary field says `pip:github-backup`. The PyPI package `github-backup` is a different, maintained project: `josegonzalez/python-github-backup`. This plan ports the PyPI one and defines a thin wrapper `start.sh`. Confirm with maintainers (section 10). |
| Version | `0.68.0` (PyPI, released 2026-11-09). Requires Python >= 3.11 (classifiers 3.11-3.14; 3.15 not listed). |
| Renovate | `datasource=pypi depName=github-backup` (for example `apps/esphome` uses `datasource=pypi`). |
| License | `MIT` (PyPI classifier and README). `LICENSE.txt` exists on the repo (starts "The MIT License (MIT) Copyright (c) 2013 Jose Diaz-Gonzalez"). |
| Source URL | https://github.com/josegonzalez/python-github-backup |
| Download | `pip install github-backup==0.68.0` from PyPI, same for both arches (pure Python, no declared dependencies). Needs `git` >= 1.9 at runtime (present in the ubuntu base). |
| Checksum source | None for pip. Optionally `pip install --require-hashes` with a hash file; not available from upstream. |
| CLI | `github-backup [options] USER`; `-t/--token` (classic) and `-f/--token-fine` (fine-grained `github_pat_...`) both accept a `file://` path; `-o/--output-directory`; `--all` (excludes `--attachments`, `-P/--private`, `-F/--fork`, `--all-starred`, `--pull-details`, `--lfs`, `--gists`, `--starred-gists`); `--organization`; `--token-from-gh`; GitHub App flags. No token environment variable is read by the tool itself. |
| Ports / listeners | None. It is a one-shot CLI. |
| lnxd image for comparison | Env `TOKEN` and `SCHEDULE` (seconds) read by `backup.sh`; loop `python3 github-backup.py config.json; sleep $SCHEDULE`; paths `/home/docker/github-backup/config/config.json` and `/home/docker/backups`; runs as UID 99:98. |
| Upstream Dockerfile reviewed | `lnxd/github-backup/Dockerfile` (alpine:3.9, `pip3 install -r requirements.txt`, `CMD ./backup.sh`). The PyPI project has no Dockerfile read here. |

## 2. Target layout

```
apps/github-backup/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (nothing to seed). Never use `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
```
Why: the draft names the python base. Python 3.15 is not in the package's classifiers; the package has no dependencies so it is likely fine, but if the first build or run fails use `ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232` (used by 8 sibling apps). Closest sibling: `apps/esphome` (single pip install into the base venv). Python rules apply: `/app/venv` read-only at runtime, caches in `/tmp`.

## 4. Dockerfile

```dockerfile
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

ENV HOME=/config \
    PIP_NO_CACHE_DIR=1 \
    GIT_TERMINAL_PROMPT=0

USER root
WORKDIR /app

RUN set -eux; \
    /app/venv/bin/pip install --no-cache-dir "github-backup==${VERSION}"; \
    mkdir -p /usr/share/licenses/github-backup; \
    curl -fsSL -o /usr/share/licenses/github-backup/LICENSE.txt \
      "https://raw.githubusercontent.com/josegonzalez/python-github-backup/${VERSION}/LICENSE.txt"; \
    chown -R root:root /app; chmod -R 755 /app; \
    rm -rf /root/.cache /tmp/*

USER apps
COPY --chmod=0755 . /
WORKDIR /config

VOLUME /config
```
Notes:
- Uses `/app/venv/bin/pip` directly (python base layout, same as `apps/changedetection`); `/app/venv` stays read-only at runtime. Verify `/app/venv/bin/github-backup` exists after build.
- `apt-get` not needed: `git` is already in the ubuntu base. Optionally `openssl` is only needed for GitHub App tokens (not in scope).
- The upstream tag is `0.68.0` (no `v` prefix) and `LICENSE.txt` exists at that tag (checked 2026-11-25), so the licence fetch must fail the build if it breaks.
- No `EXPOSE`: no ports.
- Final `USER apps`; `COPY --chmod=0755 . /` kept.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "github-backup"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=github-backup
  default = "0.68.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/josegonzalez/python-github-backup"
}
```
Standard `group "default"`, `image`, `image-local` (`github-backup:${VERSION}`), `image-all` (amd64 and arm64), as in `apps/esphome` / `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/josegonzalez/python-github-backup"
ports:
  []
env:
  - name: GITHUB_USER
    default: ""
    required: true
  - name: GITHUB_TOKEN
    default: ""
    required: true
  - name: GITHUB_ORGANIZATION
    default: "false"
    required: false
  - name: BACKUP_ARGS
    default: "--all"
    required: false
  - name: OUTPUT_DIR
    default: "/config/backups"
    required: false
  - name: SCHEDULE
    default: "86400"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```
- These env names are defined by this image's `start.sh` (not read by the upstream tool, which has none). `SCHEDULE` mirrors the lnxd image's variable name. UNVERIFIED: the TrueCharts chart's own env names (draft only says "account and API key"); align names with the chart values when migrating.
- `required: true` with an empty default conflicts with the settings rule ("required env must have a non-empty default or be handled by start.sh"): `start.sh` handles it by idling with a clear message when they are missing. Alternative: mark both `required: false`; decide in review.
- `dependencies:` none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

GITHUB_USER="${GITHUB_USER:-}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
GITHUB_ORGANIZATION="${GITHUB_ORGANIZATION:-false}"
BACKUP_ARGS="${BACKUP_ARGS:---all}"
OUTPUT_DIR="${OUTPUT_DIR:-/config/backups}"
SCHEDULE="${SCHEDULE:-86400}"

mkdir -p "${OUTPUT_DIR}"

if [ -z "${GITHUB_USER}" ] || [ -z "${GITHUB_TOKEN}" ]; then
  echo "[github-backup] GITHUB_USER and GITHUB_TOKEN are not set; nothing to back up. Idling."
  exec sleep infinity
fi

export XDG_CACHE_HOME=/tmp/.cache
read -r -a EXTRA_ARGS <<< "${BACKUP_ARGS}"

# Token goes through a 0600 file in /tmp (never on the command line / process list).
# umask is limited to a subshell so backup files keep the normal permissions.
TOKEN_FILE=/tmp/github-token
( umask 077; printf '%s' "${GITHUB_TOKEN}" > "${TOKEN_FILE}" )
unset GITHUB_TOKEN
case "$(cat "${TOKEN_FILE}")" in
  github_pat_*) TOKEN_FLAG=(--token-fine "file://${TOKEN_FILE}") ;;
  *)            TOKEN_FLAG=(--token "file://${TOKEN_FILE}") ;;
esac
ORG_FLAG=(); [ "${GITHUB_ORGANIZATION}" = "true" ] && ORG_FLAG=(--organization)

run_backup() {
  /app/venv/bin/github-backup "${TOKEN_FLAG[@]}" "${ORG_FLAG[@]}" --output-directory "${OUTPUT_DIR}" "${EXTRA_ARGS[@]}" "${GITHUB_USER}"
}

if [ "${SCHEDULE}" = "0" ]; then
  # one-shot mode, the container exits with the tool's status
  exec /app/venv/bin/github-backup "${TOKEN_FLAG[@]}" "${ORG_FLAG[@]}" --output-directory "${OUTPUT_DIR}" "${EXTRA_ARGS[@]}" "${GITHUB_USER}"
fi

# A shell loop cannot exec the tool: trap signals and wait on child processes instead
child=""
trap '[ -n "${child}" ] && kill "${child}" 2>/dev/null; exit 0' TERM INT
while true; do
  run_backup &
  child=$!
  wait "${child}" || echo "[github-backup] run failed, retrying next cycle"
  sleep "${SCHEDULE}" &
  child=$!
  wait "${child}"
done
```
Implementation notes for the final script:
- `SCHEDULE=0` means run once then exit (with `exec`). Otherwise the loop keeps running; a backup failure must not kill the container. The loop is the long-running process, so it traps TERM/INT and `wait`s on children.
- Idempotent: later runs update existing backups (upstream behaviour: repeated runs refresh and add repositories, as stated by lnxd's README for its own script; UNVERIFIED for the PyPI tool, test twice).
- Never writes to `/app`; output in `/config/backups`; token file and caches in `/tmp`; `HOME=/config`.
- Special characters in env values are handled by quoting; the token is never written under `/config`.
- Always start without env vars (container test): it idles and stays running.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /start.sh
- /app/venv/bin/github-backup
healthCommands:
- command: /app/venv/bin/github-backup --help
```
- No ports, so no tcp/http probes. The `healthCommands` entry actually executes the installed CLI (checks the Python 3.15 compatibility risk for real). `expectedExitCode` defaults to 0 (`.github/schemas/container-test.schema.json`).
- The test runs without env vars, so the real backup path (token handling, loop) is NOT exercised; run it manually per section 11 with a read-only token.
- `timeoutSeconds` omitted (180 s minimum applies).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| lnxd `/home/docker/backups` | `OUTPUT_DIR=/config/backups` |
| lnxd `/home/docker/github-backup/config/config.json` (token written into JSON via `sed`) | not used; token is passed as a 0600 file under `/tmp` |
| lnxd `HOME=/home/docker`, `chmod 777` | `HOME=/config`, user `apps` (568) |
| git global config / credential cache | `HOME=/config` (writable) or `GIT_CONFIG_GLOBAL=/tmp/gitconfig` if git insists on writing; check on run |
| pip / wheel caches | build only, `PIP_NO_CACHE_DIR`; `/tmp` at runtime |

Draft expectations: chart sets UID 0 and writable rootfs; this port runs as 568, read-only rootfs, not privileged. Chart's two PVCs (`backups`, `config`) collapse to `/config`; mount it on large storage. If the chart mounts a separate backup volume, point `OUTPUT_DIR` at it (its path must be writable by UID 568, UNVERIFIED chart behaviour).

## 10. Risks, caveats and open questions

- **Project mismatch:** the chart uses the archived lnxd image (own script, `config.json`, env `TOKEN`/`SCHEDULE`); the PyPI `github-backup` is a different CLI with different flags. Drafts' "pip install" intent is met by the PyPI tool, but existing chart configuration will not carry over unchanged. Confirm this is acceptable.
- Draft caveat: needs a GitHub token with proper scopes (classic `repo`, or fine-grained read access); supplied as a secret.
- Draft caveat: runs once per invocation; this plan adds the `SCHEDULE` loop (UNVERIFIED whether the chart prefers a Kubernetes CronJob instead; if so, `SCHEDULE=0` gives a one-shot).
- `--all` does not include private repos (`-P`), forks, gists, LFS; defaults in `BACKUP_ARGS` may need `--private`.
- Python 3.15 not in the package classifiers; fallback base 3.14.8 listed in section 3.
- API rate limits and large backups can run for hours; add no timeout.
- The draft's "alpine 3.9" detail is irrelevant to this image.
- No blockers: pure Python, both arches, glibc.

## 11. Build and test steps

```sh
cd apps/github-backup
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create github-backup-probe-config
docker run --rm -d --name github-backup-probe --read-only --tmpfs /tmp \
  -v github-backup-probe-config:/config github-backup:0.68.0
docker logs github-backup-probe   # expect the "not set ... Idling" line, container still running
docker rm -f github-backup-probe; docker volume rm github-backup-probe-config
# manual functional run with a read-only token against a tiny public account:
docker run --rm --read-only --tmpfs /tmp -v github-backup-probe-config:/config \
  -e GITHUB_USER=<small-account> -e GITHUB_TOKEN=<token> -e SCHEDULE=0 github-backup:0.68.0
forgetool containers test --image github-backup:0.68.0 --config ./apps/github-backup/container-test.yaml
```
Expected readiness signal for the unconfigured run: the idle log line plus a running container. For the manual run: clones appear under `/config/backups` and a second run updates them. Max 10 rounds.

## 12. PR checklist

- [ ] Branch `feat/add-github-backup`; commit and PR title `feat(github-backup): add new container`; target `main`.
- [ ] PR template filled; only applicable boxes ticked.
- [ ] Notes: `🤖 This PR is AI generated.` plus the lnxd versus PyPI project note.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- [ ] `docker buildx bake --print` passed; `ARG VERSION` equals bake `VERSION` (`0.68.0`).
- [ ] Untested until run: build, python 3.15 compatibility, token/loop path with a real token, read-only start, arm64, forgetool. Do not tick "Built container locally" unless done.
