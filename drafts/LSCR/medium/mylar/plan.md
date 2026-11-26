# mylar — implementation plan
> Source: ./draft.md · Target: apps/mylar/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.11.0 (the draft pin, and the latest non-prerelease). GitHub release `v0.11.0` published 2026-08-17T16:58:52Z, marked Latest, not a pre-release. Source: https://api.github.com/repos/MylarComics/mylar3/releases/latest (read via `gh api`, direct API returned 403), https://github.com/MylarComics/mylar3/releases/tag/v0.11.0 |
| Difference from draft | None on version. The draft names no release asset; the release lists 2 assets but their names did not load (UNVERIFIED). The API shows no assets, so the source tarball is the artifact. |
| Renovate | `datasource=github-releases depName=MylarComics/mylar3 versioning=semver` (tags carry a `v` prefix, so semver handles them) |
| License | UNVERIFIED (not fetched in this run). Check the `LICENSE` file in the repo before setting `LICENSE` in docker-bake.hcl. |
| Source URL | https://github.com/MylarComics/mylar3 |
| Download | Source tarball `https://api.github.com/repos/MylarComics/mylar3/tarball/${VERSION}` (API tarball, follows a redirect). Alternative `https://github.com/MylarComics/mylar3/archive/refs/tags/${VERSION}.tar.gz` is UNVERIFIED (not fetched). No per-arch binaries: pure Python. |
| Checksum source | None confirmed. The release has no checksum asset that we could read. The API tarball is pinned by tag, and GitHub does not publish a checksum for it. UNVERIFIED for any other checksum source. |
| Python dependencies | `requirements.txt` at tag v0.11.0 (https://raw.githubusercontent.com/MylarComics/mylar3/v0.11.0/requirements.txt). 23 lines, all minimum pins (`>=`) except `urllib3<2`. Notable: `Pillow>=10.1`, `CherryPy>=18.5.0`, `rarfile>=4.0`, `requests[socks]>=2.22.0`, `tenacity>=8.2.3`, `packaging>=22.0`, `pycryptodome>=3.19.0`. No environment markers. |
| Upstream Dockerfile reviewed | Not fetched in this run (the linuxserver Dockerfile at commit `0a973d043b16789a002ada4441e87aa1dcbd3b0c` is UNVERIFIED for base, entrypoint, env, ports). The draft's description (unrar from a linuxserver stage, venv, /config) comes from the draft only. |
| unrar | Draft: apt `unrar`. Sibling: `apps/unrar` builds unrar from the rarlab source tarball (`https://www.rarlab.com/rar/unrarsrc-${VERSION}.tar.gz`). Ubuntu package version and license are UNVERIFIED. |
| Port | 8090 (draft, web UI). UNVERIFIED against upstream code: the port was not confirmed on a fetched page. |
| Env vars (real) | UNVERIFIED. None confirmed on a fetched page. The draft names no env vars. |
| Data path | Draft says `/config` for config and database. UNVERIFIED against upstream (the datadir flag was not fetched). |
| Ubuntu archive | `unrar` for 26.04 not checked (UNVERIFIED). |

> NOTE (checked in repo): `apps/mylar3` already exists (python base, `docker-bake.hcl` VERSION `0.8.3`, source `mylar3/mylar3`, port 8090, `--datadir /config/mylar`, seeds `/config/scripts`). This plan's `apps/mylar` (MylarComics/mylar3 v0.11.0) would duplicate it. Decide whether to bump `apps/mylar3` instead (needs human decision; draft's chart `mylar` maps to the same app). The existing `apps/mylar3/start.sh` is a verified precedent for the flags `--nolaunch` and `--datadir`.

## 2. Target layout

- `apps/mylar/Dockerfile`
- `apps/mylar/docker-bake.hcl`
- `apps/mylar/settings.yaml`
- `apps/mylar/container-test.yaml`
- `apps/mylar/start.sh`

No `defaults/`, `etc/` or `health/` needed: mylar seeds its own config under `/config` on first start (to confirm on the first run). No `root/` (never used). No `DOWNSTREAM_CHANGES.md`: mylar is not a `FROM` base for other apps.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. It is a Python web app with pip dependencies, so the python base fits, and `/app/venv` is bundled by the base (python-runtime rules). Closest sibling: `apps/bazarr` (Python web app from a release archive, `pip`/`uv` install, unrar copied from a LinuxServer image, `WORKDIR /config`, `exec` of the app in `start.sh`). The Ubuntu base is only a fallback (the draft's alternative) if the python base lacks a needed package.

## 4. Dockerfile

1. `ARG VERSION` and `ARG TARGETARCH` (TARGETARCH unused for mylar but kept for consistency with siblings only if needed; do not add it otherwise).
2. `USER root`.
3. Install apt packages needed at runtime and build time, pinned against `VERSION` where they come from apt: `unrar` (UNVERIFIED package version and license, see section 10). Add build deps only if a wheel is missing (Pillow and cryptography ship wheels for most arches; confirm during build).
4. Download the source tarball to `/tmp`, verify it (no checksum published: record the tag in the image label, and note the gap in section 10), extract into `/app/mylar` with `--strip-components=1`.
5. Install Python deps into the bundled venv at build time: `/app/venv/bin/pip install --no-cache-dir -r /app/mylar/requirements.txt` with `PIP_CACHE_DIR=/tmp/pip`. Do not write to `/app/venv` at runtime. Do not use `/config/venv`.
6. Copy the unrar binary into `/usr/bin/unrar` (from the apt install, or from the sibling build, see section 10).
7. License: `COPY` the upstream `LICENSE` to `/usr/share/licenses/mylar/LICENSE` (UNVERIFIED that the file exists at tag v0.11.0; check during build).
8. Cleanup: `rm -rf /tmp/* /root/.cache` and apt lists.
9. Permissions: `chown -R root:root /app && chmod -R 755 /app` (read-only at runtime, as bazarr does).
10. Environment: `ENV HOME=/config PIP_CACHE_DIR=/tmp/pip`.
11. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 8090
VOLUME /config
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mylar"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=MylarComics/mylar3 versioning=semver
  default = "v0.11.0"
}

variable "LICENSE" {
  default = "UNVERIFIED"   # set from the repo LICENSE file (not fetched)
}

variable "SOURCE" {
  default = "https://github.com/MylarComics/mylar3"
}

group "default" {
  targets = ["image-local"]
}

# image, image-local (output type=docker, tags ${APP}:${VERSION}), image-all (linux/amd64, linux/arm64)
# copied from apps/bazarr/docker-bake.hcl
```

Run `docker buildx bake --print` (exit 0 required). The Dockerfile consumes the same `VERSION` through `ARG VERSION`. `VERSION` keeps the `v` prefix, so the tarball URL uses `${VERSION}` as-is.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/MylarComics/mylar3"
ports:
  - port: 8090
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: UMASK
    default: "002"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only TZ and UMASK are listed, as sibling apps do. Mylar's own env vars are UNVERIFIED and must not be added until confirmed on the upstream code. Port 8090 is UNVERIFIED against upstream code: confirm on the first run before keeping it. No dependencies: metadata services (e.g. ComicVine) are configured in the UI with a user-supplied API key, not a container dependency.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /app/mylar
exec /app/venv/bin/python /app/mylar/Mylar.py \
    --datadir /config \
    --port 8090 \
    --nolaunch
```

The script is idempotent and seeds nothing: mylar creates its database and config under `/config` on first start (UNVERIFIED flags, confirm against the upstream CLI). No writes to `/app`. Caches go to `/tmp` (pip uses `/tmp/pip` at build time only). Bind address: check whether mylar binds to 0.0.0.0 or localhost by default (UNVERIFIED); if it binds localhost, add the bind flag or config value. The `exec` gives PID 1 signal handoff.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8090'
http:
- port: '8090'
  path: /
filePaths:
- /app/mylar/Mylar.py
- /app/mylar/requirements.txt
- /usr/bin/unrar
- /usr/share/licenses/mylar/LICENSE
```

The test runs with no env vars, which is fine: mylar's start path needs no secrets. Probe path `/` is UNVERIFIED (the web root may redirect to a login or setup page; use whichever path returns 200 on the first run). `timeoutSeconds` 120 is an estimate: the sibling `apps/bazarr` has no timeout set; confirm with the first run.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Config, database, logs (datadir) | `--datadir /config` (flag UNVERIFIED) |
| Python bytecode, pip cache | `PYTHONDONTWRITEBYTECODE=1` (python base sets it), `PIP_CACHE_DIR=/tmp/pip` at build |
| CA certificates | bazarr copies the CA bundle; confirm whether mylar needs it for external calls (UNVERIFIED) |
| unrar binary | `/usr/bin/unrar`, read-only, from the image |

The draft expectations: chart runs as UID 0 and `readOnlyRootFilesystem: false`, not privileged. This image runs as `apps` and works with `--read-only --tmpfs /tmp`, given the datadir remap above. Existing chart users with data at `/config` must keep it; the chart persisted `/config` (per draft), so no migration is expected, but UNVERIFIED.

## 10. Risks, caveats and open questions

- unrar licence: the rarlab license restricts redistribution and reverse-engineering of the RAR algorithm; the Ubuntu `unrar` package is non-free. Confirm it can be packaged before publishing; the sibling `apps/unrar` route (built from the rarlab source) is the other option and needs its published image tag confirmed (UNVERIFIED).
- No checksum published for the release tarball. Pin by tag and record the tag in the image label; note the gap in the PR.
- Mylar's own license: UNVERIFIED. The `LICENSE` in docker-bake.hcl must match it.
- Upstream CLI flags (`--datadir`, `--port`, `--nolaunch`), port 8090, and the bind address are UNVERIFIED: the upstream entry point was not fetched. Do not ship `start.sh` until these are checked against the code at v0.11.0.
- Metadata lookups (ComicVine, etc.) need user API keys in the UI, which is expected behaviour, not a blocker.
- Upgrades mean a new tarball and a new requirements install; the venv is built at image build time, so each upgrade is a new image.
- Not a blocker: no musl-only dependency, no GPU, no privileged need, arm64 not blocked (pure Python, wheels UNVERIFIED for every dep on arm64).

## 11. Build and test steps

```sh
cd apps/mylar
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name mylar-probe --read-only --tmpfs /tmp \
  -v mylar-probe-config:/config mylar:v0.11.0
docker logs -f mylar-probe
forgetool containers test --image mylar:v0.11.0 --config ./apps/mylar/container-test.yaml
docker rm -f mylar-probe; docker volume rm mylar-probe-config
```

Expected readiness signal: the CherryPy/Mylar startup banner and a listening line on port 8090 (exact text UNVERIFIED). Fail if the process exits, or if `unrar` is missing at runtime.

## 12. PR checklist

- Branch `feat/add-mylar`, commit and PR title `feat(mylar): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested, to state honestly: the image build on both architectures, runtime on `--read-only`, the port, probe path, CLI flags and bind address, the unrar licence, and the checksum gap.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
