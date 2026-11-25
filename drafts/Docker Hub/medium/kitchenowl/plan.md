# kitchenowl — implementation plan
> Source: ./draft.md · Target: apps/kitchenowl/ (backend) and apps/kitchenowl-web/ (web) · Difficulty: medium · Role: sidecar (backend), main (web) · Verified on 2026-11-25

This draft has two images (chart rows 1 and 2). `AGENTS.md` requires one image per folder, so this plan covers two `apps/` folders. Each numbered section below has a backend part and a web part.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v0.8.1`, latest stable, published 2026-11-08 (https://github.com/TomBursch/kitchenowl/releases/tag/v0.8.1). Draft and chart both use `v0.8.1`. |
| Renovate | `datasource=github-releases depName=TomBursch/kitchenowl versioning=semver` (proposed for both folders; no renovate annotation found in the chart, UNVERIFIED). |
| License | AGPL-3.0 (root `LICENSE`, GNU AFFERO GPL v3: https://raw.githubusercontent.com/TomBursch/kitchenowl/v0.8.1/LICENSE). |
| Source URL | https://github.com/TomBursch/kitchenowl |
| Download, backend | Source tarball `https://github.com/TomBursch/kitchenowl/archive/refs/tags/v0.8.1.tar.gz` (confirmed on https://github.com/TomBursch/kitchenowl/releases/expanded_assets/v0.8.1). Arch-neutral. |
| Download, web | Prebuilt web bundle `https://github.com/TomBursch/kitchenowl/releases/download/v0.8.1/kitchenowl_Web.tar.gz` (confirmed on the same expanded assets page). Arch-neutral. `kitchenowl_Linux.tar.gz` exists but is not used. |
| Checksum source | None found for either asset. UNVERIFIED. Pin the tag over HTTPS and record the SHA-256 of each tarball in the PR. |
| Upstream Dockerfile, web | https://raw.githubusercontent.com/TomBursch/kitchenowl/v0.8.1/kitchenowl/Dockerfile. Builder `debian:latest` with Flutter stable, `flutter build web --release`. Runner `nginx/nginx-unprivileged:stable-alpine` (musl), copies `build/web` to `/var/www/web/kitchenowl`, non-root `nginx`, `ENV BACK_URL='back:5000'`, `EXPOSE 80`, healthcheck `curl http://localhost/`. How `BACK_URL` is consumed and the nginx config body were NOT fetched: UNVERIFIED. |
| Upstream Dockerfile, backend | https://raw.githubusercontent.com/TomBursch/kitchenowl/v0.8.1/backend/Dockerfile. Builder `python:3.14-slim` with build deps (gcc, cargo, libre2-dev and others), `pip install uv`, `uv sync --no-dev` into `/opt/venv`, downloads nltk `averaged_perceptron_tagger_eng`. Runner `python:3.14-slim`, user and group `kitchenowl` (uid/gid 1000), gosu, media-types, libicu-dev. `WORKDIR /usr/src/kitchenowl`, `VOLUME ["/data"]`, `ENV STORAGE_PATH='/data' JWT_SECRET_KEY='PLEASE_CHANGE_ME' DEBUG='False'`, `ENTRYPOINT ["./entrypoint.sh"]`, `CMD ["wsgi.ini", "--gevent", "200", "--max-fd", "1048576"]`, healthcheck `uwsgi_curl localhost:5000 /api/health/...` (full path UNVERIFIED). |
| Backend entrypoint | `entrypoint.sh` (body not fetched except the summary): when run as root, chowns `STORAGE_PATH` to `kitchenowl` and drops to it via gosu. Removes IPv6 from `wsgi.ini` if IPv6 is unavailable. UNVERIFIED in full. |
| Backend listen port | `backend/wsgi.ini` sets `http = [::]:8080` (https://raw.githubusercontent.com/TomBursch/kitchenowl/v0.8.1/backend/wsgi.ini). Chart service targets port 5000. Conflict, see section 10. |
| Ports | Web: 80 (upstream `EXPOSE`, chart `targetPort: 80`, service port 10246). Backend: chart `targetPort: 5000`, service port 10247, wsgi.ini says 8080. |
| Data / config paths | Backend: `STORAGE_PATH=/data` (upstream `VOLUME`), chart persistence `data` at `/data`. Web: nginx conf in an `emptyDir` at `/etc/nginx/conf.d` (chart). |
| Env vars (verified) | Backend: `STORAGE_PATH`, `JWT_SECRET_KEY` (default `PLEASE_CHANGE_ME`), `DEBUG` (default `False`). Web: `BACK_URL` (default `back:5000`, upstream). |
| arm64 | Yes for both: `tombursch/kitchenowl:v0.8.1` (index digest `6a048135...`, matches the chart) and `tombursch/kitchenowl-web:v0.8.1` have arm64 images. |
| copy-from | Web: no (alpine/musl runner, not usable on glibc Ubuntu). Backend: `tombursch/kitchenowl:v0.8.1` exists, but built on `python:3.14-slim` from source, not used. |
| Dependency containers | Draft says PostgreSQL (optional). Upstream backend does not appear to need it, and the chart `Chart.yaml` was not fetched. UNVERIFIED. `apps/postgresql` exists (✅). |

## 2. Target layout

Backend, `apps/kitchenowl/`:
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `start.sh`, `container-test.yaml`

Web, `apps/kitchenowl-web/`:
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `start.sh`, `container-test.yaml`
- `defaults/nginx.conf` and `defaults/default.conf` (or one equivalent file), copied to `/config` only when missing, following the `apps/nginx` pattern (`defaults/` plus `docker-entrypoint.d/03-copyconfig.sh`; the script itself was not read in detail)

No `root/`. `DOWNSTREAM_CHANGES.md` not needed for either: neither is a `FROM` base.

Folder names are a proposal: backend as `kitchenowl` (the data-bearing service), web as `kitchenowl-web`. Confirm before writing.

## 3. Base image

Backend: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Closest sibling: `apps/bazarr` (Python app, pip or uv installs into the base venv, `USER apps`).

Python version gap: upstream backend builds on Python 3.14, and the base here is 3.15.2. Compatibility of kitchenowl v0.8.1 with 3.15 is UNVERIFIED. Two options:
- A: use the 3.15.2 base. Test the backend on it. Record the result.
- B: use `ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e44439ea272f47b46a1511960f58af5df8056811c83973e2edec9b18afca`, the pin `apps/changedetection` uses to stay on 3.14. The node part is unused, but the base is the only 3.14 ContainerForge base with a verified digest.
Pick A first. Fall back to B only if the backend fails on 3.15.

Web: `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f` (same as `apps/it-tools` and `apps/nginx`). It replaces upstream `nginx-unprivileged:stable-alpine`, because the musl build cannot be copied to Ubuntu.

## 4. Dockerfile

### Backend (`apps/kitchenowl/Dockerfile`)

1. `ARG VERSION`, `USER root`. Install only what the base lacks. Build dependencies (gcc, cargo, libre2-dev and others, UNVERIFIED exact names from the upstream builder) go in the build step and are purged after `uv sync`. Keep `libicu-dev` (runtime, upstream) only if the import needs it.
2. Fetch and unpack the source:

```dockerfile
RUN set -eux; \
  mkdir -p /app/kitchenowl; \
  curl -fsSL "https://github.com/TomBursch/kitchenowl/archive/refs/tags/v${VERSION}.tar.gz" \
    | tar xz -C /app/kitchenowl --strip-components=1
```

3. Install Python dependencies into the bundled venv with uv, then remove uv. Bazarr's pattern (`pip install uv`, then `pip uninstall --yes uv`):

```dockerfile
RUN set -eux; \
  pip install uv; \
  cd /app/kitchenowl/backend; \
  UV_PROJECT_ENVIRONMENT=/app/venv uv sync --no-dev; \
  pip uninstall --yes uv
```

`UV_PROJECT_ENVIRONMENT` is the uv setting that targets an existing environment. The base sets `UV_SYSTEM_PYTHON=true`, which may interact with `uv sync`. UNVERIFIED until the build runs.

4. nltk data (upstream downloads `averaged_perceptron_tagger_eng`). Download at build time into a path under `/app`, not at runtime. The destination path is UNVERIFIED (upstream backend Dockerfile not read in full).
5. Permissions and licence: `chown -R apps:apps /app && chmod -R 755 /app`, copy `LICENSE` to `/usr/share/licenses/kitchenowl/LICENSE`, `rm -rf /tmp/* /root/.cache`.
6. Tail:

```dockerfile
ENV STORAGE_PATH=/config/data \
    DEBUG=False

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app/kitchenowl/backend
```

`STORAGE_PATH` is remapped from upstream `/data` to `/config/data` (persistent). `JWT_SECRET_KEY` is not set in the image; `start.sh` generates it (section 7).

### Web (`apps/kitchenowl-web/Dockerfile`)

```dockerfile
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f

ARG VERSION
USER root

RUN set -eux; \
  mkdir -p /usr/share/nginx/html/kitchenowl; \
  curl -fsSL -o /tmp/kitchenowl_web.tar.gz \
    "https://github.com/TomBursch/kitchenowl/releases/download/v${VERSION}/kitchenowl_Web.tar.gz"; \
  tar xzf /tmp/kitchenowl_web.tar.gz -C /usr/share/nginx/html/kitchenowl; \
  chown -R apps:apps /usr/share/nginx/html; chmod -R 755 /usr/share/nginx/html; \
  rm -rf /tmp/*
```

- The layout of `kitchenowl_Web.tar.gz` (files at the archive root, or under `build/web`) is UNVERIFIED. Run `tar tzf` on the download and fix the `-C` target.
- No Flutter build is needed (prebuilt bundle, arch-neutral).
- The nginx config is shipped in `defaults/` and copied to `/config` only when missing. It must proxy the backend API paths to `BACK_URL`. The list of proxied paths is UNVERIFIED because the upstream nginx config body was not fetched.

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
```

Port 8080 is used instead of upstream 80: non-root cannot bind a port below 1024. The chart service maps 80 to the container, so the chart needs a targetPort change. That is chart-side, not part of this PR.

## 5. docker-bake.hcl

Backend (`apps/kitchenowl/docker-bake.hcl`):

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "kitchenowl"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=TomBursch/kitchenowl versioning=semver
  default = "0.8.1"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/TomBursch/kitchenowl"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Web (`apps/kitchenowl-web/docker-bake.hcl`): the same file with `APP` = `kitchenowl-web`. Keep `VERSION` = `0.8.1` and the same renovate line. Validate both with `docker buildx bake --print`.

## 6. settings.yaml

Backend (`apps/kitchenowl/settings.yaml`):

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/TomBursch/kitchenowl"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: STORAGE_PATH
    default: "/config/data"
    required: false
  - name: DEBUG
    default: "False"
    required: false
  - name: JWT_SECRET_KEY
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `JWT_SECRET_KEY` is `required: false` with an empty default because `start.sh` generates it on first start (a `required: true` var must have a default or be handled by `start.sh`; this one is handled).
- Port 8080 follows `backend/wsgi.ini`. See section 10.
- No `dependencies` or `opt_dependencies` entry until the upstream need for PostgreSQL is confirmed.

Web (`apps/kitchenowl-web/settings.yaml`):

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/TomBursch/kitchenowl"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: BACK_URL
    default: "kitchenowl:8080"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- `BACK_URL` default follows the backend port decision. The host name `kitchenowl` is the proposed ContainerForge name of the backend container, not verified. The upstream default is `back:5000`.
- Whether nginx reads `BACK_URL` through a template, `envsubst`, or a fixed file is UNVERIFIED. The `start.sh` step must match it.

## 7. start.sh

Backend (`apps/kitchenowl/start.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data

secret_file=/config/jwt_secret_key
if [ -z "${JWT_SECRET_KEY:-}" ] || [ "${JWT_SECRET_KEY}" = "PLEASE_CHANGE_ME" ]; then
  if [ ! -s "${secret_file}" ]; then
    head -c 48 /dev/urandom | base64 > "${secret_file}"
    chmod 600 "${secret_file}"
  fi
  JWT_SECRET_KEY="$(cat "${secret_file}")"
fi
export JWT_SECRET_KEY
export STORAGE_PATH="${STORAGE_PATH:-/config/data}"
export DEBUG="${DEBUG:-False}"

cd /app/kitchenowl/backend
exec /app/venv/bin/uwsgi wsgi.ini --gevent 200 --max-fd 1048576
```

- The secret file is seeded only when missing. It is generated once and kept in `/config`, so a restart keeps the same key.
- The `uwsgi` path and the arguments come from the upstream `CMD`. The upstream entrypoint body (which also removes the IPv6 bind when IPv6 is unavailable) was not fetched. UNVERIFIED. Copy that behaviour if the container has no IPv6.
- `exec` for signal handling.
- No writes to `/app`. uwsgi pid or log files, if any, go to `/tmp`. UNVERIFIED which.

Web (`apps/kitchenowl-web/start.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail

export BACK_URL="${BACK_URL:-kitchenowl:8080}"

# render the config from the defaults and BACK_URL here, only when missing
# (exact render method depends on the upstream nginx config, UNVERIFIED)

exec nginx -c /config/nginx.conf -g "daemon off;"
```

- Config seeding and `BACK_URL` substitution follow the rules above. Do not overwrite an existing `/config/nginx.conf`.
- nginx temp paths go to `/tmp` (the base already sets `/tmp/nginx-temp` and `/tmp/nginx-cache` in `apps/nginx`).

## 8. container-test.yaml

Backend (`apps/kitchenowl/container-test.yaml`):

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
filePaths:
- /app/kitchenowl/backend/wsgi.ini
```

- One `tcp` probe for the backend port (8080). An `http` probe on the health path needs the full path first (`/api/health/...` is truncated in the upstream healthcheck, UNVERIFIED). Add it once confirmed.
- No DB dependency, so the narrowed DB exception does not apply.

Web (`apps/kitchenowl-web/container-test.yaml`):

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /
filePaths:
- /usr/share/nginx/html/kitchenowl/index.html
```

- The `index.html` path is UNVERIFIED until `tar tzf` shows the layout.
- The web container must start without the backend. If the nginx config resolves a fixed upstream host at start, nginx fails with no backend present. See section 10. Keep the test passing without a backend, or narrow it per the protocol with the required comment only if the criteria hold (they do not hold here: web has no hard dependency).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Backend `STORAGE_PATH=/data` (chart PVC `data`) | `/config/data`, set in `start.sh` and the Dockerfile. |
| Backend entrypoint chowns `/data` to uid 1000 when run as root | Not needed: the image runs as `apps`, and `/config` is the writable volume. |
| Backend secret | `/config/jwt_secret_key`, seeded once. |
| Backend caches, uwsgi scratch | `/tmp`. UNVERIFIED which paths uwsgi writes. |
| Web nginx conf (chart `emptyDir` at `/etc/nginx/conf.d`) | `/config/nginx.conf` (base CMD), seeded from `defaults/`. |
| Web nginx temp and cache | `/tmp/nginx-temp`, `/tmp/nginx-cache` (as `apps/nginx`). |

Draft expectations reconciled:
- Chart `runAsUser` default 568 applies to both. The images run as `apps`, which fits.
- Chart `readOnlyRootFilesystem` true (default). Both images need `--read-only --tmpfs /tmp`, and the plan writes only to `/config` and `/tmp`.
- Not privileged. Extra persistence: `/data` (backend) is `/config/data` in this image. Existing chart users must move their `/data` content to `/config/data`.

## 10. Risks, caveats and open questions

- Backend port conflict (blocker until checked): chart targets 5000, `wsgi.ini` binds 8080. The CMD uses `wsgi.ini`, so 8080 is the likely port. Confirm with `ss -ltn` in a real run. Settings and tests must match the real port. The chart mapping is wrong for this image, and the chart fix is out of scope here.
- IPv6 bind: `wsgi.ini` binds `[::]`. If IPv6 is missing in the container, the upstream entrypoint removes it. Copy that step. Test from outside the container for the bind address.
- Web nginx config (blocker): the upstream config body and the way `BACK_URL` is used were not fetched. Without them, the proxy paths and render step in `start.sh` are unknown.
- Web nginx upstream host at start: a fixed `proxy_pass` host is resolved when nginx loads config. If the backend is not up, nginx fails. Use a resolver with a variable `proxy_pass`, or keep the test independent of the backend. Decide after reading the config.
- Port 80 vs 8080 for the web image: the upstream exposes 80, the ContainerForge rootless image uses 8080. The chart needs a targetPort change (out of scope).
- Python 3.15 vs upstream 3.14 for the backend (section 3). Option A first.
- Web bundle layout (`kitchenowl_Web.tar.gz`) UNVERIFIED (section 4).
- Checksums: none found for either asset.
- Database: draft says PostgreSQL is optional. Upstream does not appear to need it. The chart `Chart.yaml` was not checked. If the backend needs PostgreSQL to start, it is a blocker and the DB exception applies only if all three criteria hold.
- Backup: the backend stores data under `STORAGE_PATH`; the PR should say that `/config` must be backed up (inferred).
- Blockers: backend port (confirm), web config (read), and DB start (confirm). No musl-only blocker for the backend. The web image is rebuilt on the ContainerForge nginx base, so the musl issue does not apply.

## 11. Build and test steps

Backend:

```sh
cd apps/kitchenowl
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name kitchenowl-probe --read-only --tmpfs /tmp \
  -p 8080:8080 -v kitchenowl-probe-config:/config kitchenowl:0.8.1
docker logs -f kitchenowl-probe
docker exec kitchenowl-probe ss -ltn
docker rm -f kitchenowl-probe; docker volume rm kitchenowl-probe-config

forgetool containers test --image kitchenowl:0.8.1 --config ./apps/kitchenowl/container-test.yaml
```

Web:

```sh
cd apps/kitchenowl-web
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name kitchenowl-web-probe --read-only --tmpfs /tmp \
  -p 8081:8080 -v kitchenowl-web-probe-config:/config kitchenowl-web:0.8.1
docker logs -f kitchenowl-web-probe
curl -sS -o /dev/null -w '%{http_code}\n' http://localhost:8081/
docker rm -f kitchenowl-web-probe; docker volume rm kitchenowl-web-probe-config

forgetool containers test --image kitchenowl-web:0.8.1 --config ./apps/kitchenowl-web/container-test.yaml
```

Readiness signals (expected, UNVERIFIED until a run): backend logs show uwsgi listening on 8080 and the process stays up. Web nginx logs show it started with no `emerg` error. Confirm the backend binds on `0.0.0.0` or `[::]` from another container. Empty `/config` must start both images, and a restart must keep `/config/data` and `/config/jwt_secret_key`.

## 12. PR checklist

- One PR per app, because one image per folder (`AGENTS.md`): branch `feat/add-kitchenowl` with commit `feat(kitchenowl): add new container`, and branch `feat/add-kitchenowl-web` with commit `feat(kitchenowl-web): add new container`. Target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Confirm `docker buildx bake --print` passes for both folders, and `VERSION` (`0.8.1`) equals `ARG VERSION` in each Dockerfile.
- Untested to state honestly in the PR: the backend port, the web nginx config and `BACK_URL` behaviour, the Python 3.15 backend, the IPv6 bind, the nltk data path, the bundle layout, read-only runtime, arm64, and checksums (none published).
