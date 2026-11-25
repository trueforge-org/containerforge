# pasta — implementation plan
> Source: ./draft.md · Target: apps/pasta/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `3.0.0`. GitHub release `3.0.0` published 2026-11-16 (no release assets). Docker Hub `cglatot/pasta` tag `3.0.0` (last_updated 2026-11-16). Sources: https://api.github.com/repos/cglatot/pasta/releases/latest (via `gh api`) and https://hub.docker.com/v2/repositories/cglatot/pasta/tags?page_size=5&ordering=last_updated |
| Draft tag | Draft and chart use `docker.io/cglatot/pasta:3.0.0`. Same version. |
| Renovate | `datasource=github-releases depName=cglatot/pasta versioning=semver` (release tags exist, so `github-releases` applies). UNVERIFIED: renovate config in this repo accepts this form; confirm against a sibling that uses a GitHub source. |
| License | GPL-3.0 (GitHub API `spdx_id`, https://api.github.com/repos/cglatot/pasta via `gh api`). The draft did not state a license. `LICENSE` in `docker-bake.hcl` must be `GPL-3.0`. |
| Source URL | https://github.com/cglatot/pasta |
| Download | No prebuilt binary and no release assets. Source tarball `https://github.com/cglatot/pasta/archive/refs/tags/${VERSION}.tar.gz`, built with npm. |
| Checksum source | None published by upstream. The tarball is pinned by tag. Reference commit for the upstream Dockerfile: `1030b05cdef24d8ea382223496af0c050d45ad46`. UNVERIFIED: that the tag `3.0.0` points at this commit. Check with `git ls-remote` or the tag page before pinning. |
| Upstream Dockerfile reviewed | `Dockerfile` at 1030b05 (summary from fetch, not verbatim, https://raw.githubusercontent.com/cglatot/pasta/1030b05cdef24d8ea382223496af0c050d45ad46/Dockerfile). Builder on `node:24-alpine`: `WORKDIR /app`, `COPY package*.json`, `npm ci`, `npm run build`. Runtime on `node:24-alpine`: `ENV NODE_ENV=production PORT=80 PASTA_MODE=server PASTA_CONFIG_DIR=/config PASTA_DIST_DIR=/app/dist`, `mkdir -p /config`, copies `dist`, `src/shared`, `server/src`, `package.json`, `EXPOSE 80`, `CMD node --disable-warning=ExperimentalWarning server/src/index.ts`. No `USER`, no `VOLUME`, no `ENTRYPOINT`. |
| package.json | name `pasta`, version `3.0.0`. Scripts: `build` = `tsc -b && vite build`; `start:server` = `node --disable-warning=ExperimentalWarning server/src/index.ts`. No `engines` field. No native modules (better-sqlite3 and similar are absent). Source: https://raw.githubusercontent.com/cglatot/pasta/1030b05cdef24d8ea382223496af0c050d45ad46/package.json |
| Port | 80 upstream (`PORT=80`). See section 4 and section 10: this plan runs on port 3000 (rootless cannot bind 80). |
| Env vars (real) | `NODE_ENV`, `PORT`, `PASTA_MODE` (`server`), `PASTA_CONFIG_DIR` (`/config`), `PASTA_DIST_DIR` (`/app/dist`). All confirmed in the upstream Dockerfile. |
| Data / config write path | `/config` (`PASTA_CONFIG_DIR`) |
| arm64 | Upstream builds on `node:24-alpine` (multi-arch manifest). UNVERIFIED: the arm64 manifest of `cglatot/pasta:3.0.0` was not fetched. No native modules, so arm64 is not a build concern here. |

## 2. Target layout

- `apps/pasta/Dockerfile`
- `apps/pasta/docker-bake.hcl`
- `apps/pasta/settings.yaml`
- `apps/pasta/container-test.yaml`
- `apps/pasta/start.sh`

No `defaults/` (app creates its config under `/config`), no `etc/`, no `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

Runtime source is copied to `/app/` through the `app/` folder of the allow-list (`include/.dockerignore` lists `app/`), so the build output and server source live at `apps/pasta/app/` only if they are copied from the repo. Preferred approach: build from source in the Dockerfile (section 4), so `apps/pasta/app/` is not needed.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Fits because it is the ContainerForge Node runtime (the `node` binary comes from this base, see `apps/budge`, `apps/changedetection`). Upstream uses `node:24-alpine` (musl). ContainerForge is glibc Ubuntu, so the Ubuntu-based node runtime is used instead of the alpine image. Closest sibling: `apps/budge` (Node app on python-node, builds with npm, moves state to `/config`).

UNVERIFIED: the Node major version in `python-node:3.15.2`. Check with `node -v` in the built image (step 11). Upstream needs Node 24 for `--disable-warning` and native TypeScript execution of `server/src/index.ts`. If the base Node is older than 22.18, the `server/src/index.ts` run path fails: stop and record as a blocker.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build`, `ARG VERSION`, `USER root`.
2. Download the source tarball and unpack to `/tmp/src`:
   `curl -fsSL "https://github.com/cglatot/pasta/archive/refs/tags/${VERSION}.tar.gz" | tar xz -C /tmp/src --strip-components=1`
3. `ENV NPM_CONFIG_CACHE=/tmp/npm-cache` (npm cache in `/tmp`, rule).
4. `cd /tmp/src && npm ci && npm run build`. Then `npm prune --omit=dev` (runtime needs only production deps; check after the build that `server/src` imports are satisfied).
5. Runtime stage `FROM <python-node>` (same digest), `ARG VERSION`, `USER root`.
6. Copy the built app into `/app`:
   - `COPY --from=build /tmp/src/dist /app/dist`
   - `COPY --from=build /tmp/src/src/shared /app/src/shared`
   - `COPY --from=build /tmp/src/server/src /app/server/src`
   - `COPY --from=build /tmp/src/package.json /app/package.json`
   - `COPY --from=build /tmp/src/node_modules /app/node_modules`
   The `node_modules` copy is needed because the server runs from source and loads its dependencies. UNVERIFIED: upstream's runtime stage omits `node_modules`; the fetched summary may be incomplete. Check the upstream `server/src` imports when building. If it runs without `node_modules`, drop that line.
7. License: `mkdir -p /usr/share/licenses/pasta` and copy the upstream `LICENSE` (GPL-3.0) from the tarball to `/usr/share/licenses/pasta/LICENSE`.
8. `mkdir -p /config /app && chown -R root:root /app && chmod -R 755 /app`, then `rm -rf /tmp/*` and `npm cache clean --force`.
9. Tail:

```dockerfile
ENV NODE_ENV=production \
    PORT=3000 \
    PASTA_MODE=server \
    PASTA_CONFIG_DIR=/config \
    PASTA_DIST_DIR=/app/dist

USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /app
```

- `PORT=3000` overrides upstream's `80`. Reason: non-root users cannot bind ports below 1024 (section 9).
- `VOLUME /config`: state lives under `PASTA_CONFIG_DIR`. Matches the chart's `/config` persistence.
- `EXPOSE 3000` matches the draft's port guess. Confirmed port in upstream is 80, so the draft guess is replaced by the env-driven value 3000 in this app.
- `USER apps` is the final directive.
- Tail: `COPY --chmod=0755 . /` must stay.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "pasta"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=cglatot/pasta versioning=semver
  default = "3.0.0"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/cglatot/pasta"
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

Validate with `docker buildx bake --print` from `apps/pasta/`. `VERSION` in the Dockerfile `ARG` must equal this default.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/cglatot/pasta"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "3000"
    required: false
  - name: PASTA_MODE
    default: "server"
    required: false
  - name: PASTA_CONFIG_DIR
    default: "/config"
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
- Ports: only 3000 (the port the container opens after the `PORT` override).
- Env: only variables the app reads (`PORT`, `PASTA_MODE`, `PASTA_CONFIG_DIR`). `PASTA_DIST_DIR` is set in the image, not user-facing, so it is not listed. `NODE_ENV` is set in the image and not listed.
- `TZ` follows the sibling convention. UNVERIFIED: whether pasta reads `TZ`; remove it if not used, per the rule "do not invent env vars".
- `volumes`: `/config` is required because the app persists state.
- `dependencies: []`: pasta is standalone.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /app || exit 1

exec node --disable-warning=ExperimentalWarning server/src/index.ts
```

- Idempotent. Seeds nothing: pasta creates its own state under `/config` (UNVERIFIED: whether the server creates `PASTA_CONFIG_DIR` itself; the `mkdir` is a safe guard).
- No writes to `/app`.
- `exec` for PID 1 signal handoff.
- The server binds on all interfaces. UNVERIFIED: that `server/src/index.ts` listens on `0.0.0.0` rather than `localhost`. Check the server's `listen` call in the upstream source at 1030b05 and, if it binds to localhost, set `HOST=0.0.0.0` only if the server reads such a variable. Do not invent a variable.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
filePaths:
- /app/server/src/index.ts
- /app/dist
- /usr/share/licenses/pasta/LICENSE
```

- Every port in `settings.yaml` has a `tcp` probe and an `http` probe.
- `filePaths` cover the server entry, the built frontend, and the license.
- No env var is needed to start. The test runs without any, so the path with the default config is the path under test.
- No DB dependency: no narrowing exception applies.
- `timeoutSeconds: 120`: match a sibling Node app of the same family (`apps/budge` uses its own value; check that file and use the same).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `PASTA_CONFIG_DIR=/config` | Persistent `/config` (volume). Empty `/config` start must work (step 7 creates the directory if missing). |
| npm cache during build | `/tmp/npm-cache` (`NPM_CONFIG_CACHE`), removed in the same layer |
| Node temp files at runtime | `/tmp` (tmpfs under `--read-only --tmpfs /tmp`) |
| `/app` | read-only at runtime; the server reads `dist/` and `server/src/`, writes nothing there |
| Port 80 (upstream `PORT=80`) | Changed to 3000. Non-root cannot bind < 1024. |
| Upstream runs as root in the chart (`runAsUser 0`) | This image runs as `apps` (`USER apps`). The chart can drop root. |

No `privileged`, no extra capabilities, no GPU, no SYS_ADMIN needed.

## 10. Risks, caveats and open questions

- Port change: upstream uses 80, this plan uses 3000. The TrueCharts chart must set the container port to 3000 (`PORT` env) for pasta. Document this in the PR and in `DOWNSTREAM_CHANGES.md` only if the app is a `FROM` base (it is not), so in the PR body instead.
- Node version: `python-node:3.15.2` Node major is UNVERIFIED (section 3). Native TypeScript execution needs Node 22.18+ or 24. Check at build time.
- `node_modules` in the runtime stage (section 4 step 6): upstream's runtime omits it. Verify by running the image; drop or keep accordingly.
- Source binds: upstream `server/src/index.ts` bind address is UNVERIFIED (section 7).
- `TZ` in settings is UNVERIFIED (section 6).
- Tag integrity: `3.0.0` tag to commit `1030b05` is UNVERIFIED (section 1). Pin the commit SHA in `VERSION` if the tag moves.
- Upstream is a single-maintainer project. Last push 2026-11-16 (GitHub API). Treat as active but small.
- The draft's security expectations (root, no read-only) are chart defaults. This image runs as `apps` and is read-only compatible per section 9.
- Blockers: none confirmed. No musl-only dependency (no native modules), no GPU, no privileged mode.
- arm64: the Ubuntu `python-node` arm64 build is used; not built or run here.

## 11. Build and test steps

Run from `apps/pasta/` under the build/test protocol:

```sh
cd apps/pasta
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name pasta-probe --read-only --tmpfs /tmp \
  -v pasta-probe-config:/config -p 3000:3000 pasta:3.0.0
docker logs -f pasta-probe   # expect: a startup line naming port 3000 and the process still running
curl -fsS http://127.0.0.1:3000/ >/dev/null && echo ok
docker rm -f pasta-probe; docker volume rm pasta-probe-config
forgetool containers test --image pasta:3.0.0 --config ./container-test.yaml
```

- Expected readiness signal: the server log line announcing the listening port (3000), with the process still running after the startup window.
- Empty `/config` start: fresh named volume `pasta-probe-config` on each round.
- Also run `docker run --rm pasta:3.0.0 node -v` to confirm the Node major (section 3).
- Cleanup: `docker rm -f pasta-probe; docker volume rm pasta-probe-config` between rounds.

## 12. PR checklist

- Branch: `feat/add-pasta`
- Commit and PR title: `feat(pasta): add new container`
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user that contributions need a signed CLA at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Mention in the PR: port changed from upstream 80 to 3000; GPL-3.0 license; the chart needs the port update.
- Not tested: the image is not built here. State exactly what was built and run. Do not check "Built container locally" unless it was.
