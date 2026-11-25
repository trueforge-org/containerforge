# tandoor-recipes — implementation plan
> Source: ./draft.md · Target: apps/tandoor-recipes/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest GitHub release 2.7.8, published 2026-11-24 (https://api.github.com/repos/TandoorRecipes/recipes/releases/latest). Chart pins 2.7.6 (published 2026-11-18, commit `89c07f26bb168221e41d409224976960cf344289`). Plan targets 2.7.8 unless the user wants the chart version. |
| Renovate | `datasource=github-releases depName=TandoorRecipes/recipes versioning=semver`. Tags have no `v` prefix. |
| License | GitHub API reports `NOASSERTION` (https://api.github.com/repos/TandoorRecipes/recipes). SPDX **UNVERIFIED**; the repo LICENSE was not fetched. Blocker: confirm before filling `LICENSE`. |
| Source URL | https://github.com/TandoorRecipes/recipes |
| Download | No release assets (the release lists none). Build from `https://github.com/TandoorRecipes/recipes/archive/refs/tags/${VERSION}.tar.gz`. The tag's commit SHA is the pin (2.7.6 = `89c07f26bb168221e41d409224976960cf344289`; 2.7.8 SHA UNVERIFIED). |
| Checksum source | None published. Pin by tag and record the commit SHA in the PR. |
| Upstream Dockerfile reviewed | https://github.com/TandoorRecipes/recipes/blob/89c07f26bb168221e41d409224976960cf344289/Dockerfile (via gh api). `FROM python:3.14-alpine3.24` (musl, so `copy-from` is `no`). Single stage. apk runtime: `postgresql-libs postgresql-client gettext zlib libjpeg libwebp libxml2-dev libxslt-dev openldap git libgcc libstdc++ nginx tini envsubst nodejs npm`. Build deps are purged after pip. Venv at `/opt/recipes/venv`, `pip install -r requirements.txt` (dev section stripped with `sed`), pinned `wheel==0.48.0` and `setuptools_rust==1.13.0`. `ENV PYTHONUNBUFFERED=1 DOCKER=true`, `EXPOSE 80 8080`, nginx config moved to `/opt/recipes/http.d` (chmod 1777), nginx logs to stdout/stderr, `ENTRYPOINT ["/sbin/tini","--","/opt/recipes/boot.sh"]`, no USER (root), no VOLUME, HEALTHCHECK commented out upstream. `version.py` run, then `.git` dirs removed. |
| Node frontend | Upstream installs node and npm but runs no build in this Dockerfile. How the Vue frontend gets built is UNVERIFIED (check the repo's build scripts or shipped static files before the port). |
| boot.sh | Not fetched. It templates the nginx config and starts gunicorn. Its env names and paths are UNVERIFIED. |
| Ports | Upstream EXPOSE 80 (nginx) and 8080 (gunicorn, per the upstream comment). The plan uses 8080 as the public port; nginx on 80 needs a root bind, so the rootless port must be changed. |
| Media and static paths | Draft says `/opt/recipes/mediafiles` and `/opt/recipes/staticfiles`. Not confirmed by the Dockerfile; settings or boot.sh decide them (UNVERIFIED). |
| Secret key | Draft says Django needs `SECRET_KEY` before first start (UNVERIFIED on docs.tandoor.dev, not fetched). |
| Docs | https://docs.tandoor.dev/ not fetched. |

## 2. Target layout

- `apps/tandoor-recipes/Dockerfile`
- `apps/tandoor-recipes/docker-bake.hcl`
- `apps/tandoor-recipes/settings.yaml`
- `apps/tandoor-recipes/container-test.yaml`
- `apps/tandoor-recipes/start.sh` (replaces upstream `boot.sh` for the rootless parts)
- `apps/tandoor-recipes/defaults/` for the nginx template and gunicorn config, if they must ship read-only (decide in section 7)

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Upstream's Python 3.14 is Alpine; ContainerForge's python base is glibc on ubuntu, so the app builds against it. Python 3.15 is a deviation to note (check `requirements.txt` wheels for 3.15 first, UNVERIFIED).
- Closest siblings: `apps/bazarr` (python app), `apps/changedetection` (python-node, nginx-adjacent), `apps/nextcloud-fpm` (nginx/fpm split).
- nginx: apt on the python base (or on ubuntu if the base lacks it; check first).

## 4. Dockerfile

1. `ARG VERSION` (tag, for example `2.7.8`, no `v`) and `ARG TARGETARCH`. Default matches `docker-bake.hcl`.
2. Build stage `FROM <python base> AS build`, `USER root`: install build deps for the Python wheels (`gcc`, `libpq-dev`, `libjpeg-dev`, `zlib1g-dev`, `libxml2-dev`, `libxslt1-dev`, `libldap2-dev`, `libsasl2-dev`, `libffi-dev`, `libssl-dev`, `libwebp-dev` and so on, check each against the upstream requirements; UNVERIFIED list).
3. `curl -fsSL https://github.com/TandoorRecipes/recipes/archive/refs/tags/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`.
4. Venv in `/tmp/venv`, not `/app`: `python -m venv /tmp/venv`, then `pip install --no-cache-dir wheel==0.48.0 setuptools_rust==1.13.0` and `pip install --no-cache-dir -r requirements.txt` (strip the `# Development` section as upstream does). Pip cache and build scratch go to `/tmp` (`PIP_CACHE_DIR=/tmp/pip`).
5. Frontend: run the upstream frontend build if the source requires it (UNVERIFIED steps; do not guess). Copy the built static files into the image tree.
6. Runtime stage, `USER root` for installs: `apt-get install -y --no-install-recommends nginx libpq5 tini gettext-base` (versions not pinned; check `VERSION` alignment is not applicable to apt). Use the base's own Python. Copy `/tmp/venv` to `/app/venv` (read-only at runtime, owned by root). Remove the default nginx config and point nginx at the templated config under `/tmp` (see section 9).
7. License: `install -Dm644 LICENSE /usr/share/licenses/tandoor-recipes/LICENSE` (after confirmation).
8. `ENV PYTHONUNBUFFERED=1 DOCKER=true`, `EXPOSE 8080`, `VOLUME ["/config"]`, `WORKDIR /app`.
9. `ENTRYPOINT ["/usr/bin/tini","--","/app/start.sh"]` or the `start.sh` from this app, with `COPY --chmod=0755 . /` before it.
10. `USER apps`, `COPY --chmod=0755 . /` as the last copy.

Note: the upstream `chmod 1777` on `/opt/recipes/http.d` (so the non-root user can write templated nginx config) is not needed if the template goes to `/tmp`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "tandoor-recipes"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=TandoorRecipes/recipes versioning=semver
  default = "2.7.8"
}

variable "LICENSE" {
  default = "UNVERIFIED"   // set to the SPDX id once confirmed
}

variable "SOURCE" {
  default = "https://github.com/TandoorRecipes/recipes"
}
```

Then the default group (`image-local`), `image`, `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`). `docker buildx bake --print` before any build. The LICENSE placeholder must not ship.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/TandoorRecipes/recipes"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: SECRET_KEY
    default: ""
    required: true
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - postgresql
```

- `SECRET_KEY` is `required: true` with no default, so `start.sh` must generate one on first run, store it in `/config`, and read it on later starts (start-script rule: required env with no default must be handled on first run). The generated value goes in `/config`, not the process list.
- Only env names upstream really reads belong here. `DATABASE_URL`-style names are UNVERIFIED; add them only after checking settings in the repo.
- `opt_dependencies: postgresql` because upstream recommends Postgres while SQLite works for one user (draft, UNVERIFIED on docs). `apps/postgresql` exists (✅).

## 7. start.sh

- `#!/bin/sh`, `set -eu`. Create `/config` and the media directory under `/config` (for example `/config/mediafiles`, if the app's `MEDIA_ROOT`-style setting is confirmed; UNVERIFIED).
- First start: if `/config/secret_key` is missing or empty, generate one with `python -c 'import secrets; print(secrets.token_urlsafe(50))'` and write it to `/config`. On later starts, read it. If `SECRET_KEY` is set in the env, prefer it.
- Render the nginx config (`envsubst`) into `/tmp/nginx/`, not `/app`. Point nginx at `/tmp/nginx` and its logs at stdout and stderr.
- Run migrations on each start (`python manage.py migrate`, UNVERIFIED that boot.sh does this) with `DJANGO_SETTINGS_MODULE` as upstream sets it. Migrations write to the DB, not the rootfs.
- Start gunicorn in the background on 127.0.0.1:8080 (or 0.0.0.0 if the probe needs it), then start nginx in the foreground, or `exec` a supervisor. Choose one; `exec` is preferred for signals (UNVERIFIED which process model boot.sh uses).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /openapi
```

- `/openapi` is the path in the upstream commented-out HEALTHCHECK (`/openapi` on 8080), so it is a real readiness probe, not a placeholder.
- `timeoutSeconds`: the first run applies migrations and is slow (draft). Match a slow python sibling such as `apps/bazarr` and measure in section 11.
- The test runs with no env vars, so `SECRET_KEY` is generated by `start.sh` on first run and the probe still works. Any path that needs a Postgres connection goes to `filePaths`.
- DB dependency narrowing: this app meets the protocol's criteria only if the app fails without a DB. Check first; if it does, add the required comment near the narrowed assertion (`# narrowed: requires external postgresql; full functional test not feasible in single-container suite`).

## 9. Rootless and read-only-rootfs adaptations

| Upstream behavior | ContainerForge handling |
| --- | --- |
| Runs as root (no USER) | Runs as `apps`. |
| nginx listens on 80 (EXPOSE 80) | Bind to 8080 (or a high port) in the rendered config. Port 80 needs root. |
| `/opt/recipes/http.d` world-writable (chmod 1777) | Not needed: config is rendered to `/tmp/nginx`, so no world-writable dir. |
| nginx logs to `/dev/stdout`, `/dev/stderr` | Same (works on read-only rootfs). |
| Templating in `boot.sh` | `envsubst` in `start.sh`, output to `/tmp`. |
| `version.py` git info | Build-time only. Remove `.git` before the image copy (as upstream does). |
| `SECRET_KEY`, media, static, sqlite | Under `/config` (persistent). Static collected at build time or to `/tmp` if the app writes it (UNVERIFIED). |
| Draft's `/opt/recipes/mediafiles` and `/opt/recipes/staticfiles` | Remap to `/config/mediafiles` and `/tmp/staticfiles` respectively, once the app's settings confirm the env names. |

Security expectations from the draft (root, rootfs writable) are TrueCharts defaults and are **not** adopted. Target is `--read-only --tmpfs /tmp` with an empty `/config`.

## 10. Risks, caveats and open questions

- **Blocker, frontend:** the Vue frontend build path is UNVERIFIED. The Dockerfile has no build step, so the port may need a separate build stage. Do not ship without knowing where the static files come from.
- **Blocker, boot.sh:** not fetched. The rootless port depends on its env names, template paths and process model. Fetch it (`gh api`) before writing `start.sh`.
- **Blocker, license:** NOASSERTION from the API.
- **Python version:** upstream 3.14 Alpine; ContainerForge python 3.15.2. Check wheels for `requirements.txt` on 3.15.
- **Postgres:** upstream recommends it; SQLite default for single user (draft, UNVERIFIED).
- **Version drift:** chart pins 2.7.6, latest is 2.7.8. Chart's extra persistence paths must be remapped.
- **Draft claims** (SECRET_KEY, migrations on first start, Vue build): kept as UNVERIFIED until the docs or boot.sh confirm them.

## 11. Build and test steps

Run from `apps/tandoor-recipes/`, per `.github/instructions/build-test-protocol.instructions.md`.

1. `docker buildx bake --print` (exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker volume create tandoor-probe-config`, then `docker run --rm -d --name tandoor-probe --read-only --tmpfs /tmp -v tandoor-probe-config:/config tandoor-recipes:2.7.8`. Readiness: process stays up, port 8080 open, `/openapi` returns 200, and a gunicorn "Booting worker" line (UNVERIFIED wording, read the first real log).
4. `forgetool containers test --image tandoor-recipes:2.7.8 --config ./container-test.yaml`.
5. Cleanup: `docker rm -f tandoor-probe; docker volume rm tandoor-probe-config`.

Expected: image builds, migrations run, `/openapi` answers 200. Anything else is UNVERIFIED until the first run.

## 12. PR checklist

- Branch `feat/add-tandoor-recipes`; commit `feat(tandoor-recipes): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only the boxes that apply.
- Notes: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State what was not built or run. Do not check "Built container locally" unless it was.
- List the python version choice, frontend source, boot.sh and license as open questions in the PR.
