# joplin-server — implementation plan
> Source: ./draft.md · Target: apps/joplin-server/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Draft and chart pin `3.7.6` (released 2026-06-24, https://github.com/laurent22/joplin/releases/tag/v3.7.6). Latest upstream stable is `v3.7.24` (published 2026-11-19, https://github.com/laurent22/joplin/releases/tag/v3.7.24). Docker Hub `joplin/server:3.7.6` exists (amd64 + arm64, pushed 2026-11-16). Docker Hub `joplin/server:3.7.24` returns 404. Plan builds from source, so the Docker Hub tag does not limit the choice. See section 10. |
| Renovate | `datasource=github-releases depName=laurent22/joplin versioning=semver` (proposed; the chart's own annotation was not found, UNVERIFIED) |
| License | Root `LICENSE` is GPL-3.0 (https://raw.githubusercontent.com/laurent22/joplin/dev/LICENSE). Upstream `Dockerfile.server` seds `packages/server` to `UNLICENSED` at build time, so the shipped package is not AGPL-tagged. UNVERIFIED which value the bake file should carry, see section 10. |
| Source URL | https://github.com/laurent22/joplin (server package: https://github.com/laurent22/joplin/tree/dev/packages/server) |
| Download | No server tarball on the release page (only desktop AppImage, deb, dmg, zip: https://github.com/laurent22/joplin/releases/expanded_assets/v3.7.24). Build from the tag source archive `https://github.com/laurent22/joplin/archive/refs/tags/v${VERSION}.tar.gz`. UNVERIFIED: this URL pattern was not fetched; confirm it returns the tag before use. |
| Checksum source | None published on the release page. The tarball is content-addressed by tag only, UNVERIFIED for a checksum asset. |
| Upstream Dockerfile reviewed | `Dockerfile.server` at commit `6fcc076` (https://raw.githubusercontent.com/laurent22/joplin/6fcc076/Dockerfile.server). Builder `node:24.22.1` with corepack/yarn, apt installs python3, tini and the cairo, pango, jpeg, gif and rsvg dev libraries (exact package names UNVERIFIED). Runs `yarn install --inline-builds`, then `yarn workspaces focus --production --all`. Runtime `node:24.22.1-slim`, user `joplin`, `npm i -g pm2@5.4.3`, `PM2_HOME=/opt/pm2`, `pm2-logrotate` 3.0.0 (max_size 100MB, retain 5, compress true). `ENV NODE_ENV=production RUNNING_IN_DOCKER=1 APP_NAME LICENSE_REQUIRED`. `WORKDIR /home/joplin/packages/server`, `ENTRYPOINT ["tini","--"]`, `CMD ["yarn","start-prod"]`, `EXPOSE ${APP_PORT}`. |
| Port | 22300 (chart service `main`; chart sets env `APP_PORT` from it: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/joplin-server/values.yaml). |
| Env vars (verified) | `APP_PORT` (chart), `NODE_ENV=production`, `RUNNING_IN_DOCKER=1`, `APP_NAME`, `LICENSE_REQUIRED` (set by upstream image; `APP_NAME` and `LICENSE_REQUIRED` values UNVERIFIED). |
| Env vars (not verified) | Database (`POSTGRES_*`, `DB_CLIENT`) and mail settings: NOT fetched. UNVERIFIED. Do not add them to `settings.yaml` until read from the server source. |
| Data / config paths | Upstream sets `PM2_HOME=/opt/pm2`. Chart mounts persistence at `/config`. UNVERIFIED whether the server reads or writes any path at runtime. |
| arm64 | Yes. Docker Hub manifest list for `3.7.6` has an arm64 image. The build is arch-neutral JavaScript, so no per-arch download is needed. |
| copy-from | Possible (`joplin/server:3.7.6`) but not used: the plan builds from source so the image is ours and the base is ContainerForge. |
| Dependency containers | PostgreSQL, optional per the draft. Upstream production guidance not fetched. UNVERIFIED. `apps/postgresql` exists (✅). |

## 2. Target layout

- `apps/joplin-server/Dockerfile`
- `apps/joplin-server/docker-bake.hcl`
- `apps/joplin-server/settings.yaml`
- `apps/joplin-server/start.sh`
- `apps/joplin-server/container-test.yaml`

No `defaults/`, `etc/`, `scripts/` or `health/` needed: nothing is seeded and no config template is copied. Never use `root/`. `DOWNSTREAM_CHANGES.md` not needed: the new app is not a `FROM` base for any other image.

## 3. Base image

Build stage and final stage both use `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`. It is the only ContainerForge base with Node (see the `apps/changedetection` precedent, which uses `python-node` for a Node tool).

Open check: the Node version in `python-node` is UNVERIFIED. Upstream builds with Node 24 (`node:24.22.1`). Run `node --version` and `yarn --version` in the base before writing the Dockerfile. If the base Node is below 24, stop and report it as a blocker. Do not switch to `ubuntu` and install Node by hand without an approved plan.

The Python part of the base is not used by this app. Ignore `/app/venv`.

## 4. Dockerfile

Two stages, both on the base above.

1. Build stage `FROM <python-node> AS build`, `ARG VERSION`, `USER root`.
2. Install build packages only in the build stage: `python3`, `tini`, and the cairo, pango, jpeg, gif and rsvg development libraries (exact names UNVERIFIED; take them from the upstream `Dockerfile.server` builder stage). `rm -rf /var/lib/apt/lists/*`.
3. Fetch and extract the source:

```dockerfile
RUN set -eux; \
  mkdir -p /tmp/joplin; \
  curl -fsSL "https://github.com/laurent22/joplin/archive/refs/tags/v${VERSION}.tar.gz" \
    | tar xz -C /tmp/joplin --strip-components=1
```

4. Install and prune dependencies as upstream does:

```dockerfile
RUN set -eux; \
  cd /tmp/joplin; \
  corepack enable; \
  yarn install --inline-builds; \
  yarn workspaces focus --production --all
```

UNVERIFIED: whether the upstream builder runs a TypeScript build of `packages/server` before `focus`. Read the full `Dockerfile.server` (only the summary was fetched) and copy its build step exactly.

5. Move the result into the runtime layout and make it writable only for build: `mkdir -p /app/joplin && cp -a /tmp/joplin/. /app/joplin/`, then `chown -R apps:apps /app/joplin && chmod -R 755 /app/joplin`.
6. License file: `mkdir -p /usr/share/licenses/joplin-server && cp /tmp/joplin/LICENSE /usr/share/licenses/joplin-server/LICENSE`. Clear `/tmp/*`.
7. Final stage: `USER apps`, `COPY --chmod=0755 . /`, `ENV NODE_ENV=production RUNNING_IN_DOCKER=1`, `WORKDIR /app/joplin/packages/server`, `EXPOSE 22300`, `VOLUME /config`.

Only the `ENV` values listed as verified in section 1 go into the Dockerfile. Do not add `APP_NAME` or `LICENSE_REQUIRED` values until their values are confirmed.

```dockerfile
ARG VERSION
...
USER apps
COPY --chmod=0755 . /

EXPOSE 22300
VOLUME /config
WORKDIR /app/joplin/packages/server
```

Node packages must be in the final image. `node_modules` is needed at runtime, so the final stage must copy the pruned tree from the build stage (or build in place). Use `COPY --from=build --chown=apps:apps /app/joplin /app/joplin`.

Version alignment: `ARG VERSION` must equal the `VERSION` default in `docker-bake.hcl` (`3.7.6` in this plan).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "joplin-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=laurent22/joplin versioning=semver
  default = "3.7.6"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/laurent22/joplin"
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

`LICENSE` value is a decision, not verified: see section 10. Validate with `docker buildx bake --print` from `apps/joplin-server/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/laurent22/joplin"
ports:
  - port: 22300
    protocol: tcp
    required: false
env:
  - name: APP_PORT
    default: "22300"
    required: false
  - name: NODE_ENV
    default: "production"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
```

Notes:
- `APP_PORT` comes from the chart, so it is listed. `NODE_ENV` is set by upstream image.
- `RUNNING_IN_DOCKER` is set in the Dockerfile and not user-facing, so it is not in `env`.
- Database and mail variables are missing on purpose (UNVERIFIED names, see section 1).
- `postgresql` is an optional dependency per the draft. Use `opt_dependencies`, not `dependencies`, unless the server source proves a hard need.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export APP_PORT="${APP_PORT:-22300}"
export NODE_ENV="${NODE_ENV:-production}"
export RUNNING_IN_DOCKER="${RUNNING_IN_DOCKER:-1}"

cd /app/joplin/packages/server
exec yarn start-prod
```

Rules applied:
- Idempotent and seeds nothing: no file is written to `/config` unless the server does so itself (UNVERIFIED). If it does, create the directory with `mkdir -p` only.
- No writes to `/app`. Any cache or scratch goes to `/tmp`, for example `TMPDIR=/tmp`.
- `exec` gives the final process PID 1 signal handling. Upstream uses `tini` as PID 1. Use `tini` only if zombie reaping is needed and the base does not provide an init (UNVERIFIED which applies).
- PM2 is not used: the upstream runtime runs `pm2` with a writable `PM2_HOME`. Dropping it removes the need for `/opt/pm2` and `pm2-logrotate`. Decision for the implementer; if PM2 is kept, set `PM2_HOME=/tmp/pm2` and state why in the PR.
- The server must listen on all interfaces. UNVERIFIED: the bind address in the server config. Check it from outside the container (see section 11).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '22300'
filePaths:
- /app/joplin/packages/server
```

- One `tcp` probe for port 22300. No `http` probe yet: the health or ping path is UNVERIFIED. Add an `http` probe only after the path is confirmed in the source and returns 200 with no env vars.
- `timeoutSeconds: 180` matches the Node-based sibling `apps/changedetection`.
- Path for `filePaths`: replace `/app/joplin/packages/server` with the built entry point (for example the compiled `dist` file) once the build confirms it. UNVERIFIED until then.
- The test runs with no env vars. If the server only starts with a database, the test fails. The DB exception in the protocol applies only to a hard dependency, and the draft says optional. So the server must start without PostgreSQL. If it does not, report it as a blocker and do not narrow the test.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `PM2_HOME=/opt/pm2` | Not used (PM2 dropped, section 7). If kept, `/tmp/pm2`. |
| Node cache and temp | `TMPDIR=/tmp`. |
| Server data or logs | UNVERIFIED whether any. If found, point at `/config` (persistent) or `/tmp` (scratch). |
| Upstream user `joplin` (uid set by upstream image) | Final image runs as `apps` (`USER apps`), per the Dockerfile rules. |

Draft expectations reconciled:
- Chart `runAsUser: 0`, `runAsNonRoot: false`: the image runs as `apps`, so the chart override is not needed for this image.
- Chart `readOnlyRootFilesystem: false`: the plan is compatible with `--read-only --tmpfs /tmp` if the server writes nothing outside `/config` and `/tmp`. Verify with the protocol run.
- Not privileged. No extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- Version: draft and chart pin `3.7.6`, which matches the Docker Hub tag. Upstream is at `3.7.24`, which is not on Docker Hub, but the plan builds from source. Recommended: `3.7.6` for this PR for parity with the chart. Bump in a separate PR.
- License: the root `LICENSE` is GPL-3.0, but upstream sets `packages/server` to `UNLICENSED` at build time. The bake value must match the software in the image. Decision needed before commit. Use `GPL-3.0` as the proposal until confirmed.
- Node 24: upstream needs it, and the `python-node` base Node version is UNVERIFIED (section 3).
- Build time and disk: yarn monorepo plus native cairo/pango builds. Expect a slow build on arm64. Plan the build on amd64 first.
- PM2 removed: a deliberate deviation from upstream. Reason: writable `PM2_HOME` and log rotation are not needed by a container that already has logs on stdout.
- Upstream `tini` as PID 1 versus `exec yarn start-prod`: signal handling must be checked on `docker stop`.
- Database: optional in the draft, but upstream production use is PostgreSQL (inferred from the draft, UNVERIFIED). Real use is not tested by the single-container suite.
- Mail: needed for signup and password reset; the variables are UNVERIFIED and not in `settings.yaml`.
- Chart security: `runAsUser 0` and `readOnlyRootFilesystem false` are chart choices, not upstream requirements.
- Blockers: none confirmed. Gate: Node 24 available in the base, and a server start without a database.

## 11. Build and test steps

```sh
cd apps/joplin-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name joplin-server-probe --read-only --tmpfs /tmp \
  -p 22300:22300 -v joplin-server-probe-config:/config joplin-server:3.7.6
docker logs -f joplin-server-probe
curl -sS -o /dev/null -w '%{http_code}\n' http://localhost:22300/
docker exec joplin-server-probe ss -ltn
docker rm -f joplin-server-probe; docker volume rm joplin-server-probe-config

forgetool containers test --image joplin-server:3.7.6 --config ./apps/joplin-server/container-test.yaml
```

Readiness signals (expected, UNVERIFIED until a run): the process stays up, a line with the port or `listening`/`started` appears in the log, and `ss -ltn` shows `:22300` on `0.0.0.0` or `[::]`. Confirm the bind from another container, not only with `localhost`, because the `tcp` probe runs inside the container.

## 12. PR checklist

- Branch `feat/add-joplin-server` from `main`. Commit and PR title `feat(joplin-server): add new container`. Target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Confirm `docker buildx bake --print` passes and `VERSION` in `docker-bake.hcl` equals `ARG VERSION` in the Dockerfile.
- Untested to state honestly in the PR: the Node 24 check in the base, the full build on arm64, runtime on `--read-only`, the health path, the database and mail variables, and the license value.
