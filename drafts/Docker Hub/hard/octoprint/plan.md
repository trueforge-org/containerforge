# octoprint — implementation plan
> Source: ./draft.md · Target: apps/octoprint/ · Difficulty: hard (draft) / medium in practice · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `2.0.1` (PyPI JSON, 2026-11-24). Draft tag `1.11.8` is outdated. `requires_python` `>=3.9,<3.16`. |
| Renovate | `datasource=pypi depName=OctoPrint versioning=pep440` |
| License | AGPL-3.0-or-later (PyPI metadata) |
| Source URL | https://github.com/OctoPrint/OctoPrint (site https://octoprint.org) |
| Per-arch download | Pure Python, no per-arch artifact. PyPI wheel `octoprint-2.0.1-py3-none-any.whl` sha256 `dc6e3e3acfbbdc469921a9d1998606fc62d64652830ba6b35b8d1a442072150c`; sdist `octoprint-2.0.1.tar.gz` sha256 `c5003c1fc76edd279ef09dd062e48042df8019551941ce907b51f2102b85edf1`. |
| Checksum source | PyPI JSON `urls[].digests.sha256` (above). |
| Upstream Dockerfile reviewed | https://github.com/OctoPrint/octoprint-docker/blob/32fdd6eae2a9a2c1f97f26cf4c7d3802cb0559db/Dockerfile : `python:3.10-slim-bullseye`, s6-overlay, haproxy front end on port 80, mjpg-streamer, `PIP_USER=true`, `PYTHONUSERBASE=/octoprint/plugins`, `VOLUME /octoprint`, `CAMERA_DEV=/dev/video0`, `MJPG_STREAMER_INPUT=-n -r 640x480`. Apt: avrdude, ffmpeg, imagemagick, v4l-utils, libjpeg62-turbo, libusb, openssh-client, etc. |
| Port / paths | OctoPrint default `server.port` 5000; `server.host` unset binds all interfaces (docs.octoprint.org config.yaml). Settings dir defaults to `~/.octoprint`; relocated with the CLI `--basedir` option (flag name from OctoPrint CLI, not shown on the config page: UNVERIFIED, confirm with `octoprint --help`). |
| Env vars | Upstream wrapper only has `CAMERA_DEV`, `MJPG_STREAMER_INPUT` (webcam streamer, out of scope). OctoPrint's own `OCTOPRINT_*` env overrides: UNVERIFIED, not documented on the pages read; not used in this plan. |

## 2. Target layout

```
apps/octoprint/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (OctoPrint creates `config.yaml` itself on first run; the first-run wizard handles the admin). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: pure Python app, `/app/venv` bundled by the base, pip installs into it at build time (read-only at runtime). Closest siblings: `apps/bazarr`, `apps/changedetection` (pip into `/app/venv/bin/pip`). Fallback if a transitive dependency lacks Python 3.15 wheels (UNVERIFIED): pin `python:3.14.8@sha256:...` like changedetection does, with a comment. `python-runtime.instructions.md` applies: `/app/venv` read-only, caches in `/tmp`.

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends` build deps `build-essential libffi-dev libjpeg-dev zlib1g-dev libyaml-dev` and runtime `ffmpeg libjpeg-turbo8 avrdude imagemagick openssh-client` (timelapse and firmware flashing, as in upstream; check what the base already has first). No pinned apt versions needed: the app version is `VERSION`, pip-pinned.
3. Install with a hash check: `/app/venv/bin/pip download --no-deps --no-cache-dir -d /tmp/ds "OctoPrint==${VERSION}"`, verify the wheel against `sha256sum` of the known value (kept in a Dockerfile `ARG OCTOPRINT_WHEEL_SHA256`; update with VERSION), then `/app/venv/bin/pip install --no-cache-dir /tmp/ds/octoprint-${VERSION}-py3-none-any.whl`. `PIP_CACHE_DIR=/tmp/pip`.
4. Licence: `mkdir -p /usr/share/licenses/octoprint && cp /app/venv/lib/python*/site-packages/octoprint-${VERSION}.dist-info/licenses/* /usr/share/licenses/octoprint/ 2>/dev/null || curl -fsSL -o /usr/share/licenses/octoprint/LICENSE https://raw.githubusercontent.com/OctoPrint/OctoPrint/${VERSION}/LICENSE.txt` (path of LICENSE in the dist-info: UNVERIFIED).
5. Purge build deps: `apt-get purge -y --auto-remove build-essential libffi-dev libjpeg-dev zlib1g-dev libyaml-dev`; `rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache`.
6. ENV: `HOME=/config`, `XDG_CACHE_HOME=/tmp/.cache`, `PIP_CACHE_DIR=/tmp/pip`, `PYTHONUNBUFFERED=1`, `PIP_USER=true`, `PYTHONUSERBASE=/config/plugins` (plugin installs from the OctoPrint UI go to persistent `/config/plugins`, because `/app/venv` is read-only; mirrors upstream's `/octoprint/plugins`), `PATH=/config/plugins/bin:$PATH`.
7. `USER apps`
8. `COPY --chmod=0755 . /`
9. `EXPOSE 5000`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "octoprint"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=OctoPrint versioning=pep440
  default = "2.0.1"
}

variable "LICENSE" {
  default = "AGPL-3.0-or-later"
}

variable "SOURCE" {
  default = "https://github.com/OctoPrint/OctoPrint"
}
```
Followed by `group "default"` and the `image`, `image-local` (`tags = ["${APP}:${VERSION}"]`, `output = ["type=docker"]`), `image-all` (amd64, arm64) targets, copied verbatim from `apps/adguardhome-sync/docker-bake.hcl`. Validate: `cd apps/octoprint && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/OctoPrint/OctoPrint"
ports:
  - port: 5000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
No other env vars (none verified). No dependency containers (draft: none).

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /config/plugins /tmp/.cache /tmp/pip
cd /config
exec /app/venv/bin/octoprint --basedir /config serve --host 0.0.0.0 --port 5000
```
Idempotent; OctoPrint writes `config.yaml`, `logs/`, `uploads/`, `timelapse/`, `data/` under `/config` itself on an empty volume. Nothing written to `/app`. Verify flag order (`--basedir` is a group option before `serve`; `--host/--port` are `serve` options) against `octoprint --help` and `octoprint serve --help`: UNVERIFIED.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '5000'
http:
- port: '5000'
  path: /
filePaths:
- /app/venv/bin/octoprint
- /usr/share/licenses/octoprint
```
Probe covers port 5000 (tcp and http). `/` redirects to the setup wizard on first run (HTTP 200 after redirect; if forgetool does not follow redirects use `/api/version`, which is public in OctoPrint: UNVERIFIED). timeout sibling: `changedetection` 180.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `~/.octoprint` (config, logs, uploads, timelapse) | `--basedir /config`, `HOME=/config` |
| pip user installs for plugins (`/octoprint/plugins`) | `PYTHONUSERBASE=/config/plugins`, `PIP_USER=true` (persistent by explicit design, pip cache in `/tmp/pip`) |
| `/app/venv` | read-only, never touched at runtime |
| haproxy:80 and s6-overlay as root | dropped; OctoPrint binds 5000 directly |
| mjpg-streamer webcam (`/dev/video0`) | not included (UNVERIFIED need; separate sidecar) |
| Draft: UID 0, rootfs writable, extra `/octoprint` pvc | UID 568, read-only rootfs; `/octoprint` data becomes `/config` (document migration: mount old volume at `/config`; OctoPrint config lives in `/octoprint/octoprint` upstream, so move contents up one level). Serial/USB: base user `apps` is already in group 20 (`dialout`, see `apps/ubuntu/Dockerfile`), so `/dev/ttyUSB0` mounted with group dialout works without root; device mounts and group mapping are runtime choices. |

## 10. Risks, caveats and open questions

- Serial/USB printer access needs device mounts and host-side permissions; cannot be tested in CI (no device).
- Python 3.15 compatibility of OctoPrint 2.0.1 dependencies (UNVERIFIED); fallback to python 3.14.8 base.
- OctoPrint 2.0.1 vs draft's 1.11.8: a major version, review release notes before pinning (UNVERIFIED breaking changes: config migration from 1.x).
- First start has no admin account; the setup wizard creates it in the UI.
- `ffmpeg`, `avrdude` and `imagemagick` are optional features; confirm the image size trade-off.
- UNVERIFIED count: 6 (`--basedir` flag order, `OCTOPRINT_*` env, licence file path, `/` redirect behaviour, Python 3.15 wheels, webcam need).

## 11. Build and test steps

```sh
cd apps/octoprint
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create octoprint-probe-config
docker run --rm -d --name octoprint-probe --read-only --tmpfs /tmp -v octoprint-probe-config:/config octoprint:2.0.1
docker logs -f octoprint-probe
forgetool containers test --image octoprint:2.0.1 --config ./apps/octoprint/container-test.yaml
docker rm -f octoprint-probe; docker volume rm octoprint-probe-config
```
Expected readiness log: `Listening on http://0.0.0.0:5000` (OctoPrint server start line; exact wording UNVERIFIED) and no traceback. Also install a plugin through the UI once to confirm `/config/plugins` works on a read-only rootfs. Round limit 10; clean up between rounds.

## 12. PR checklist

- Branch `feat/add-octoprint`; commit and PR title `feat(octoprint): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` (keep sections, tick only applicable boxes); include source, version `2.0.1`, base `python:3.15.2`, ports/volumes; put `🤖 This PR is AI generated.` in Notes.
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested at plan time: all builds and runs, arm64 build, plugin install on read-only rootfs, serial/USB access, Python 3.15 dependency set. Say so in the PR.
