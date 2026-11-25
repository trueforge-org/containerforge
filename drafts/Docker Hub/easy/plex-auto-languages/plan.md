# plex-auto-languages — implementation plan
> Source: ./draft.md · Target: apps/plex-auto-languages/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `1.2.3` (tag `v1.2.3` = `7c8e9366cb1c1e3f8ee2bff6550bba76c510c04e`, released 2023-08-11). The draft's `:latest` image is built from `master` (HEAD `104ead7b...`, 2025-11-30), which is newer than the release and renamed config `ignore_tags` to `ignore_labels`. This plan follows the release tag. |
| Renovate | `datasource=github-releases` · `depName=RemiRigal/Plex-Auto-Languages` · `versioning=semver` (tags have a `v` prefix) |
| License | `MIT` (GitHub API; `LICENSE` in repo root) |
| Source | https://github.com/RemiRigal/Plex-Auto-Languages |
| Download | `https://github.com/RemiRigal/Plex-Auto-Languages/archive/refs/tags/v${VERSION}.tar.gz` (pure Python, arch independent) |
| Checksum | None published. HTTPS only. |
| Upstream Dockerfile reviewed | `python:3.8-alpine`, `ENV CONTAINERIZED True`, `pip install -r requirements.txt`, `COPY . /app/`, `VOLUME /config`, `HEALTHCHECK curl http://localhost:9880/`, `ENTRYPOINT tini -s python3 main.py -c /config/config.yaml`. |
| requirements.txt (v1.2.3) | `plexapi>=4.13.2`, `websocket-client>=1.5.1`, `apprise>=1.2.1`, `PyYAML>=6.0`, `schedule>=1.1.0`, `Flask>=2.2.3`, `python-dateutil>=2.8.2`, `tqdm>=4.64.1`, `requests>=2.28.2` (all unpinned lower bounds) |
| Ports | No app port. An internal health server listens on `0.0.0.0:9880` (`/`, `/health`, `/ready` return JSON; 200 when healthy/ready, else 400). It is started before the configuration is parsed. The draft said "none"; 9880 is real. |
| Config | YAML at `-c /config/config.yaml` (optional) and env overrides: each key path uppercased with `_` (`plex.url` -> `PLEX_URL`). Only keys that exist in `config/default.yaml` can be overridden. Token can also come from `PLEX_TOKEN_FILE` (default `/run/secrets/plex_token`). |
| Default config (v1.2.3) | `update_level: show`, `update_strategy: next`, `trigger_on_play: true`, `trigger_on_scan: true`, `trigger_on_activity: false`, `refresh_library_on_scan: true`, `ignore_tags: [PAL_IGNORE]`, `plex.url: ""`, `plex.token: ""`, `scheduler.enable: true`, `scheduler.schedule_time: "02:00"`, `notifications.enable: false`, `notifications.apprise_configs: []`, `debug: false` |
| Data dir | `get_data_directory` returns `/config` when `CONTAINERIZED=true` (or `/.dockerenv` exists); cache goes to `/config/cache/<server id>`. |
| Fails when | `plex.url` or `plex.token` is empty: `InvalidConfiguration` ("A Plex URL is required"). |

## 2. Target layout

```
apps/plex-auto-languages/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (the app ships its own `config/default.yaml`; user `config.yaml` is optional and is not seeded). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: pure Python service, only pip dependencies, no apt. Closest sibling: `apps/bazarr` (python base, source in `/app`, deps in the system interpreter under `/usr/local`) and `apps/jbops` (Plex scripts, import-style tests).

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`; `USER root`.
2. `ENV HOME=/config CONTAINERIZED=True LANG=C.UTF-8 LC_ALL=C.UTF-8` (`CONTAINERIZED` makes the data dir `/config`, as upstream does).
3. `RUN`:
   - `curl -fsSL -o /tmp/pal.tar.gz "https://github.com/RemiRigal/Plex-Auto-Languages/archive/refs/tags/v${VERSION}.tar.gz"`
   - `mkdir -p /app/plex-auto-languages && tar xzf /tmp/pal.tar.gz -C /app/plex-auto-languages --strip-components=1`
   - `pip install -r /app/plex-auto-languages/requirements.txt` (system interpreter, no cache; base sets `PIP_NO_CACHE_DIR`).
   - `mkdir -p /usr/share/licenses/plex-auto-languages && cp /app/plex-auto-languages/LICENSE /usr/share/licenses/plex-auto-languages/`
   - `rm -rf /tmp/* && chown -R root:root /app/plex-auto-languages && chmod -R a+rX,go-w /app/plex-auto-languages`
4. `USER apps`; `COPY --chmod=0755 . /`.
5. `EXPOSE 9880`; `VOLUME /config`; `WORKDIR /config`.

No apt packages (upstream needs only `curl` and `tini`; the base already has `curl` and handles PID 1). Python 3.15 wheels for all dependencies are pure Python (apprise, plexapi, PyYAML has a C extension but ships wheels); UNVERIFIED for 3.15 until built.

## 5. docker-bake.hcl

- `APP = "plex-auto-languages"`
- `VERSION`: `// renovate: datasource=github-releases depName=RemiRigal/Plex-Auto-Languages versioning=semver` + `default = "1.2.3"`
- `LICENSE = "MIT"`; `SOURCE = "https://github.com/RemiRigal/Plex-Auto-Languages"`
- Standard four targets plus `group "default" { targets = ["image-local"] }` copied from `apps/adguardhome-sync/docker-bake.hcl`; validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/RemiRigal/Plex-Auto-Languages"
ports:
  - port: 9880          # health/readiness JSON endpoint
    protocol: tcp
    required: false
env:
  - name: PLEX_URL   # needed to do anything useful
    default: ""
    required: false
  - name: PLEX_TOKEN
    default: ""
    required: false
  - name: PLEX_TOKEN_FILE
    default: "/run/secrets/plex_token"
    required: false
  - name: UPDATE_LEVEL   # show | season
    default: "show"
    required: false
  - name: UPDATE_STRATEGY   # all | next
    default: "next"
    required: false
  - name: TRIGGER_ON_PLAY
    default: "true"
    required: false
  - name: TRIGGER_ON_SCAN
    default: "true"
    required: false
  - name: TRIGGER_ON_ACTIVITY
    default: "false"
    required: false
  - name: REFRESH_LIBRARY_ON_SCAN
    default: "true"
    required: false
  - name: IGNORE_TAGS   # comma separated
    default: "PAL_IGNORE"
    required: false
  - name: SCHEDULER_ENABLE
    default: "true"
    required: false
  - name: SCHEDULER_SCHEDULE_TIME   # HH:MM
    default: "02:00"
    required: false
  - name: NOTIFICATIONS_ENABLE
    default: "false"
    required: false
  - name: DEBUG
    default: "false"
    required: false
volumes:
  - path: /config
    required: true
```
`PLEX_URL`/`PLEX_TOKEN` are `required: false` because `start.sh` handles the unconfigured case. Defaults match upstream `default.yaml`; the container defaults only apply when the variable is unset (the app reads its own defaults, `start.sh` does not re-export them). No `dependencies` (Plex is an external server; `apps/plex` exists but is not a container dependency).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config                     # data dir and cache; created only if missing

# The app exits with "A Plex URL is required" when unconfigured.
if [[ -z "${PLEX_URL:-}" && ! -f /config/config.yaml ]]; then
  echo "plex-auto-languages: not configured. Set PLEX_URL and PLEX_TOKEN (or PLEX_TOKEN_FILE), or create /config/config.yaml. Waiting."
  exec sleep infinity
fi

exec /usr/local/bin/python /app/plex-auto-languages/main.py -c /config/config.yaml
```
`-c` pointing at a missing file is fine (the app only loads it when it exists). No secrets are echoed. Logging is on stdout. Binding: the health server already binds `0.0.0.0`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
mainRunner:
  env:
    PLEX_URL: http://127.0.0.1:32400
    PLEX_TOKEN: test-token
tcp:
- port: '9880'
filePaths:
- /app/plex-auto-languages/main.py
- /usr/share/licenses/plex-auto-languages/LICENSE
```
Rationale: without env the container idles (no listener on 9880), so the main runner gets dummy values. forgetool `main` applies `mainRunner.env` to the wait container (schema and `yaml_runner.go`), and `apps/drydock/container-test.yaml` uses it. `container-test.instructions.md` still says the test has no key to set env vars, so call this out in the PR. The probe only proves that the health server starts: with the dummy URL, v1.2.3 then logs a traceback (`_get_server` returns `None`, and `_get_logged_user` dereferences it), while the non-daemon health thread keeps the process and port 9880 alive (inferred from source, UNVERIFIED by a run). The no-env idle path is not tested. UNVERIFIED: that the forgetool version pinned in CI honors `mainRunner.env`. Fallback if not: use the `apps/jbops` pattern (`mainRunner: {enabled: false}` plus `runners` with `entrypoint: /usr/local/bin/python`, `cmd: "-c __import__('plexapi');print('pal'+'-ok')"`, `expectedOutput: pal-ok`; keep cmd space-free) and drop the `tcp` probe, noting why.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/config/cache/<server id>` (library cache) | already `/config` via `CONTAINERIZED=True` |
| `/config/config.yaml` (user supplied, read only) | not seeded |
| `__pycache__` in `/app` | `PYTHONDONTWRITEBYTECODE=1` from base |
| `/run/secrets/plex_token` | read only, optional |

Draft reconciliation: chart runs as UID 0 with writable rootfs, not needed. This image runs as `apps`, read-only rootfs, only `/config` and `/tmp` writable; no extra persistence beyond `/config`; not privileged.

## 10. Risks, caveats and open questions

- Draft caveat confirmed: needs a Plex URL and token; the app changes audio and subtitle tracks, so test only against a copy or a throwaway Plex library.
- Behavior without config or with an unreachable Plex server: the main thread dies with a traceback, but the non-daemon health thread should keep the process alive with `/health` returning 400 (from source, UNVERIFIED by a run). Restart policies will not notice; only the HTTP health status would. Env values are parsed with `yaml.safe_load`, so quote-sensitive values can change type (for example `SCHEDULER_SCHEDULE_TIME=12:00` is read by YAML 1.1 as an integer and fails validation; `02:00` stays a string). `start.sh` idles with a clear log line instead, so empty-start works and a missing config is visible in the logs.
- The release is from 2023 while `master` has 2025 commits (`ignore_labels`, websocket fixes). Decision needed: stay on `v1.2.3` (Renovate-friendly) or pin a `master` commit. If `master` is chosen, the env var becomes `IGNORE_LABELS` and the settings table must change.
- Python 3.15.2 is newer than anything upstream tests (3.8). If a dependency fails, fall back to the 3.14 python base (changedetection precedent).
- No checksum for the source tarball. amd64 and arm64 identical; no musl, GPU or privileged needs.
- Notifications use Apprise config files/URLs from `/config` (read only).

## 11. Build and test steps

```sh
cd apps/plex-auto-languages
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create plex-auto-languages-probe-config
# empty start (expect the "not configured. Waiting." line, container stays up)
docker run --rm -d --name plex-auto-languages-probe --read-only --tmpfs /tmp \
  -v plex-auto-languages-probe-config:/config plex-auto-languages:1.2.3
docker logs plex-auto-languages-probe
docker rm -f plex-auto-languages-probe
# configured start with dummy Plex values (expect "The provided configuration has been successfully validated" and port 9880 open; with this dummy URL a traceback is then expected, see section 10, so it does not meet protocol step 3; step 3 on the configured path needs a reachable Plex)
docker run --rm -d --name plex-auto-languages-probe --read-only --tmpfs /tmp \
  -e PLEX_URL=http://127.0.0.1:32400 -e PLEX_TOKEN=test \
  -v plex-auto-languages-probe-config:/config plex-auto-languages:1.2.3
docker logs -f plex-auto-languages-probe
docker rm -f plex-auto-languages-probe; docker volume rm plex-auto-languages-probe-config
forgetool containers test --image plex-auto-languages:1.2.3 --config ./apps/plex-auto-languages/container-test.yaml
```
If a real Plex server is available, also confirm the "Connected to Plex" style startup and that `/config/cache/` appears. Round limit 10; clean up each round.

## 12. PR checklist

- Branch `feat/add-plex-auto-languages`; commit and PR title `feat(plex-auto-languages): add new container`; base `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, tick only what applies.
- Add `🤖 This PR is AI generated.` to the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- List what is untested: connection to a real Plex server, audio/subtitle updates, notifications, arm64, whether CI forgetool honors `mainRunner.env`, Python 3.15 compatibility of dependencies. Do not tick "Built container locally" unless built.
- Pre-completion: bake `--print` OK, versions aligned, rootless + read-only rootfs, empty `/config` start verified, no assertion weakened.
