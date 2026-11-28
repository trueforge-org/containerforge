# shelfmark — implementation plan
> Source: ./draft.md · Target: apps/shelfmark/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v1.7.0`, published 2026-11-13 (latest stable release). Draft's chart image tag is `ghcr.io/calibrain/shelfmark:v1.7.0`, same. Source: https://github.com/calibrain/shelfmark/releases/tag/v1.7.0 |
| Renovate | `// renovate: datasource=github-releases depName=calibrain/shelfmark versioning=semver` on `VERSION` (tag has a `v` prefix; strip it only where a path needs it) |
| License | MIT (GitHub SPDX `MIT`, repo not archived, pushed 2026-11-25) |
| Source URL | https://github.com/calibrain/shelfmark |
| Ready-made binary | None. The release has no assets. Interpreted app, so it is built from the source tree at the tag (`amd64`: yes, `arm64`: yes). |
| Checksum source | None published for the source tarball. Pin by tag `v1.7.0` (`https://github.com/calibrain/shelfmark/archive/refs/tags/v1.7.0.tar.gz`); UNVERIFIED that the tarball URL is served for this tag. |
| copy-from | `ghcr.io/calibrain/shelfmark:v1.7.0` is not used. It is a full upstream image with Chromium and a Python venv, so the source build is preferred. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/calibrain/shelfmark/main/Dockerfile (on `main`, not the tag; UNVERIFIED that the tag's Dockerfile is identical). Stages: `frontend-builder` (`node:24-alpine`, `npm ci`, `npm run build`), `uv` (`ghcr.io/astral-sh/uv:0.13.9`, mounted), `base` (`python:3.14.10-slim`, apt, user `shelfmark` UID/GID 1000, `uv sync --locked --no-default-groups`), `shelfmark` (full: Chromium, Xvfb, python3-tk, unrar-free, `uv sync --extra browser`, `python-xlib==0.33`), `shelfmark-lite` (`USING_EXTERNAL_BYPASSER=true`, no browser stack). |
| Port | `FLASK_PORT` default `8084` (EXPOSE and HEALTHCHECK use it). Health endpoint `GET /api/health`. |
| Env vars (README, https://github.com/calibrain/shelfmark/blob/main/README.md) | `FLASK_PORT` (8084), `INGEST_DIR` (`/books`), `PUID`/`PGID` (`1000`/`1000`; legacy `UID`/`GID`), `WIREGUARD_CONFIG` (`/config/wg0.conf`), `WIREGUARD_ALLOW_WEBUI_OFFTUNNEL` (`false`), `LOG_LEVEL` (`INFO`). Image ENV: `DOCKERMODE=true`, `PYTHONUNBUFFERED=1`, `PYTHONDONTWRITEBYTECODE=1`, `NAME=Shelfmark`. Full list: docs/environment-variables.md (UNVERIFIED: not read). |
| Data paths | `/config` (config, database, artwork cache), `/books` (downloads, `INGEST_DIR`), `/var/log/shelfmark` (created by upstream image). |
| Runs as | Upstream supports `user: "1000:1000"`. Default upstream flow starts as root and drops to PUID/PGID via `entrypoint.sh`. |
| Dependencies | None required. WireGuard, Tor and external bypasser are optional features. |

## 2. Target layout

Files in `apps/shelfmark/`:
- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required, wraps upstream `entrypoint.sh` only if it can run as `apps` (see section 9).
- `defaults/`: only if a default config must be seeded; reason: none known yet. UNVERIFIED.
- `app/`: not used. The build stage copies the app to `/app/shelfmark` directly (see section 4), which the `COPY . /` allow-list does not need.

Not applicable: `root/` (must not be touched). `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Build stage: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`. It has Python and Node for the frontend build. Upstream uses node 24 and Python 3.14.10, so see risk R1.
- Final stage: `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Closest sibling: `apps/bazarr` (python base, `/app` venv layout). Reason: Python backend, and the python base covers the runtime.
- Alternative if the python base cannot run the app: the ubuntu base `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` with `uv` installed from `ghcr.io/astral-sh/uv:0.13.9` (mount or copy). Only if a Python-base problem is shown.

## 4. Dockerfile

1. `ARG VERSION=` and `ARG TARGETARCH` in each stage; declare `VERSION` before the first `FROM` only if used in `FROM` (not used here).
2. Stage `frontend` `FROM <python-node>`: `ARG VERSION`, `USER root`. Fetch the tag tarball: `curl -fL -o /tmp/shelfmark.tar.gz https://github.com/calibrain/shelfmark/archive/refs/tags/v${VERSION#v}.tar.gz`, extract to `/tmp/src --strip-components=1`. `cd /tmp/src/src/frontend && npm ci --no-audit && npm run build`. Set `NPM_CONFIG_CACHE=/tmp/npm`. (The frontend path `src/frontend` is taken from upstream `COPY src/frontend`; UNVERIFIED for the tag.)
3. Stage `backend` (same base): `uv` binary via `COPY --from=ghcr.io/astral-sh/uv:0.13.9@sha256:d3b601f0c7b118bc1753febf7c41cc80981df678445e0254284eecf84db79a7d /uv /usr/local/bin/uv`. Copy `pyproject.toml uv.lock` and run `UV_LINK_MODE=copy UV_CACHE_DIR=/tmp/uv uv sync --locked --no-default-groups --extra browser` (browser extra only if the full variant is kept, see R2) into `/app/shelfmark/.venv`. Then remove the venv pip and set `python-xlib==0.33` the same way upstream does.
4. Apt (in the final stage, `USER root`): only what the base lacks. Upstream base packages: `dumb-init curl tzdata locales zip iputils-ping gosu tor supervisor iptables wireguard-tools iproute2 procps ca-certificates`. Check each against the python base before adding it; do NOT add packages the base already has. Pin any apt package by version and check it against `VERSION`. Full-variant only: `chromium xvfb python3-tk unrar-free` (see R2).
5. Copy application: `COPY --from=frontend /tmp/src/ /app/shelfmark/` for the source, then `COPY --from=frontend /tmp/src/<frontend build dir> /app/shelfmark/<frontend build dir>` (UNVERIFIED path), `COPY --from=backend /app/shelfmark/.venv /app/shelfmark/.venv`. Remove `/app/shelfmark/src` (upstream does this) to keep the image small.
6. License: `install -D /tmp/src/LICENSE /usr/share/licenses/shelfmark/LICENSE`.
7. `chown -R apps:apps /app/shelfmark` and `chmod -R 755 /app/shelfmark`. Env: `ENV PATH=/app/shelfmark/.venv/bin:$PATH PYTHONPATH=/app/shelfmark PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 PYTHONIOENCODING=UTF-8 FLASK_PORT=8084 INGEST_DIR=/books HOME=/config DOCKERMODE=true LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8`. Keep `HOME` as `/config` only if no cache writes go there (set `XDG_CACHE_HOME=/tmp`).
8. Create runtime dirs owned by apps: `mkdir -p /books /var/log/shelfmark` (`/books` is download data; mark it as a volume only if the chart expects it; see R4). `chown apps:apps /books /var/log/shelfmark`.
9. Tail: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8084`, `VOLUME /config`, `WORKDIR /app/shelfmark`.
10. ENTRYPOINT/CMD: `ENTRYPOINT` none; `start.sh` is the entrypoint, so CMD `["/start.sh"]`.

Version alignment: the Dockerfile `ARG VERSION` must equal the `docker-bake.hcl` default `v1.7.0`, passed as `1.7.0` where a path needs no `v`.

## 5. docker-bake.hcl

- `APP = "shelfmark"`, `VERSION = "v1.7.0"` with the renovate annotation (section 1), `LICENSE = "MIT"`, `SOURCE = "https://github.com/calibrain/shelfmark"`.
- Four standard targets plus `group "default" { targets = ["image-local"] }`, mirroring `apps/adguardhome-sync/docker-bake.hcl`.
- Validate with `cd apps/shelfmark && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/calibrain/shelfmark"
ports:
  - port: 8084
    protocol: tcp
    required: true
env:
  - name: FLASK_PORT
    default: "8084"
    required: false
  - name: INGEST_DIR
    default: "/books"
    required: false
  - name: LOG_LEVEL
    default: "INFO"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /books
    required: false
dependencies: []
```

Only variables the app reads are listed. `PUID`/`PGID` are left out: only upstream's root `entrypoint.sh` reads them and it is not used. `WIREGUARD_*` is left out until the WireGuard path is tested (R5).

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail` is not used by sibling apps; match `apps/adguardhome-sync/start.sh` style.
- Create `/config` subdirs only if missing: `mkdir -p /config/data`.
- Export `FLASK_PORT`, `INGEST_DIR`, `LOG_LEVEL` with defaults matching settings.yaml.
- `cd /app/shelfmark` and `exec /app/shelfmark/.venv/bin/python -m shelfmark` (UNVERIFIED: the module entry point; check `pyproject.toml` `[project.scripts]` or `entrypoint.sh` for the real command before writing).
- Writes only under `/config` and `/tmp`. Never write to `/app`.
- Bind address: the app must listen on `0.0.0.0` (UNVERIFIED default in the app; check and set explicitly if needed).
- Seed `/config` on first run only when missing. Do not overwrite existing files.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8084'
http:
- port: '8084'
  path: /api/health
filePaths:
- /app/shelfmark/.venv/bin/python
- /usr/share/licenses/shelfmark/LICENSE
```

- Every port in settings.yaml has a probe: `8084` has both `tcp` and `http`.
- `timeoutSeconds` is an estimate; compare with sibling `apps/bazarr` and adjust.
- No env vars are passed in tests, so the defaults in start.sh must be enough to start.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app` (upstream copies app there) | Read-only at runtime. Build-time only. |
| `/config` (config, DB, artwork cache) | Persistent volume, `VOLUME /config`. |
| `/books` (downloads) | `INGEST_DIR` default; optionally a volume. |
| `/var/log/shelfmark` | Created at build, owned by `apps`. If the app rotates logs there at runtime with `--read-only` it must be a tmpfs or `/config` path; UNVERIFIED which it uses. Remap to `/config/logs` via env if the app allows it. |
| uv / pip caches, `SeleniumBase` driver dir (full variant) | `/tmp`. Upstream makes the driver dir writable by UID 1000; set it under `/tmp` instead. |
| `entrypoint.sh` (upstream runs as root and drops to PUID/PGID) | Not used. The image runs as `apps` (UID 568), so `PUID`/`PGID` do not apply. Upstream's `gosu` and `tor` handling is only needed for the WireGuard/Tor features; see R5. |
| iptables legacy setting | Only needed for WireGuard; skip. |

## 10. Risks, caveats and open questions

- R1. Python version: upstream builds on `python:3.14.10-slim`, the python base here is 3.15.2. Check `requires-python` in `pyproject.toml` at v1.7.0 before choosing; if it caps at 3.14, use a 3.14 base (copy the FROM line from a sibling that pins 3.14, such as `apps/changedetection`).
- R2. Full vs lite image: the full variant needs Chromium, Xvfb and `python3-tk` (large image). Decide with the maintainer whether `shelfmark-lite` (external bypasser) is the first target. The draft flags this as unconfirmed.
- R3. Frontend build path inside the tarball and the output directory of `npm run build` are UNVERIFIED for v1.7.0.
- R4. The upstream Dockerfile is from `main`, not the tag. Confirm the tag's Dockerfile before building.
- R5. WireGuard and Tor are optional features that need `NET_ADMIN`-style capabilities and iptables. They are not in the rootless, read-only target. Exclude them from the first version and document as not supported.
- R6. Apt packages from the upstream base are not all in the python base; the list in section 4 must be checked package by package.
- R7. Download and indexer sources usually need configuration through the UI or API keys (draft, inferred).
- No arm64 release binary exists; arm64 is a source build and not yet tested.
- Blockers: none confirmed. Musl: no (glibc base).

## 11. Build and test steps

From `apps/shelfmark/`:
1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name shelfmark-probe --read-only --tmpfs /tmp -v shelfmark-probe-config:/config shelfmark:1.7.0` (local tag from the bake target `${APP}:${VERSION}`), then `docker logs -f shelfmark-probe`. Expected readiness signal: a line such as "Running on http://0.0.0.0:8084" (UNVERIFIED wording; set after the first run).
4. `forgetool containers test --image shelfmark:1.7.0 --config ./container-test.yaml`.
5. Cleanup: `docker rm -f shelfmark-probe; docker volume rm shelfmark-probe-config`.
6. arm64 only if amd64 fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-shelfmark`, commit `feat(shelfmark): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows status.
- Say what is not tested: arm64, full-variant browser path, WireGuard/Tor, and anything not built locally.
- Check `docker buildx bake --print` was run and passed.
