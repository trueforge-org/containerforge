# changedetection-io — implementation plan
> Source: ./draft.md · Target: apps/changedetection-io/ · Difficulty: easy · Role: main · Verified on 2026-11-25
>
> **Blocker before any file is created**: `apps/changedetection/` already exists in this repo (same upstream, version 0.70.4, `-d /config`). Confirm with the user whether a second app is wanted. Sections 2 to 12 assume yes. See section 10.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **0.70.4** (latest release, published 2026-11-19). Source: https://github.com/dgtlmoon/changedetection.io/releases/tag/0.70.4. Matches the chart's pinned `ghcr.io/dgtlmoon/changedetection.io:0.70.4`. |
| Renovate | `datasource=github-releases depName=dgtlmoon/changedetection.io versioning=loose`, as in `apps/changedetection/docker-bake.hcl`. |
| License | **Apache-2.0** per GitHub license API (https://api.github.com/repos/dgtlmoon/changedetection.io/license) and the LICENSE file. **Conflict**: `apps/changedetection/docker-bake.hcl` sets `AGPL-3.0-or-later`. The new bake must use Apache-2.0, and the existing sibling value should be raised with the user. |
| Source URL | https://github.com/dgtlmoon/changedetection.io |
| Per-arch download | No prebuilt binary is published. Install from source: tag archive `https://github.com/dgtlmoon/changedetection.io/archive/refs/tags/0.70.4.tar.gz` (standard GitHub form, UNVERIFIED that it was fetched). The draft's "pip:changedetection.io" was not confirmed on PyPI (UNVERIFIED), so the install uses the repo's `requirements.txt`. |
| Checksum source | None published. Pin by tag and record SHA-256 at build time (UNVERIFIED value). |
| Upstream Dockerfile reviewed | https://github.com/dgtlmoon/changedetection.io/blob/master/Dockerfile: two stages on `python:${PYTHON_VERSION}-slim-bookworm` (default 3.11). Builder installs system build tools and `uv~=0.9`, then `uv pip install --target=/dependencies -r /requirements.txt` (with piwheels extra index on arm/v6, v7 and v8). Playwright and OpenCV are installed separately and optional. Final stage: apt runtime libs (`libxslt1.1`, `locales`, `poppler-utils`, `file`, `zlib1g`, `libglib2.0-0`, `libsm6`, `libxext6`, `libxrender-dev`), `locale-gen`, `ENV PYTHONUNBUFFERED=1`, `RUN mkdir /datastore`, `ENV PYTHONPATH=/usr/local`, `EXPOSE 5000`, `COPY changedetectionio /app/changedetectionio`, `pybabel compile`, `COPY changedetection.py /app/changedetection.py`, `ENV LC_ALL=en_US.UTF-8`, `WORKDIR /app`, `ENTRYPOINT ["/docker-entrypoint.sh"]`, `CMD ["python", "./changedetection.py", "-d", "/datastore"]`. Upstream also runs `sed` on `/etc/ssl/openssl.cnf` to set `SECLEVEL=1`. |
| Entrypoint (upstream) | https://github.com/dgtlmoon/changedetection.io/blob/master/docker-entrypoint.sh: when `EXTRA_PACKAGES` is set, runs `pip3 install` on every start, then `exec "$@"`. This writes to the rootfs, so it does not work with read-only rootfs and is not carried over. |
| Env vars (real) | `PORT` (default 5000), `LISTEN_HOST` (default `0.0.0.0`), `MALLOC_ARENA_MAX` (set to 2 if unset), `LITELLM_LOCAL_MODEL_COST_MAP`, `LOGGER_LEVEL`, `LC_ALL`, `PYTHONUNBUFFERED`. Datastore path comes from the `-d` argument (changedetection.py). Source: changedetection.py and changedetectionio/flask_app.py. |
| Port | 5000 tcp. |
| Data write path | `/datastore` upstream (from `-d`). Remapped here to `/config` via `-d /config`, same as `apps/changedetection/start.sh`. |
| Dependencies | None required. Browser fetchers (Playwright or Selenium) are separate containers; `PLAYWRIGHT_DRIVER_URL` is the hook for them (already in `apps/changedetection/settings.yaml`). |
| arm64 | Upstream Dockerfile has explicit arm handling (piwheels, OpenCV skipped on arm/v7 and v8), so arm64 is supported upstream. |

## 2. Target layout

- `apps/changedetection-io/Dockerfile`
- `apps/changedetection-io/docker-bake.hcl`
- `apps/changedetection-io/settings.yaml`
- `apps/changedetection-io/container-test.yaml`
- `apps/changedetection-io/start.sh`

Not needed: `defaults/` (the app creates its datastore on first start), `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (brief base table). Upstream uses Python 3.11 on bookworm, so the Python version changes; the upstream `requirements.txt` must install on 3.15 (UNVERIFIED, first build decides). Closest sibling: `apps/changedetection` (same app, but it builds on `python-node:3.14.8` and installs under `/app/changedetection`, not this plan's `python:3.15.2` layout; `start.sh` runs `changedetection.py -d /config`). Python-runtime rules apply.

## 4. Dockerfile

1. `ARG VERSION` (value from bake, no inline default). `USER root` for installs only.
2. Install apt runtime packages from the upstream list that the base does not already provide: `libxslt1.1`, `poppler-utils`, `file`, `libglib2.0-0`, `libsm6`, `libxext6`, `libxrender-dev`, `locales`. Check against the base first (dockerfile rule: do not re-install what the base has). Run `apt-get clean && rm -rf /var/lib/apt/lists/*` in the same `RUN`.
3. Locales: generate `en_US.UTF-8` only (the draft's and upstream's full list of 18 locales costs about 21 MB and is not needed for the base). Set `ENV LC_ALL=en_US.UTF-8`. Mention the trade-off in the PR.
4. Download the tag archive to `/tmp`, verify SHA-256 (value recorded at build), extract, copy `changedetectionio/` to `/app/changedetectionio/` and `changedetection.py` to `/app/changedetection.py`, and `docs/api-spec.yaml` to `/app/docs/`.
5. Install Python deps into the bundled venv at build time: `/app/venv/bin/pip install --no-cache-dir -r /tmp/src/requirements.txt` with `PIP_CACHE_DIR=/tmp/pip-cache`. Exclude Playwright and OpenCV from the default install (upstream does this for arm32 reasons, keep the same split). Remove `/tmp/src` and `/tmp/pip-cache` in the same `RUN`.
6. `pybabel compile -d /app/changedetectionio/translations` in the same build venv.
7. Do not run the upstream `sed` on openssl.cnf unless the user wants weak-cipher monitoring. It is a system-file change and is out of scope; record it in section 10.
8. `ENV PYTHONUNBUFFERED=1 PYTHONPATH=/app/venv/lib/python3.15/site-packages` (or the base venv path, UNVERIFIED) and `ENV LC_ALL=en_US.UTF-8`.
9. `EXPOSE 5000`. `VOLUME /config`.
10. `COPY --chmod=0755 . /` (required), which brings `start.sh`.
11. `USER apps`. Entry: `/start.sh`.

Pins: `ARG VERSION` must equal `docker-bake.hcl` `VERSION`.

## 5. docker-bake.hcl

- `variable "APP" { default = "changedetection-io" }`
- `variable "VERSION"` with `// renovate: datasource=github-releases depName=dgtlmoon/changedetection.io versioning=loose` and `default = "0.70.4"`.
- `variable "LICENSE" { default = "Apache-2.0" }` (see section 1 conflict).
- `variable "SOURCE" { default = "https://github.com/dgtlmoon/changedetection.io" }`
- Standard targets as in `apps/changedetection/docker-bake.hcl`.
- Validate with `docker buildx bake --print` in `apps/changedetection-io`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/dgtlmoon/changedetection.io"`.
- `ports`: `5000` tcp, `required: true`.
- `env`: `PORT` default `5000`; `LISTEN_HOST` default `0.0.0.0`; `BASE_URL` default `""`; `TZ` default `Etc/UTC`; `PLAYWRIGHT_DRIVER_URL` default `""`; `USE_X_SETTINGS_FILE` default `""` (`BASE_URL`, `PLAYWRIGHT_DRIVER_URL`, `TZ`, `USE_X_SETTINGS_FILE` are the names `apps/changedetection/settings.yaml` lists; `PORT` and `LISTEN_HOST` are not in the sibling and come from upstream code, UNVERIFIED that `start.sh` defaults them are honoured). Every default must match what the app reads. No `EXTRA_PACKAGES` (not supported here, section 4 step 5 and section 10).
- `volumes`: `/config`, `required: true`.
- `dependencies`: none.

## 7. start.sh

Bash, `set -euo pipefail`:
1. `mkdir -p /config` (datastore). Do not overwrite existing `/config` state. The app creates its own files on first start.
2. `export PORT="${PORT:-5000}" LISTEN_HOST="${LISTEN_HOST:-0.0.0.0}"`. Fill env defaults from settings.yaml.
3. `cd /app` and `exec /app/venv/bin/python /app/changedetection.py -d /config`. `exec` keeps PID 1 signal handling.

Writes only to `/config` and `/tmp`. Nothing is written to `/app`.

## 8. container-test.yaml

- Schema header as in `apps/changedetection/container-test.yaml`.
- `timeoutSeconds: 180` (same as the sibling; the app starts a Flask server on an empty `/config`).
- `tcp: port '5000'`, matching `settings.yaml`.
- No env needed for the test. `/config` is empty on the test run, so the datastore creation path is exercised.

## 9. Rootless and read-only-rootfs adaptations

- Upstream `/datastore` becomes `/config` (`-d /config`).
- Upstream `docker-entrypoint.sh` and its `EXTRA_PACKAGES` pip step are removed, because pip would write to the read-only rootfs.
- Caches: `UV_CACHE_DIR` and `PIP_CACHE_DIR` point at `/tmp` at build time only. Nothing at runtime writes a cache, but if the app's Playwright or OpenCV path needs one, it goes to `/tmp`.
- Chart security (draft): non-root yes (runAsUser 568 default), read-only rootfs yes, privileged no. Extra persistence: `/datastore` in the chart maps to `/config` here.

## 10. Risks, caveats and open questions

- **Duplicate app (blocker)**: `apps/changedetection` already packages changedetection 0.70.4 with the same ports and `/config` datastore. Decide with the user: (a) do not create `apps/changedetection-io`, close the draft; (b) keep the existing app and only update it if something is missing; (c) create this app anyway, which needs the same name-distinction the user wants. This plan does not create anything until the user answers.
- **License conflict**: sibling bake says AGPL-3.0-or-later, upstream LICENSE and GitHub say Apache-2.0. Raise this for the existing app as well.
- **Python 3.15 vs upstream 3.11**: upstream pins deps for 3.11. Wheels for 3.15 are not checked (UNVERIFIED). If `requirements.txt` cannot install on 3.15, fall back to the closest base that works, and say so.
- **Browser fetchers**: JavaScript pages are not fetched without a separate Playwright or Selenium container. Document this; it is not a defect.
- **Notification targets**: none by default; users set them in the UI.
- **Chart tag pin**: pinned upstream tag, rolling upstream. Upgrades chosen deliberately via renovate.
- **`EXTRA_PACKAGES` not supported** (section 9).
- **Locales**: only `en_US.UTF-8` generated (section 4 step 3). Users who need other locale formatting lose that. Decision noted for the PR.
- **Blockers**: duplicate app (above). No musl, GPU or privileged needs found.
- **UNVERIFIED**: PyPI `changedetection.io` package; arm64 wheels for the full requirements; exact `PYTHONPATH` for the base venv; readiness log line.

## 11. Build and test steps

From `apps/changedetection-io` (only after section 10 is resolved):
1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe: `docker run --rm -d --name changedetection-io-probe --read-only --tmpfs /tmp -v changedetection-io-probe-config:/config changedetection-io:0.70.4`, then `docker logs -f changedetection-io-probe`. Expected: process still running after startup, Flask listening on `0.0.0.0:5000`. Readiness line UNVERIFIED; record the exact line from the first run in the PR. Cleanup: `docker rm -f changedetection-io-probe; docker volume rm changedetection-io-probe-config`.
4. Repeat with a fresh empty `/config` volume per round.
5. `forgetool containers test --image changedetection-io:0.70.4 --config ./apps/changedetection-io/container-test.yaml`.

## 12. PR checklist

- Branch `feat/add-changedetection-io`, commit `feat(changedetection-io): add new container`, PR title the same. Do not open this PR until section 10 (duplicate app) is answered.
- PR template `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept, only applicable boxes checked.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check shows status).
- State what is untested: arm64 build, Python 3.15 install of upstream requirements, browser fetchers, notification delivery, the existing sibling's license value. Do not tick "Built container locally" unless the build ran.
