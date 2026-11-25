# calendarr — implementation plan
> Source: ./draft.md · Target: apps/calendarr/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **v1.5.2** (latest release, published 2026-11-04). Source: https://github.com/jordanlambrecht/calendarr/releases/tag/v1.5.2. The chart uses rolling `ghcr.io/jordanlambrecht/calendarr:latest`; the plan pins the tag, not `latest`. |
| Renovate | `datasource=github-releases depName=jordanlambrecht/calendarr versioning=semver` (UNVERIFIED that Renovate handles the tag prefix for this repo; check the sibling convention). |
| License | **GPL-3.0** (GitHub license API, https://api.github.com/repos/jordanlambrecht/calendarr/license). `LICENSE` in `docker-bake.hcl` must be `GPL-3.0`. |
| Source URL | https://github.com/jordanlambrecht/calendarr |
| Release binary | None. The v1.5.2 release has no assets (API `releases/tags/v1.5.2` lists none). Source only. |
| Per-arch download | Not applicable as a binary. Source archive `https://github.com/jordanlambrecht/calendarr/archive/refs/tags/v1.5.2.tar.gz` (standard GitHub tag archive; UNVERIFIED that it was fetched and extracts cleanly). Same source for amd64 and arm64. Python packages are pure Python (pinned, see below). |
| Checksum source | None published. Pin by tag and record the archive's SHA-256 in the Dockerfile after the first download (UNVERIFIED value, compute it in the build). |
| Upstream Dockerfile reviewed | https://github.com/jordanlambrecht/calendarr/blob/main/Dockerfile: `FROM python:3.15.2-slim`, `WORKDIR /app`, `pip install --no-cache-dir -r requirements.txt`, `COPY src/ /app/src/`, footers to `/app/default_footers/`, `COPY entrypoint.sh /app/entrypoint.sh`, `mkdir -p /app/logs`, `ENV PYTHONUNBUFFERED=1 PYTHONPATH=/app/src`, `EXPOSE 5000`, HEALTHCHECK `/health`, `ENTRYPOINT ["/app/entrypoint.sh"]`, `CMD ["python", "-m", "calendarr"]`. |
| Pinned Python deps | `requirements.txt`: apscheduler==3.11.3, icalendar==7.3.0, recurring-ical-events==3.8.2, requests==2.34.2 |
| entrypoint.sh | Seeds `$CUSTOM_FOOTERS_DIR/discord_footer.md` and `slack_footer.md` from `/app/default_footers` when missing (`CUSTOM_FOOTERS_DIR=/app/custom_footers`), then `exec "$@"`. |
| Footer paths (hard-coded) | `src/calendarr/render.py`: `DISCORD_FOOTER_FILE = "/app/custom_footers/discord_footer.md"`, `SLACK_FOOTER_FILE = "/app/custom_footers/slack_footer.md"`. Not configurable by env. |
| Env vars (real, from `src/calendarr/config.py`) | `USE_DISCORD` (default true), `USE_SLACK` (default false), `DISCORD_WEBHOOK_URL`, `SLACK_WEBHOOK_URL`, `DISCORD_MENTION_ROLE_ID` / `MENTION_ROLE_ID`, `CALENDAR_URLS` (JSON list, default `[]`), `TZ` (default UTC), `SCHEDULE_TYPE` (default WEEKLY), `SCHEDULE_DAY` (default 1), `RUN_TIME` (default 09:00), `RUN_ON_STARTUP`, `PASSED_EVENT_HANDLING` (default DISPLAY), `CALENDAR_RANGE` (default AUTO), `CUSTOM_HEADER` (default "New Releases"), `CRON_SCHEDULE` (default empty), `LOG_DIR` (default `/app/logs`), `LOG_FILE` (default `calendarr.log`), `HTTP_TIMEOUT` (default 30), `DEBUG`. |
| Port | 5000 tcp. `src/calendarr/health.py` serves `/` and `/health` on `0.0.0.0:5000` (stdlib `ThreadingHTTPServer`). |
| Startup without webhook | `load_config()` fails with `DISCORD_WEBHOOK_URL is required when USE_DISCORD is true`, and `run_daemon()` returns 1 (`src/calendarr/__main__.py`). **The process exits when no webhook is set.** See section 10. |
| Data write paths | Logs: `LOG_DIR`/`LOG_FILE` (created by `os.makedirs`, `src/calendarr/log.py`). Custom footers: `/app/custom_footers` (hard-coded). No database: no sqlite or DB library in the code (code search returned 0 hits). |
| Dependencies | None at runtime. Sonarr/Radarr are data sources via calendar feed URLs (`CALENDAR_URLS`), not containers. |

## 2. Target layout

- `apps/calendarr/Dockerfile`
- `apps/calendarr/docker-bake.hcl`
- `apps/calendarr/settings.yaml`
- `apps/calendarr/container-test.yaml`
- `apps/calendarr/start.sh` (replaces upstream `entrypoint.sh`, which writes to `/app/custom_footers` and is not used)
- `apps/calendarr/defaults/custom_footers/discord_footer.md` and `slack_footer.md` (copied from upstream `calendarr/custom_footers/`, the seed for `/config/custom_footers`). Needed because the seed must live outside `/app`.
- Source is fetched from the tag archive in the Dockerfile, so `src/` is not copied from the repo.

Not needed: `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (from the brief's base table). Upstream uses `python:3.15.2-slim`, which is the same Python. The base bundles `/app/venv` (read-only at runtime). Closest sibling: `apps/bazarr` (python base, pip deps, read-only `/app`). Python-runtime rules apply.

## 4. Dockerfile

1. Build step as `USER root` (base default is `apps`; switch only for installs). `ARG VERSION` (value from bake, no inline default). Download `https://github.com/jordanlambrecht/calendarr/archive/refs/tags/v${VERSION}.tar.gz` to `/tmp`, verify the SHA-256 recorded in the Dockerfile, extract to `/tmp/calendarr-src`.
2. Install pinned deps into the bundled venv at build time, not at runtime: `/app/venv/bin/pip install --no-cache-dir -r /tmp/calendarr-src/requirements.txt`. Set `PIP_CACHE_DIR=/tmp/pip-cache` so no cache lands in `/config` or `/app`. Remove `/tmp/calendarr-src` and `/tmp/pip-cache` in the same `RUN`.
3. Copy `src/` to `/app/src/` (`cp -r /tmp/calendarr-src/src /app/src`). Copy the default footers to `/app/default_footers/` only if the build needs them; otherwise keep them in the app folder as `defaults/custom_footers` and copy into the image with `COPY --chmod=0755 . /` (step 7).
4. Footer path: create the symlink at build time, `ln -s /config/custom_footers /app/custom_footers`. This works with read-only `/app` at runtime because the symlink is created in the image layer and only the target is written, in `/config`. Start script seeds the target (see section 7).
5. `ENV PYTHONUNBUFFERED=1 PYTHONPATH=/app/src LOG_DIR=/config/logs LOG_FILE=calendarr.log`. Logs go to `/config/logs` (persistent) rather than the upstream `/app/logs`, which is read-only here (decision in section 10).
6. `EXPOSE 5000`. `VOLUME /config`. No `HEALTHCHECK` (the test harness probes the port; keep the image small).
7. `COPY --chmod=0755 . /` (required). This brings `start.sh` and `defaults/`.
8. `USER apps`. Entry command: `/start.sh`, which execs `/app/venv/bin/python -m calendarr` with `WORKDIR /app`.

Pins: `ARG VERSION` must match `docker-bake.hcl` `VERSION`. Python deps are already pinned (`==`) upstream, so no extra pins.

## 5. docker-bake.hcl

- `variable "APP" { default = "calendarr" }`
- `variable "VERSION"` with `// renovate: datasource=github-releases depName=jordanlambrecht/calendarr versioning=semver` and `default = "1.5.2"`.
- `variable "LICENSE" { default = "GPL-3.0" }`
- `variable "SOURCE" { default = "https://github.com/jordanlambrecht/calendarr" }`
- Standard targets as in `apps/changedetection/docker-bake.hcl` (docker-metadata-action, image, image-local, image-all, group default). `image` sets `args = { VERSION = "${VERSION}" }` and the `source`/`licenses` labels.
- Validate with `docker buildx bake --print` in `apps/calendarr`.

## 6. settings.yaml

- Schema header as in sibling apps, `schema_version: 1`, `upstream_env_url: "https://github.com/jordanlambrecht/calendarr"`.
- `ports`: `5000` tcp, `required: true`.
- `env` (only vars the start path reads with defaults; the rest are user-set): `TZ` default `UTC`; `LOG_DIR` default `/config/logs`; `LOG_FILE` default `calendarr.log`; `CALENDAR_URLS` default `[]`; `SCHEDULE_TYPE` default `WEEKLY`; `RUN_TIME` default `09:00`; `CALENDAR_RANGE` default `AUTO`; `DISCORD_WEBHOOK_URL` default `""`, `required` decision in section 10. Every default must match `config.py`.
- `volumes`: `/config`, `required: true`.
- `dependencies`: none.

## 7. start.sh

Bash, `set -euo pipefail`:
1. `mkdir -p /config/custom_footers /config/logs`.
2. For `discord_footer.md` and `slack_footer.md`: copy from `/defaults/custom_footers/` to `/config/custom_footers/` only when missing. Never overwrite existing user files.
3. `cd /app` and `exec /app/venv/bin/python -m calendarr` with `PYTHONPATH=/app/src`. `exec` keeps PID 1 signal handling.

No write to `/app`. `/tmp` is not used (no cache).

## 8. container-test.yaml

- Schema header from `apps/changedetection/container-test.yaml` (forgetool test schema).
- `timeoutSeconds`: start is fast (python), copy the sibling value (`apps/changedetection` uses 180; use the same).
- `tcp: port '5000'`, matching `settings.yaml`.
- Blocker for this test: the test runs with no env vars, and the app exits 1 without `DISCORD_WEBHOOK_URL` (section 10). Until that is resolved, the tcp probe cannot pass. Do not add a fake webhook default to pass the test.

## 9. Rootless and read-only-rootfs adaptations

- Upstream `/app/logs` and `/app/custom_footers` are writable mounts in the chart. Here `/app` is read-only, so logs go to `/config/logs` and the footers are a symlink into `/config`.
- Chart defaults: runAsNonRoot false and runAsUser 0. Our image runs as `apps`, which the app does not need.
- Read-only rootfs: `--read-only --tmpfs /tmp` works because nothing writes to `/tmp` at runtime. Logs and footers go to `/config` (a named volume in the probe).
- No DB, no extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- **Blocker: no-env startup**. `DISCORD_WEBHOOK_URL` (or `SLACK_WEBHOOK_URL` with `USE_SLACK=true`) is required, otherwise the process exits 1 (`src/calendarr/config.py` and `__main__.py`). The forgetool test passes no env, so the container cannot pass its own test as published. Options for the user to decide (do not pick one silently): (a) accept a narrowed test that only checks the image builds and the config error message appears in logs (this is NOT a DB dependency, so the DB-dependency exception does not apply, which is a problem); (b) ask upstream to allow a no-webhook start; (c) add a test-only env mechanism to forgetool (out of repo scope). Recommended: (b) or (c). Do not weaken the port probe.
- **Footer path**: hard-coded `/app/custom_footers` (section 1). The symlink approach depends on it being a plain file path read by `open()`. UNVERIFIED that no code path resolves it differently; verify on first run with footers present.
- **Log dir**: `LOG_DIR` default `/app/logs` is replaced by `/config/logs`. Upstream logs are rotated (`RotatingFileHandler`). UNVERIFIED whether a read-only `/app` is needed anywhere else.
- **Draft errors corrected**: the draft says "keep the DB in /config". Calendarr has no database (section 1). The draft says "tag: latest" for the chart and "release v1.5.2" for the app; this plan pins the release tag.
- **Source archive not checksummed upstream**: pin by tag, record SHA-256 at build time (UNVERIFIED value).
- **Chart security**: non-root possible (the chart sets runAsUser 0, which this image does not need). Confidence medium.
- **Blockers**: the webhook requirement above. No musl, GPU or arm64 issue found (pure Python).
- **UNVERIFIED**: arm64 pip install from source (pure Python, expected to work); forgetool schema for `http` probe on `/health` (optional).

## 11. Build and test steps

From `apps/calendarr`:
1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe run with a webhook only if the user approves section 10 option (b) or (c). Otherwise the probe fails at the config step and that output is the expected result to report: `docker run --rm --name calendarr-probe --read-only --tmpfs /tmp -v calendarr-probe-config:/config calendarr:1.5.2`, then `docker logs calendarr-probe`. Expected with no webhook: `Configuration error. DISCORD_WEBHOOK_URL is required when USE_DISCORD is true`, exit 1. Cleanup: `docker rm -f calendarr-probe; docker volume rm calendarr-probe-config`.
4. With a dummy but valid-looking webhook URL set for local testing only (never committed), confirm: process stays up, `/health` answers on 5000, `/config/logs/calendarr.log` is written, `/config/custom_footers` seeded. Use a fresh volume each round.
5. `forgetool containers test --image calendarr:1.5.2 --config ./apps/calendarr/container-test.yaml` (after section 10 is resolved).

## 12. PR checklist

- Branch `feat/add-calendarr`, commit `feat(calendarr): add new container`, PR title the same.
- PR template `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept, only applicable boxes checked.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check shows status).
- State what is untested: the no-webhook blocker, footer symlink behaviour, arm64, the source archive SHA-256, Discord and Slack delivery. Do not tick "Built container locally" unless the build ran.
