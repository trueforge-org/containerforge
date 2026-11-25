# pingvin-share — implementation plan
> Source: ./draft.md · Target: apps/pingvin-share/ · Difficulty: medium · Role (main) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest release | v1.13.0, published 2025-05-25 (matches draft tag) | https://api.github.com/repos/stonith404/pingvin-share/releases/latest |
| Renovate | UNVERIFIED: no renovate config checked. Planned: `datasource=github-releases depName=stonith404/pingvin-share versioning=semver` | — |
| License | BSD-2-Clause | https://api.github.com/repos/stonith404/pingvin-share/license |
| Source URL | https://github.com/stonith404/pingvin-share | draft.md |
| Ready-made binary | None. The v1.13.0 release has no assets. The app is built from source (npm) | https://github.com/stonith404/pingvin-share/releases/tag/v1.13.0 and releases API |
| amd64 / arm64 | Source build only, so both are "compile" in practice. The draft's `yes` for both means "fetch the source and build", not a binary download | releases API |
| Checksum source | Not applicable (no assets) | — |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/stonith404/pingvin-share/dd546b4f17a516ef696ea35b96bbac8ff5521e2a/Dockerfile: all stages `node:22-alpine`. Stages: frontend-dependencies (`npm ci`), frontend-builder (`npm run build`), backend-dependencies (adds `python3`, `npm ci`), backend-builder (adds `openssl`, `npx prisma generate`, `npm run build && npm prune --production`), runner (deletes `node` user, installs `curl`, `caddy`, `su-exec`, `openssl`) | same |
| Upstream ENTRYPOINT/CMD | `ENTRYPOINT ["sh", "./scripts/docker/create-user.sh"]`, `CMD ["sh", "./scripts/docker/entrypoint.sh"]` | same |
| Env vars | `NODE_ENV=docker` (Dockerfile). `CADDY_DISABLED` (if not `"true"`, Caddy starts) and `TRUST_PROXY` (if `"true"`, uses `Caddyfile.trust-proxy`) read by `scripts/docker/entrypoint.sh`, no defaults. `BACKEND_PORT` used by HEALTHCHECK, default 8080 | https://raw.githubusercontent.com/stonith404/pingvin-share/dd546b4f17a516ef696ea35b96bbac8ff5521e2a/scripts/docker/entrypoint.sh and Dockerfile |
| Ports | `EXPOSE 3000` (Dockerfile). Frontend runs on `PORT=3333 HOSTNAME=0.0.0.0` (entrypoint). Backend default 8080. Which port Caddy serves on: UNVERIFIED (Caddyfile not fetched). HEALTHCHECK curls port 3000 when Caddy is on | same |
| Data paths | Draft: `/opt/app/backend/data` (Prisma DB and uploads). Entrypoint writes `/opt/app/frontend/public/img` (`cp -rn /tmp/img/* ...`). Exact SQLite file path: UNVERIFIED | same |
| Migrations | Prisma: `prisma generate` at build time. Migration on first start: UNVERIFIED (the `npm run prod` script was not fetched) | same |
| Process model | Entrypoint does not `exec`: runs `cd backend && npm run prod` in the foreground after starting the frontend in the background | same |
| Dependencies | None external. Redis cache is an optional backend choice in v1.13.0 (release notes) | https://api.github.com/repos/stonith404/pingvin-share/releases/latest |

## 2. Target layout

- `apps/pingvin-share/Dockerfile`
- `apps/pingvin-share/docker-bake.hcl`
- `apps/pingvin-share/settings.yaml`
- `apps/pingvin-share/container-test.yaml`
- `apps/pingvin-share/start.sh` (replaces upstream `scripts/docker/entrypoint.sh`, with `exec` on the last process)
- `apps/pingvin-share/defaults/` only if a seeded config file is needed (none known)

Not needed: `root/` (never used), `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`.

Fit: the app is Node only, but the Python stage is needed for `node-gyp` in `backend-dependencies` upstream, and `python-node` already ships Node. Python is not needed at runtime. Node major version in the base: UNVERIFIED. Upstream builds with Node 22, so confirm `node --version` in the base before building. If the base's Node is not 22, the draft's Node-only table row points to `ghcr.io/trueforge-org/ubuntu` plus a Node 22 install, which is a larger change; decide in the probe.

Closest siblings: `apps/changedetection` (python-node, npm build, `/app` source copy, `/config` for data) and `apps/budge` (Node app built into `/app/www`, `exec` on a Node process).

## 4. Dockerfile

1. `FROM <python-node> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Fetch source: `curl -fL https://github.com/stonith404/pingvin-share/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`, with the same non-`v` fallback as `apps/changedetection`.
3. Build stage steps, mirroring upstream:
   - `cd /tmp/src/frontend && npm ci && npm run build`
   - `cd /tmp/src/backend && npm ci && npx prisma generate && npm run build && npm prune --omit=dev`
   - `ENV npm_config_cache=/tmp/npm NODE_ENV=production` (caches in `/tmp`, never `/config`).
   - Remove `/tmp/src` after copying the outputs.
4. Final stage `FROM <python-node>` (same digest), `ARG VERSION`, `ARG TARGETARCH`, `USER root`:
   - `apt-get update && apt-get install -y --no-install-recommends caddy su-exec openssl curl` (only if Caddy is kept; see section 10). Package availability for `caddy` on Ubuntu 26.04: UNVERIFIED.
   - Copy the built frontend and backend to `/app/frontend` and `/app/backend` with `COPY --from=build`.
   - Copy the upstream `Caddyfile` and `Caddyfile.trust-proxy` to `/app/reverse-proxy/` (only if Caddy is kept).
   - License: copy upstream `LICENSE` to `/usr/share/licenses/pingvin-share/LICENSE` (BSD-2-Clause).
   - Symlink the writable paths into `/config` (dangling until start.sh creates them, same pattern as `apps/bookstack`):
     - `ln -s /config/data /app/backend/data`
     - `ln -s /config/img /app/frontend/public/img`
   - `chown -R apps:apps /app && chmod -R 755 /app`.
   - `ENV NODE_ENV=docker HOME=/config`.
   - `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "pingvin-share"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=stonith404/pingvin-share versioning=semver
  default = "1.13.0"
}

variable "LICENSE" {
  default = "BSD-2-Clause"
}

variable "SOURCE" {
  default = "https://github.com/stonith404/pingvin-share"
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

Validate with `docker buildx bake --print`. `VERSION` 1.13.0 must equal the Dockerfile `ARG VERSION`. The release tag is `v1.13.0`, so the curl in the Dockerfile uses `v${VERSION}`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/stonith404/pingvin-share"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: CADDY_DISABLED
    default: "false"
    required: false
  - name: TRUST_PROXY
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Port 3000 is the upstream EXPOSE and the port the chart uses (draft). Confirm the Caddy listening port (section 10). Only env vars read by the scripts are listed. `CADDY_DISABLED` and `TRUST_PROXY` are read with no default upstream; the defaults above state the behavior the script already has (`!= "true"`, `= "true"`).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data /config/img

# seed default images only when missing (never overwrite user uploads)
if [ -d /tmp/img ]; then
  cp -rn /tmp/img/. /config/img/ 2>/dev/null || true
fi

cd /app/backend
export NODE_ENV=docker

if [ "${CADDY_DISABLED:-false}" != "true" ]; then
  if [ "${TRUST_PROXY:-false}" = "true" ]; then
    caddy start --config /app/reverse-proxy/Caddyfile.trust-proxy --adapter caddyfile
  else
    caddy start --config /app/reverse-proxy/Caddyfile --adapter caddyfile
  fi
fi

PORT=3333 HOSTNAME=0.0.0.0 node /app/frontend/server.js &
exec npm run prod
```

- Idempotent. Seeds `/config/img` only when missing (`cp -n`). Creates `/config/data` for Prisma.
- Upstream copies images from `/tmp/img` into `public/img`; the `/tmp/img` source must come from the build stage (put the seed images in the image at a path outside `/config`, or drop the seed if the image dir is empty upstream: UNVERIFIED).
- `exec npm run prod` is the final long-running process. If the frontend background process must be supervised, a `wait -n` pattern is needed; decide in the probe. Do not leave the frontend unsupervised without a note.
- Prisma migration on start: run `npx prisma migrate deploy` before `npm run prod` only if the upstream `prod` script does not already do it (UNVERIFIED; check `backend/package.json`).
- Never write to `/app`. Caddy `start` writes its runtime state under `$HOME` = `/config`: set `XDG_DATA_HOME=/tmp/caddy-data XDG_CONFIG_HOME=/tmp/caddy-config` so nothing lands in `/config` (Caddy state belongs in `/tmp`).
- `HOSTNAME=0.0.0.0` binds the frontend to all interfaces, as the upstream entrypoint does.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/backend/dist/main.js
- /app/frontend/server.js
- /usr/share/licenses/pingvin-share/LICENSE
```

- `tcp` and `http` probes for port 3000, the only declared port. If Caddy serves on another port, change the probes and `settings.yaml` together.
- `filePaths`: `/app/backend/dist/main.js` is the expected NestJS entry (UNVERIFIED; confirm the path from the backend build output).
- `timeoutSeconds` 180 is an estimate for Prisma and Next.js start-up; compare with `apps/changedetection` (180).
- The test runs with no env vars, so the first-run admin-account path is not tested. Note this in the PR.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/opt/app/backend/data` (Prisma DB, upload data, draft) | build-time symlink `/app/backend/data` to `/config/data` |
| `/opt/app/frontend/public/img` (chart PVC, images) | build-time symlink `/app/frontend/public/img` to `/config/img` |
| Caddy data and config (`$HOME/.local`, `$XDG_*`) | `/tmp` via `XDG_DATA_HOME` and `XDG_CONFIG_HOME` |
| npm, Prisma engine cache | build stage only, `/tmp` |

Draft security expectations reconciled: the chart runs as root (runAsUser 0), but this image uses `USER apps` and does not need root at runtime (Caddy binds port 3000 only if the port is above 1024; keep it above 1024). Read-only rootfs is compatible with `--read-only --tmpfs /tmp` if both the Prisma and Caddy writes go to `/config` or `/tmp`. Not privileged. `su-exec` from upstream is not needed when the image already runs as `apps`; drop it unless a script still requires it.

## 10. Risks, caveats and open questions

- Alpine to Ubuntu: upstream is `node:22-alpine` (musl). Node native modules and Prisma engines must be rebuilt on glibc in the build stage. Do not `COPY --from` an alpine image into the ubuntu stage.
- Caddy on Ubuntu 26.04: package availability UNVERIFIED. If the `caddy` apt package is absent, use `CADDY_DISABLED` as the default and document that the frontend and backend need separate routing (UNVERIFIED how the upstream frontend reaches `/api` without Caddy). This is a blocker if no routing is possible on one port.
- Port conflict: draft and EXPOSE say 3000, the entrypoint's frontend says 3333, the backend default is 8080. Confirm which port Caddy serves (Caddyfile not fetched).
- The HEALTHCHECK in the upstream Dockerfile is dropped (ContainerForge uses forgetool probes), so no `HEALTHCHECK` line in our Dockerfile unless needed.
- Prisma migration on first start: UNVERIFIED (see section 7).
- The draft's "admin account in browser" is UNVERIFIED for this release and is not testable in the container suite.
- Uploads grow over time; plan `/config` size (draft caveat, not verified).
- `runAsUser` and `readOnlyRootFilesystem` in the chart differ from this image by design (section 9).
- Blockers: none confirmed. Caddy availability and the routing question are the open items.

## 11. Build and test steps

```sh
cd apps/pingvin-share
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name pingvin-share-probe --read-only --tmpfs /tmp \
  -v pingvin-share-probe-config:/config pingvin-share:1.13.0
docker logs -f pingvin-share-probe
forgetool containers test --image pingvin-share:1.13.0 --config ./apps/pingvin-share/container-test.yaml
docker rm -f pingvin-share-probe; docker volume rm pingvin-share-probe-config
```

Expected readiness signal: the backend logs its Nest listening line and the frontend logs Next.js `ready` (exact text UNVERIFIED; take it from the first probe run). The container must still be running after the start-up window. Then build arm64 if amd64 is green.

## 12. PR checklist

- Branch `feat/add-pingvin-share`, commit and PR title `feat(pingvin-share): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only what applies.
- Notes section: `🤖 This PR is AI generated.` No "Generated with" or other tool attribution line (AGENTS.md).
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Tell the user; only the user can sign it; the `license/cla` check shows the status.
- State honestly what was not tested: the Caddy routing decision, the admin first-run flow, arm64, upload and Prisma paths under real use, and the Renovate annotation (UNVERIFIED).
