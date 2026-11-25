# dispatcharr — implementation plan
> Source: ./draft.md · Target: apps/dispatcharr/ · Difficulty: hard · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Chart pins `ghcr.io/dispatcharr/dispatcharr:0.34.1`. GitHub release `v0.34.1` published 2026-11-17, not a prerelease, and has **zero assets** (no prebuilt binary). Source: https://api.github.com/repos/Dispatcharr/Dispatcharr/releases/tags/v0.34.1 |
| Renovate | `datasource=github-releases depName=Dispatcharr/Dispatcharr versioning=semver` (proposed; release tags are semver-like) |
| License | AGPL-3.0 (GitHub license API, `repos/Dispatcharr/Dispatcharr/license`) |
| Source URL | https://github.com/Dispatcharr/Dispatcharr |
| Per-arch download | None. No release assets. Upstream builds the image from source (`docker/Dockerfile`). |
| Checksum source | None (no assets). Pin by git tag/commit instead. |
| Upstream Dockerfile reviewed | `docker/Dockerfile` on `main` (https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/main/docker/Dockerfile). The draft's pinned commit `83f82bf` could **not** be fetched; `UNVERIFIED: pinned-commit content may differ from main`. |
| Upstream Dockerfile summary | Stage 1 `FROM node:24 AS frontend-builder`: `npm install` and `npm run build` in `/app/frontend`. Stage 2 `FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}:${BASE_TAG} AS final` (defaults `dispatcharr/dispatcharr:base`). `WORKDIR /app`, `COPY . /app`, nginx config to `/etc/nginx/sites-enabled/default`, CRLF fix and chmod on `docker/entrypoint*.sh`, `dist` copied in, optional `TIMESTAMP` sed on `/app/version.py`. `ENV VIRTUAL_ENV=/dispatcharrpy`, `ENTRYPOINT ["/app/docker/entrypoint.sh"]`. No EXPOSE, VOLUME, USER or CMD. |
| Base image | `ghcr.io/dispatcharr/dispatcharr:base` is a **project-owned image** that does not exist in this repo. `UNVERIFIED: whether the base tag is published and what it contains` (python venv at `/dispatcharrpy`, nginx, redis, celery, supervisor, ffmpeg). |
| apt / pip in this Dockerfile | None. Everything else comes from the base or from `docker/entrypoint.sh`, which was **not read** (`UNVERIFIED`). |
| Ports | Compose `docker/docker-compose.aio.yml` (main): `9191:9191`, env `DISPATCHARR_PORT` default 9191 (nginx listens on it). Source: `gh api repos/Dispatcharr/Dispatcharr/contents/docker/docker-compose.aio.yml?ref=main` |
| Volumes / data | Compose mounts `dispatcharr_data:/data`. Upstream Dockerfile declares no VOLUME. |
| Env vars (real, from compose) | `DISPATCHARR_ENV=aio`, `REDIS_HOST=localhost`, `CELERY_BROKER_URL=redis://localhost:6379/0`, `DISPATCHARR_LOG_LEVEL=info`, `DISPATCHARR_PORT`, `DISPATCHARR_SETUP_ALLOWED_IP`, `DISPATCHARR_TRUSTED_PROXIES`, `REDIS_IDLE_TIMEOUT`, `REDIS_MAX_CONNECTIONS`, `UWSGI_WORKERS`, `UWSGI_NICE_LEVEL`, `CELERY_MAX_WORKERS`, `CELERY_MIN_WORKERS`, `CELERY_NICE_LEVEL`, `DISPATCHARR_NOFILE`, `USE_LEGACY_NUMPY`. |
| arm64 | `UNVERIFIED`: no manifest was checked. The source-build path makes arm64 plausible, but the base image's arch support is unknown. |
| Docs | https://dispatcharr.github.io/Dispatcharr-Docs not fetched. `UNVERIFIED`. |
| Dependencies | Redis and Celery run **inside** the aio container (`REDIS_HOST=localhost`). No external DB in the compose file. The chart's `alpine` companion (`alpineImage`) is not a runtime dependency of the app itself. |

## 2. Target layout

- `apps/dispatcharr/Dockerfile`
- `apps/dispatcharr/docker-bake.hcl`
- `apps/dispatcharr/settings.yaml`
- `apps/dispatcharr/container-test.yaml`
- `apps/dispatcharr/start.sh` (only if the upstream entrypoint cannot be reused as-is; see section 7)
- `defaults/` or `etc/` for the nginx config only if needed. Reason: the upstream nginx config is copied in the upstream Dockerfile, so we will copy it to `etc/nginx/sites-enabled/default` via the allow-listed `etc/` path.

No `root/`. `DOWNSTREAM_CHANGES.md` is not needed unless this image becomes a `FROM` base.

## 3. Base image

**Blocked for now.** The natural base is `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (Python plus Node, matching the upstream node build stage and python runtime). But the upstream runtime is `ghcr.io/dispatcharr/dispatcharr:base`, which contains the Python venv, nginx, redis and celery.

Two options:
1. **Preferred if the upstream base is reproducible:** rebuild the upstream `base` stage on the ContainerForge `ubuntu` base (`ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`), then add the app layer. Requires reading the upstream base Dockerfile first (`UNVERIFIED: not in this repo or fetched`).
2. **Fallback:** `python-node` as the final stage, and add nginx, redis-server, ffmpeg and supervisor via apt in the final stage, with a `start.sh` that starts them.

Closest sibling: `apps/bazarr` (Python), `apps/changedetection` (python-node + supervisor-like start), `apps/nginx` (nginx). Decide after the upstream base is read.

## 4. Dockerfile

Only after option 1 or 2 in section 3 is chosen:

1. Build stage `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS frontend` (`USER root`). Copy the frontend source from the upstream repo at pinned `ARG VERSION`, run `npm ci` (or `npm install --no-audit --progress=false` as upstream), `npm run build`, delete `node_modules` and `.cache`. Build artifacts live in `/tmp`.
2. Runtime stage on the chosen base. `ARG VERSION` must match `docker-bake.hcl`.
3. `apt-get install -y --no-install-recommends ffmpeg nginx redis-server supervisor` only for packages the chosen base lacks. Pin the apt packages where they come from apt and check against `VERSION` (version alignment rule).
4. Source: `curl -fL https://github.com/Dispatcharr/Dispatcharr/archive/refs/tags/${VERSION}.tar.gz | tar xz -C /app --strip-components=1`, verified by pinned tag.
5. `COPY --from=frontend /tmp/...dist /app/frontend/dist`.
6. nginx config: `COPY etc/nginx/sites-enabled/default` (or inline). Redirect nginx state to `/tmp` (`/var/lib/nginx`, `/var/log/nginx` as needed) so `/app` stays read-only.
7. License: `COPY LICENSE /usr/share/licenses/dispatcharr/LICENSE`.
8. ENV: `VIRTUAL_ENV=/dispatcharrpy`, `PATH=$VIRTUAL_ENV/bin:$PATH`, `XDG_CACHE_HOME=/tmp/.cache`, `PIP_CACHE_DIR=/tmp/pip`, `HOME=/config`.
9. `VOLUME /config`, `EXPOSE 9191`.
10. Final: `COPY --chmod=0755 . /`, `USER apps`.

Note: the upstream image runs as the base's default user. Do not run as root in the final stage.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "dispatcharr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Dispatcharr/Dispatcharr versioning=semver
  default = "0.34.1"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/Dispatcharr/Dispatcharr"
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
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Validate with `docker buildx bake --print` from `apps/dispatcharr/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Dispatcharr/Dispatcharr"
ports:
  - port: 9191
    protocol: tcp
    required: true
env:
  - name: DISPATCHARR_PORT
    default: "9191"
    required: false
  - name: DISPATCHARR_ENV
    default: "aio"
    required: false
  - name: DISPATCHARR_LOG_LEVEL
    default: "info"
    required: false
volumes:
  - path: /config
    required: true
  - path: /data
    required: false
dependencies: []
```

Only env vars the app really reads are listed. The defaults match the compose file. Other compose variables are optional and can be added once `entrypoint.sh` is read. `/data` is listed only if the upstream entrypoint writes there and `/config` cannot be mapped to it (see section 9).

## 7. start.sh

Only if the upstream entrypoint cannot be used as-is. Plan:

1. Read `docker/entrypoint.sh` upstream (`UNVERIFIED`, not yet read).
2. Map upstream state paths (`/data`, `/app/data`, logs) to `/config` via symlink or env var, and create them on first start only (`mkdir -p /config/...`).
3. Start redis on `localhost:6379` (`redis-server --dir /tmp`), nginx on `DISPATCHARR_PORT` with `/tmp` state, celery and uwsgi through the upstream supervisor config.
4. Bind all interfaces (`0.0.0.0`) for nginx.
5. Final `exec` of the supervisor process so signals reach PID 1.

No writes to `/app`. All caches in `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '9191'
http:
- port: '9191'
  path: /
filePaths:
- /app/manage.py
- /app/docker/entrypoint.sh
- /usr/share/licenses/dispatcharr/LICENSE
```

Every settings.yaml port has a tcp probe. Use the http path that returns 200 without setup (`UNVERIFIED`; may redirect to the setup page). Startup needs more time than a single service because of ffmpeg, redis and celery, so `timeoutSeconds` is set higher than sibling Python apps. Confirm against `apps/bazarr`. Code paths that need `DISPATCHARR_SETUP_ALLOWED_IP` or trusted-proxy env are not reached by this test; add them to `filePaths` if they exist as files.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (compose volume `dispatcharr_data`) | Map to `/config/data` via symlink in `start.sh` or an env var if upstream supports one (`UNVERIFIED`). |
| nginx state, logs, pid (`/var/lib/nginx`, `/var/log/nginx`, `/run/nginx.pid`) | `/tmp`, or `nginx` `-g` `pid` and `error_log` overrides. |
| redis (`dir`, `dbfilename`) | `/tmp` (ephemeral) or `/config/redis` if persistence is wanted; decide per upstream. |
| celery beat schedule, uwsgi sockets, pycache | `/tmp`. |
| `/app/version.py` (TIMESTAMP sed) | Build time only, in the Dockerfile. Not a runtime write. |

Upstream security expectations (from the TrueCharts chart, to verify, not guarantees): the chart runs as root, read-only rootfs is false, not privileged. ContainerForge requires `USER apps` and read-only rootfs, so the chart's root requirement is **not** carried over. Extra persistence `/var/run/postgresql` is a socket path. There is no Postgres in the image, so drop it. `/data` is replaced by `/config`.

## 10. Risks, caveats and open questions

- **Base image blocker:** `ghcr.io/dispatcharr/dispatcharr:base` is project-owned and not in this repo. Until it is reproduced on the ContainerForge base, the build cannot start (blocker).
- **Pinned draft commit:** the draft pins Dockerfile `83f82bf`, which could not be fetched. `UNVERIFIED`.
- **No prebuilt binary:** the release has zero assets, so arm64 depends on the source build working.
- **Multi-process:** web, celery, nginx and redis in one container. Needs supervision and careful PID 1 handling. Hard band.
- **Dependency:** the chart's `alpine` companion container is missing from ContainerForge. Not a runtime dependency of the app itself, but the chart stack fails without it. Rebuild or replace before the stack runs.
- **Entrypoint not read:** `docker/entrypoint.sh` and the supervisor config were not read. Everything in section 7 is provisional.
- **Docs not read:** https://dispatcharr.github.io/Dispatcharr-Docs not fetched.
- **Caveat from draft:** higher memory and CPU use (inferred).
- Blockers to confirm: upstream base reproducibility, arm64 build, and whether the entrypoint can run with `/config` as the only writable state.

## 11. Build and test steps

Run from `apps/dispatcharr/`, one app at a time, per `build-test-protocol.instructions.md`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe run with a fresh config volume:
   ```sh
   docker run --rm -d --name dispatcharr-probe --read-only --tmpfs /tmp \
     -v dispatcharr-probe-config:/config dispatcharr:0.34.1
   docker logs -f dispatcharr-probe
   ```
   Expected readiness signal: nginx listening on `9191`, or the app's startup log line (`UNVERIFIED`; confirm from the upstream entrypoint).
4. `forgetool containers test --image dispatcharr:0.34.1 --config ./apps/dispatcharr/container-test.yaml`.
5. Cleanup: `docker rm -f dispatcharr-probe; docker volume rm dispatcharr-probe-config`.

## 12. PR checklist

- Branch: `feat/add-dispatcharr`
- Commit: `feat(dispatcharr): add new container`
- PR title: `feat(dispatcharr): add new container`
- Use `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes. Only check boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State what was not tested: the base image, arm64 and the full stack are not validated until built.
- If the image is not built, do not check "Built container locally".
