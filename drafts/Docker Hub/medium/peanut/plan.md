# peanut — implementation plan
> Source: ./draft.md · Target: apps/peanut/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v6.1.2`. GitHub release `v6.1.2` published 2026-10-19 (no release assets). Docker Hub `brandawg93/peanut` tags `6.1.2` and `latest` (last_updated 2026-10-28). Sources: https://api.github.com/repos/Brandawg93/PeaNUT/releases/latest (via `gh api`) and https://hub.docker.com/v2/repositories/brandawg93/peanut/tags?page_size=5&ordering=last_updated |
| Draft tag | Draft uses `docker.io/brandawg93/peanut:6.1.2`. The TrueCharts chart (fetched 2026-11-27) pins `docker.io/brandawg93/peanut:6.2.0`, not 6.1.2. |
| Renovate | `datasource=github-releases depName=Brandawg93/PeaNUT versioning=semver` (release tags exist). UNVERIFIED: the `v` prefix handling; `apps/budge` does not use a `v`-prefixed VERSION: its Dockerfile tries `${VERSION}` and falls back to `v${VERSION}` for the tarball URL. Check how renovate treats the `v` here. |
| License | Apache-2.0 (GitHub API `spdx_id`, https://api.github.com/repos/Brandawg93/PeaNUT via `gh api`). `LICENSE` in `docker-bake.hcl` = `Apache-2.0`. |
| Source URL | https://github.com/Brandawg93/PeaNUT |
| Download | No prebuilt binary and no release assets. Source tarball `https://github.com/Brandawg93/PeaNUT/archive/refs/tags/${VERSION}.tar.gz` (`VERSION=v6.1.2`), built with pnpm and Next.js. |
| Checksum source | None published by upstream. Tarball pinned by tag. Reference commit for the upstream Dockerfile: `7ad39fd50525a3c7e5f0979fef7defbcc7f65229`. UNVERIFIED: that tag `v6.1.2` points at this commit. Check before pinning. |
| package.json | name `peanut`, version `6.1.2`, `packageManager` `pnpm@10.25.0`, scripts `build` = `next build`, `start` = `node server.js`. Source: https://raw.githubusercontent.com/Brandawg93/PeaNUT/7ad39fd50525a3c7e5f0979fef7defbcc7f65229/package.json |
| Upstream Dockerfile reviewed | `Dockerfile` at 7ad39fd (summary from fetch, not verbatim, https://raw.githubusercontent.com/Brandawg93/PeaNUT/7ad39fd50525a3c7e5f0979fef7defbcc7f65229/Dockerfile). Stages: `pnpm` (`node:lts-slim`, corepack); `deps` (`pnpm fetch`, `pnpm i --frozen-lockfile --ignore-scripts`); `build` (`pnpm run next-ws`, `pnpm run build`, creates `/config`, removes `.next/standalone/.next/cache`); runner on `dhi.io/node:24`. Runner: `COPY` of `.next/standalone`, `.next/static`, `/config`, `src/app/api`, `package.json`, plus `entrypoint.mjs` and `healthcheck.mjs`. `ENTRYPOINT ["node", "entrypoint.mjs"]`. `HEALTHCHECK node healthcheck.mjs`. No `USER` (relies on node user, UID 1000), no `VOLUME`, `EXPOSE $WEB_PORT`. |
| Env vars (real, from upstream Dockerfile) | `NODE_ENV=production`, `NEXT_TELEMETRY_DISABLED=1`, `CI=true`, `WEB_HOST=0.0.0.0`, `WEB_PORT=8080`, `BASE_PATH=""`, `SETTINGS_FILE=/config/settings.yml`, `AUTH_FILE_PATH=/config/auth.yaml`, `DEBUG=false`. |
| Port | 8080 (`WEB_PORT`, upstream `EXPOSE`). Draft guess of 8080 is confirmed. |
| Data / config write paths | `/config` (`SETTINGS_FILE`, `AUTH_FILE_PATH`). UNVERIFIED: any further writable path (logs, caches) inside the Next.js server. |
| arm64 | Upstream is multi-arch by intent. UNVERIFIED: manifest list of `brandawg93/peanut:6.1.2` was not fetched. |

## 2. Target layout

- `apps/peanut/Dockerfile`
- `apps/peanut/docker-bake.hcl`
- `apps/peanut/settings.yaml`
- `apps/peanut/container-test.yaml`
- `apps/peanut/start.sh`

No `defaults/`, `etc/` or `health/` needed: the app writes its config on first start under `/config`. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

Upstream `entrypoint.mjs` and `healthcheck.mjs` live in the repo root. `include/.dockerignore` only allows listed paths, so they cannot be copied from `apps/peanut/` root. They are fetched in the build stage from the pinned tarball, not copied from the repo (section 4).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Fits because it is the ContainerForge Node runtime (`apps/budge`, `apps/changedetection`). Upstream runner is `dhi.io/node:24`, which is not used here. Closest sibling: `apps/budge` (Node app with a build stage on python-node, state in `/config`).

UNVERIFIED: whether `python-node:3.15.2` ships `corepack` (needed for `pnpm`). Check `corepack --version` in the image. If absent, use `npm install -g pnpm@10.25.0` (matches `packageManager`). UNVERIFIED: the Node major in the base. Next.js needs Node 20.9+ at least; upstream targets Node 24. If the base Node is older than 20.9, stop and record as a blocker.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build`, `ARG VERSION` (`v6.1.2`), `ARG TARGETARCH`, `USER root`.
2. Download the pinned source tarball to `/tmp/src` (`mkdir -p /tmp/src` first):
   `curl -fsSL "https://github.com/Brandawg93/PeaNUT/archive/refs/tags/${VERSION}.tar.gz" | tar xz -C /tmp/src --strip-components=1`
3. `ENV PNPM_HOME=/tmp/pnpm PATH=/tmp/pnpm:$PATH NEXT_TELEMETRY_DISABLED=1 NPM_CONFIG_CACHE=/tmp/npm-cache`. All caches in `/tmp`, never `/config` or `/app`.
4. `cd /tmp/src && corepack enable && pnpm i --frozen-lockfile --ignore-scripts && pnpm run build`. The upstream `next-ws` script is also run (`pnpm run next-ws`) before `build`, matching upstream. UNVERIFIED: that `next-ws` exists in `package.json` at 7ad39fd. Check the `scripts` block when building.
5. Runtime stage `FROM <python-node>` (same digest), `ARG VERSION`, `USER root`.
6. Copy the standalone output into `/app`:
   - `COPY --from=build /tmp/src/.next/standalone/ /app/`
   - `COPY --from=build /tmp/src/.next/static/ /app/.next/static/`
   - `COPY --from=build /tmp/src/src/app/api/ /app/src/app/api/` (Swagger generation, as upstream)
   - `COPY --from=build /tmp/src/package.json /app/package.json`
   - Fetch `entrypoint.mjs` and `healthcheck.mjs` from the same tag (`https://raw.githubusercontent.com/Brandawg93/PeaNUT/${VERSION}/entrypoint.mjs` and `.../healthcheck.mjs`) into `/app/`, then `chmod 0755`. UNVERIFIED: both files exist at tag `v6.1.2` (they were seen at commit 7ad39fd by the fetch summary only).
7. License: `mkdir -p /usr/share/licenses/peanut` and copy the tarball's `LICENSE` to `/usr/share/licenses/peanut/LICENSE`.
8. `mkdir -p /config`, then `rm -rf /tmp/* /tmp/.[!.]*` and `pnpm store prune` / `npm cache clean --force` in the same layer.
9. Tail:

```dockerfile
ENV NODE_ENV=production \
    CI=true \
    WEB_HOST=0.0.0.0 \
    WEB_PORT=8080 \
    BASE_PATH="" \
    SETTINGS_FILE=/config/settings.yml \
    AUTH_FILE_PATH=/config/auth.yaml \
    DEBUG=false

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app
```

- `USER apps` final. Upstream had no `USER`, so ownership of `/app` must allow `apps` to read it (`chown -R root:root` and `chmod -R 755` in step 8).
- `HEALTHCHECK` is not added here. The probe is covered by `container-test.yaml` (section 8). Adding a Dockerfile HEALTHCHECK is optional; if added, use `node /app/healthcheck.mjs` with `WEB_PORT`.
- `COPY --chmod=0755 . /` must stay.
- `ARG VERSION` must equal the `VERSION` default in `docker-bake.hcl` (`v6.1.2`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "peanut"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Brandawg93/PeaNUT versioning=semver
  default = "v6.1.2"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/Brandawg93/PeaNUT"
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

Validate with `docker buildx bake --print` from `apps/peanut/`. The tag keeps its `v` prefix so the image tag matches the release tag. Alternatively strip the `v` in the image tag if sibling convention differs (`apps/budge` uses no `v` in VERSION and falls back in the Dockerfile).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Brandawg93/PeaNUT"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: WEB_PORT
    default: "8080"
    required: false
  - name: BASE_PATH
    default: ""
    required: false
  - name: SETTINGS_FILE
    default: "/config/settings.yml"
    required: false
  - name: AUTH_FILE_PATH
    default: "/config/auth.yaml"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Rules applied:
- Ports: 8080 only.
- Env: only variables the app reads from the upstream Dockerfile and config paths. `NODE_ENV`, `CI`, `DEBUG`, `NEXT_TELEMETRY_DISABLED` are set in the image, not user-facing, so they are not listed. `WEB_HOST` is fixed to `0.0.0.0` in the image, so it is not listed (rule: bind all interfaces).
- NUT server connection (host, port, user, password) is not in this list because the upstream config for NUT servers is not confirmed as env-driven (UNVERIFIED). It is set in the web UI or `settings.yml` under `/config`. Do not invent env vars.
- `volumes`: `/config` required (state).
- `dependencies: []`: NUT server is external, not a ContainerForge dependency.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /app || exit 1

exec node entrypoint.mjs
```

- Idempotent. Creates `/config` if missing. The upstream `entrypoint.mjs` seeds `settings.yml` and `auth.yaml` under `/config` when they are missing (UNVERIFIED: the entrypoint's seeding behaviour; read `entrypoint.mjs` at tag `v6.1.2` before committing). Do not overwrite existing files.
- No writes to `/app`.
- `exec` gives the Node process PID 1 signal handling.
- `WEB_HOST=0.0.0.0` is set in the image, so the server listens on all interfaces.
- If `entrypoint.mjs` is not usable, fall back to `exec node server.js` from `/app` (upstream `start` script). Confirm which path runs.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/server.js
- /app/entrypoint.mjs
- /app/.next/static
- /usr/share/licenses/peanut/LICENSE
```

- `tcp` and `http` probes for 8080, the only port in `settings.yaml`.
- `http` path `/`: UNVERIFIED that `/` returns 200 without a configured NUT server. Check in the build round. If the first-run redirect returns a non-200, use the status-returning route the app serves (confirm from the app source, do not guess).
- `filePaths` cover the Next.js standalone server entry, the entrypoint, the static assets, and the license.
- No DB dependency and no env var needed to start, so the default path is the path under test. The NUT server is not reachable in the test, and the app is expected to start and serve its UI without it (UNVERIFIED: confirm in step 11; if the app exits without a NUT server, record it as a blocker and check the protocol's DB-style narrowing does not apply, since NUT is not a ContainerForge dependency).
- `timeoutSeconds: 120`: Next.js standalone start can be slow. `apps/budge` sets no `timeoutSeconds`; 120 is a plan choice.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `SETTINGS_FILE=/config/settings.yml`, `AUTH_FILE_PATH=/config/auth.yaml` | `/config` (persistent) |
| `/config` created in build | Re-created by `start.sh` when missing (empty `/config` start) |
| Next.js cache (`.next/cache`) | Removed at build time (upstream does this). If the runtime writes a cache, it goes to `/tmp`; UNVERIFIED whether it does, so run under `--read-only --tmpfs /tmp` in step 11. |
| pnpm and npm caches | `/tmp` at build time only |
| Node temp files | `/tmp` (tmpfs) |
| `/app` | read-only at runtime |
| Upstream runs as UID 1000 (node) and the chart as root | This image runs as `apps` (`USER apps`). The chart can drop root. |

No `privileged`, no extra capabilities, no GPU.

## 10. Risks, caveats and open questions

- `dhi.io/node:24` (upstream runner) is not reused. The Node major and `corepack` in `python-node:3.15.2` are UNVERIFIED (section 3).
- NUT server dependency: PeaNUT needs a reachable `upsd`. Not part of this container. The app should still start and serve its UI without it. Confirm (section 8).
- `entrypoint.mjs` and `healthcheck.mjs` are fetched from the tag (section 4 step 6). Verify they exist at `v6.1.2`. If the tag lacks them, use the upstream `node server.js` path (section 7).
- Tag integrity: `v6.1.2` to commit `7ad39fd` is UNVERIFIED (section 1).
- Build memory: Next.js build may need a lot of RAM on small hosts (draft caveat, confirmed as a reasonable concern). Note in the PR.
- Renovate `v` prefix handling is UNVERIFIED (section 1).
- The chart uses `brandawg93/peanut:6.2.0` (no `v`; fetched 2026-11-27). This app uses `peanut:v6.1.2` as tag. Decide the tag form with the user, or keep `v` and note the tag difference in the PR.
- Upstream is active: last push 2026-11-23 (GitHub API). Release 6.1.2 is from 2026-10-19.
- Blockers: none confirmed. No musl-only dependency, no GPU, no privileged mode.
- arm64: not built or run here.

## 11. Build and test steps

Run from `apps/peanut/` under the build/test protocol:

```sh
cd apps/peanut
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name peanut-probe --read-only --tmpfs /tmp \
  -v peanut-probe-config:/config -p 8080:8080 peanut:v6.1.2
docker logs -f peanut-probe   # expect: a line that the server is ready on port 8080, process still running
curl -fsS http://127.0.0.1:8080/ >/dev/null && echo ok
docker rm -f peanut-probe; docker volume rm peanut-probe-config
forgetool containers test --image peanut:v6.1.2 --config ./container-test.yaml
```

- Expected readiness signal: a server-listening line on port 8080 (exact text UNVERIFIED until the first build), with the process still running after the startup window.
- Empty `/config`: a fresh named volume `peanut-probe-config` on each round.
- Check `corepack --version` and `node -v` in the image before the first round (section 3).
- Cleanup: `docker rm -f peanut-probe; docker volume rm peanut-probe-config` between rounds.

## 12. PR checklist

- Branch: `feat/add-peanut`
- Commit and PR title: `feat(peanut): add new container`
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user that contributions need a signed CLA at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Mention in the PR: a NUT server is required at runtime but is not part of the image; build memory note; tag form (`v6.1.2`) versus chart tag (`6.2.0`).
- Not tested: the image is not built here. State exactly what was built and run. Do not check "Built container locally" unless it was.
