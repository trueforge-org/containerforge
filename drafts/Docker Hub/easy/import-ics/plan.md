# import-ics — implementation plan
> Source: ./draft.md · Target: apps/import-ics/ · Difficulty: easy (code) but with a license blocker · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| What it really is | **Not a web app.** `import_ics` is a cron-driven script that downloads `.ics` files and imports them into a CalDAV server. It opens no port. The draft's `5000/http` (inferred) is wrong. |
| Version | No releases or tags. Pinned commit `ec04d6c113aa9014f2127639db9801a1fb4f9d3b` (draft links `ec04d6c`; full SHA read from the commit feed, last commit 2022-06-08). Use the full SHA as `VERSION`. |
| Renovate | `// renovate: datasource=git-refs depName=https://github.com/Vilhjalmr26/import_ics currentValue=main` (default branch `main`) |
| License | None: `LICENSE` is 404 at the pinned commit; README names none. UNVERIFIED, see section 10. |
| Source URL | https://github.com/Vilhjalmr26/import_ics |
| Download | `https://github.com/Vilhjalmr26/import_ics/archive/<sha>.tar.gz` (pure Python, same for both arches). No checksum published; the commit SHA pins the content. |
| Python deps | `import_ics/requirements.txt` is a single unpinned line: `caldav`. Code also imports `requests`, which caldav 3.7.0 does **not** depend on (its PyPI metadata lists `niquests`), so `requests` must be installed explicitly. Latest on PyPI today: caldav 3.7.0 (`>=3.10`), requests 2.34.2. |
| Upstream Dockerfile reviewed | `dockerfile` at ec04d6c: `python:3.9.13-alpine3.16`, ENV `ICS_URL`, `ICS_USERNAME`, `ICS_PASSWORD`, `CRONTAB_SCHEDULE="0 0 * * *"`, `TZ=UTC`; copies `./import_ics` to `/import_ics`, moves `calendar_download_map.py` to `samples/`, symlinks `/config/calendar_download_map.py`, `entrypoint.sh` writes a crontab and runs `crond -f`. |
| Env vars read | `ICS_URL`, `ICS_USERNAME`, `ICS_PASSWORD` (read by `import_ics.py` via `os.getenv`), `CRONTAB_SCHEDULE` (read by the upstream entrypoint), `TZ`. |
| Paths | Relative to the working directory: `./ical_export/` (written by the download step, read by the importer) and `import calendar_download_map` (module with a `mapping = {"calendar name": "https://...ics"}` dict). README: manual `.ics` files go in `/config/ical_export`. |

## 2. Target layout

```
apps/import-ics/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/calendar_download_map.py   # sample mapping, seeded to /config when missing
```

`defaults/` is needed for the seed file (allow-listed). No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: Python script with one pure-Python dependency (draft agrees). Closest sibling: `apps/bazarr` for the python base and `start.sh` shape, `apps/changedetection` for installing into `/app/venv`. Python rules apply: `/app/venv` is read-only at runtime, caches in `/tmp`.

## 4. Dockerfile

1. `FROM` above, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `ENV PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1` (the python base already sets most pip variables) and `PYTHONPATH=/config`. Reason: `import_ics.py` does `import calendar_download_map`; the file lives in `/config`, which is writable and user-owned.
3. supercronic (cron without root, stdout logging): `ARG SUPERCRONIC_VERSION` with comment `# renovate: datasource=github-releases depName=aptible/supercronic` and value `v0.2.51` (latest checked). Download `https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}` to `/usr/local/bin/supercronic`, verify against the sha256 digest GitHub shows for the asset (v0.2.51: amd64 `cc232108...a123`, arm64 `4ae22576...2b94`; re-check at build time and fail on mismatch), `chmod 0755`. License MIT: `curl` its `LICENSE.md` into `/usr/share/licenses/supercronic/`. Keep `SUPERCRONIC_VERSION` out of docker-bake (it is a secondary tool) or also expose it in bake `args` so the two files stay aligned; choose the latter to follow "values match bake".
4. App install in one RUN: `mkdir -p /app/import_ics`; `curl -fsSL https://github.com/Vilhjalmr26/import_ics/archive/${VERSION}.tar.gz | tar xz -C /app/import_ics --strip-components=1`; then `cp /app/import_ics/import_ics/* ...` or move `import_ics/` contents so the script ends at `/app/import_ics/import_ics.py`; **delete** `calendar_download_map.py` from the app dir (the module must resolve from `/config` through `PYTHONPATH`; `sys.path[0]` would otherwise shadow it); `/app/venv/bin/pip install --no-cache-dir -r requirements.txt` (pin the result by replacing the one line with `caldav==3.7.0` and `requests==2.34.2` via `sed`/printf in the RUN, so the build is reproducible; leave a comment that renovate does not track these).
5. No apt packages (curl, tar, tzdata are in the ubuntu base). `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/*`.
6. Licenses: upstream has none; write a `NOTICE` with source and commit to `/usr/share/licenses/import-ics/`.
7. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`, `WORKDIR /config`. No `EXPOSE` (no port).

## 5. docker-bake.hcl

- `APP` = `import-ics`
- `VERSION` with the git-refs renovate comment above, `default = "ec04d6c113aa9014f2127639db9801a1fb4f9d3b"`
- `LICENSE`: no license in upstream. Do not invent; open question for the maintainer (see section 10).
- `SOURCE` = `https://github.com/Vilhjalmr26/import_ics`
- Standard four targets plus default group (copy `apps/bazarr/docker-bake.hcl`); `image` also passes `SUPERCRONIC_VERSION` in `args` if added as a variable with its own renovate comment.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

Header, `schema_version: 1`, `upstream_env_url: "https://github.com/Vilhjalmr26/import_ics"`.

- ports: none. Write `ports: []` and say in the PR that the app has no listener.
- env (all four are real upstream variables, read by the app or by `start.sh`):
  - `ICS_URL` default `""` required false (CalDAV server URL)
  - `ICS_USERNAME` default `""` required false
  - `ICS_PASSWORD` default `""` required false
  - `CRONTAB_SCHEDULE` default `"0 0 * * *"` required false (same default as upstream)
  - `TZ` default `"Etc/UTC"` required false
- volumes: `/config` required true (holds `calendar_download_map.py` and `ical_export/`).
- dependencies: none in ContainerForge; a CalDAV server (for example Radicale or Nextcloud) is needed at runtime but is external. UNVERIFIED which of them exist in `apps/`.

Upstream default values (`https://example.com/dav.php`, `username`, `password`) are placeholders; keep empty here so an unconfigured container does not try to log in.

## 7. start.sh

`#!/usr/bin/env bash`, `set -euo pipefail`.

1. `cd /config`; `mkdir -p /config/ical_export`.
2. Seed only when missing: `[ -f /config/calendar_download_map.py ] || cp /defaults/calendar_download_map.py /config/calendar_download_map.py`.
3. `: "${CRONTAB_SCHEDULE:=0 0 * * *}"`; write `/tmp/crontab` with one line: `${CRONTAB_SCHEDULE} /app/venv/bin/python /app/import_ics/import_ics.py` (ephemeral in `/tmp`, rebuilt each start so schedule changes apply).
4. If `ICS_URL` or `ICS_USERNAME` is empty: log `ICS_URL/ICS_USERNAME not set; jobs will fail until configured` but keep running (the harness starts the image without env).
5. The credentials stay in the environment (supercronic passes it to jobs), never in a file or in arguments.
6. `exec supercronic /tmp/crontab` (stays in the foreground, logs to stdout; the working directory is `/config`, so `./ical_export` and `PYTHONPATH` resolve there).

Optional env `IMPORT_ON_START=true` is not part of upstream and is not added (keep scope minimal).

## 8. container-test.yaml

No port exists, so no tcp/http probe (the settings list no ports). Real assertions on files and the runtime:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/import_ics/import_ics.py
- /usr/local/bin/supercronic
- /defaults/calendar_download_map.py
healthCommands:
- command: /app/venv/bin/python -c "import caldav, requests" && test -f /app/import_ics/import_ics.py
- command: pgrep -x supercronic
```

The first command must not end in a quote: `include/healthcheck.sh` strips a trailing quote from the value, which would break the in-image HEALTHCHECK.

UNVERIFIED: `pgrep` exists in the base image (procps); if not, use `test -d /proc/1` style alternative or drop that line only after replacing it with an equal assertion. Env-dependent code (the actual import) is not testable without a CalDAV server; do that by hand per the protocol.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `crond` as root, `chown root:root /ical_export` | `supercronic` as `apps`, crontab in `/tmp` |
| `./ical_export` in `/import_ics` | `/config/ical_export` (cwd is `/config`) |
| `/config/calendar_download_map.py` symlinked into the code dir | `PYTHONPATH=/config`, file removed from the code dir |
| pip install at runtime | build time into `/app/venv`, never mutated at runtime |

Chart runs as UID 0 with a writable rootfs; here UID 568, read-only rootfs with `/tmp` tmpfs. Draft extra persistence `/import_ics/ical_export` becomes `/config/ical_export` (single volume). No capabilities.

## 10. Risks, caveats and open questions

- **No license** in the repo: cannot fill `LICENSE` honestly; ask upstream or the maintainer first. Blocker for merge.
- Abandoned (last commit 2022); the code is simple but unmaintained. The draft's "no auth by default web app" caveat does not apply, since there is no web server; the real risk is the CalDAV password in env.
- Draft caveats: "python 3.9 base and old pins" is moot (unpinned `caldav`, now modern). UNVERIFIED that the script works with caldav 3.x (`DAVClient` context manager, `principal().calendars()`, `save_event(ical=...)`) as it was written for 2022. Test against a real server (for example a throw-away Radicale) before finalizing; fall back to pinning an older caldav (for example 1.x) if the API changed.
- Downloaded ICS content is parsed by hand line by line; malformed files may fail silently.
- `CRONTAB_SCHEDULE` is passed to supercronic (5 field syntax, plus optional seconds? supercronic accepts standard 5 fields): UNVERIFIED for edge syntaxes upstream's busybox crond accepted.
- Not a blocker: no musl, GPU, privileged, arm64 is fine.

## 11. Build and test steps

```sh
cd apps/import-ics
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create import-ics-probe-config
docker run --rm -d --name import-ics-probe --read-only --tmpfs /tmp \
  -v import-ics-probe-config:/config import-ics:ec04d6c113aa9014f2127639db9801a1fb4f9d3b
docker logs -f import-ics-probe
```

Readiness: supercronic log lines `read crontab: /tmp/crontab` and the next job schedule, process still running, `/config/calendar_download_map.py` and `/config/ical_export/` created. Second run with a real or fake CalDAV (for example `-e CRONTAB_SCHEDULE="* * * * *"`) and a local Radicale to prove one import cycle. Then `forgetool containers test --image import-ics:<sha> --config ./apps/import-ics/container-test.yaml`; remove container and volume.

## 12. PR checklist

- Branch `feat/add-import-ics`, commit and PR title `feat(import-ics): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; tick only applicable boxes.
- Notes: `🤖 This PR is AI generated.`; mention license gap and no listener.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested to state: real CalDAV import, caldav 3.x compatibility, arm64, supercronic schedule edge cases.
