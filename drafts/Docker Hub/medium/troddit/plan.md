# troddit — implementation plan
> Source: ./draft.md · Target: apps/troddit/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No git tag and no GitHub release (`gh api repos/burhan-syed/troddit/releases/latest` returns 404). Chart image `docker.io/bsyed/troddit:latest` is the only Docker Hub tag, last updated 2025-07-28 (https://hub.docker.com/v2/repositories/bsyed/troddit/tags). Upstream `package.json` version is `0.21.0` (https://raw.githubusercontent.com/burhan-syed/troddit/main/package.json). Plan pins a commit SHA: `eafe83d592014e68efb9b038ef9dd9a27cb69cc4` (the commit the draft traced the Dockerfile to). UNVERIFIED that this equals current `main` HEAD; confirm at build time. |
| Renovate | `datasource=git-refs depName=https://github.com/burhan-syed/troddit currentValue=main` (precedent `apps/fenrus`). Renovate will propose every `main` push; see section 10. |
| License | AGPL-3.0 (GitHub API `license.spdx_id`, https://api.github.com/repos/burhan-syed/troddit) |
| Source URL | https://github.com/burhan-syed/troddit |
| Download | Source archive `https://github.com/burhan-syed/troddit/archive/${VERSION}.tar.gz` (VERSION = commit SHA). No release assets exist. |
| Per-arch | Source build, so no per-arch binary. Docker Hub `latest` has amd64 and arm64 manifests (https://hub.docker.com/v2/repositories/bsyed/troddit/tags), but we build our own. |
| Checksum source | None published upstream. The tarball is content-addressed by the commit SHA; record the tarball `sha256sum` in the Dockerfile only if the writer verifies it at build time (UNVERIFIED: no upstream checksum). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/burhan-syed/troddit/main/Dockerfile: 3 stages on `node:18-alpine`. `deps`: `apk add libc6-compat g++ make py3-pip`, `yarn install --frozen-lockfile`. `builder`: `yarn build`, then `yarn install --production --ignore-scripts`. `runner`: `NODE_ENV=production`, `NEXT_TELEMETRY_DISABLED=1`, user `nextjs` UID/GID 1001, copies `next.config.js`, `public/`, `.next/standalone`, `.next/static`, `ARG portnum=3000`, `EXPOSE ${portnum}`, `ENV PORT ${portnum}`, `CMD ["node","server.js"]`. No `VOLUME`, no `ENTRYPOINT`. |
| Next config | `next.config.js` sets `output: "standalone"` and `next-pwa` (`dest: public`, `register: true`) (https://api.github.com/repos/burhan-syed/troddit/contents/next.config.js). |
| Versions | `next ^13.4.4`, `react ^18.2.0`, `yarn@1.22.19` (from `packageManager`). Upstream image is Node 18. |
| Port | 3000 (Dockerfile `portnum` default). |
| Env vars (real) | Set by upstream Dockerfile: `NODE_ENV`, `NEXT_TELEMETRY_DISABLED`, `PORT`. App-level auth/analytics variables (Clerk, Supabase, NextAuth, Plausible) are UNVERIFIED: no `.env.example` was fetched, so none are listed in settings.yaml. |
| Data / write paths | No documented runtime writes. Next.js writes `.next/cache` for image optimisation and ISR when used (UNVERIFIED for this app). |
| Dependencies | None in the Dockerfile. Reddit API is an external runtime dependency, not a container. |

## 2. Target layout

- `apps/troddit/Dockerfile`
- `apps/troddit/docker-bake.hcl`
- `apps/troddit/settings.yaml`
- `apps/troddit/container-test.yaml`
- `apps/troddit/start.sh` (sets `HOSTNAME`, `cd`s into the standalone tree, `exec node server.js`)

No `defaults/`, `etc/`, `health/`, `root/` needed. No `DOWNSTREAM_CHANGES.md` (nothing uses this image as `FROM`).

## 3. Base image

Final stage and build stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`.
Reason: Next.js needs Node at runtime (`node server.js`), and `python-node` is the ContainerForge base that already ships Node. Closest sibling: `apps/changedetection` (python-node, node present, build step in the image). The `node:18-alpine` upstream is musl and cannot be reused on glibc Ubuntu.
UNVERIFIED: the Node version inside `python-node:3.15.2`. The writer must run `node --version` in the base first. Next 13 requires Node 16.14 or newer. If the base Node is older than 18, stop and record the blocker in section 10.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Enable yarn 1.x pinned to the `packageManager` field: `npm install -g yarn@1.22.19` (UNVERIFIED that npm is present in the base; if missing, add it via `apt-get install nodejs npm` only if the base lacks them).
3. `ENV NEXT_TELEMETRY_DISABLED=1 NODE_ENV=production YARN_CACHE_FOLDER=/tmp/yarn`. All caches in `/tmp`, never `/config`.
4. `curl -fsL https://github.com/burhan-syed/troddit/archive/${VERSION}.tar.gz -o /tmp/troddit.tar.gz`, then `tar xf ... -C /app/troddit --strip-components=1`, then `rm /tmp/troddit.tar.gz`.
5. `cd /app/troddit && yarn install --frozen-lockfile --network-timeout 600000` (NODE_ENV=production installs skip devDependencies that the build needs. Set `NODE_ENV=development` for this single install, then `NODE_ENV=production` for `yarn build`; UNVERIFIED that `next build` works without devDependencies, so check at build time).
6. `yarn build`, then `yarn install --production --ignore-scripts --prefer-offline` to prune dev dependencies.
7. Copy into the final stage layout under `/app/troddit`: `.next/standalone`, `.next/static` (to `.next/static`), `public`, `next.config.js`. Keep `/app` read-only at runtime.
8. Read-only rootfs: `ln -s /tmp/next-cache /app/troddit/.next/cache` (build-time symlink, so Next writes to `/tmp`). `mkdir -p /tmp/next-cache` is not needed at build time: Next creates it on first write.
9. License: `COPY --from=build /app/troddit/LICENSE /usr/share/licenses/troddit/LICENSE`.
10. Tail:

```dockerfile
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 PORT=3000
USER apps
COPY --chmod=0755 . /
EXPOSE 3000
WORKDIR /app/troddit
CMD ["/start.sh"]
```

No `VOLUME`: the app keeps no state in `/config` (UNVERIFIED: nothing persistent found). If the writer finds persistent writes, add `VOLUME /config` and map them.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "troddit"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/burhan-syed/troddit currentValue=main
  default = "eafe83d592014e68efb9b038ef9dd9a27cb69cc4"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/burhan-syed/troddit"
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

Validate with `docker buildx bake --print` from `apps/troddit`. Copy the exact layout of `apps/valkey/docker-bake.hcl`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/burhan-syed/troddit"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "3000"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
dependencies: []
```

Notes: `volumes` is empty because no persistent path is confirmed. `env` lists only variables the image reads (`PORT`, read by `server.js`; `TZ` is the ContainerForge convention). Do not add Clerk, Supabase or Plausible variables until a fetched `.env.example` confirms their names (UNVERIFIED).

## 7. start.sh

```bash
#!/bin/bash
set -euo pipefail

export PORT="${PORT:-3000}"
export HOSTNAME="0.0.0.0"
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1

cd /app/troddit
exec node server.js "$@"
```

- Binds to all interfaces. The `HOSTNAME` override is explicit because the Docker `HOSTNAME` (container hostname) must not decide the Next bind address (UNVERIFIED default for standalone `server.js`).
- No seeding: the app keeps no state in `/config`, so an empty `/config` is a no-op. Nothing is written under `/app`.
- Ends with `exec` so signals reach Node as PID 1.

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
- /app/troddit/server.js
- /app/troddit/.next/static
- /usr/share/licenses/troddit/LICENSE
```

- One `tcp` and one `http` probe for port 3000 (coverage minimum).
- UNVERIFIED: the HTTP status of `/` with no Reddit or Clerk configuration. If it is not 200, the writer narrows the probe to the status the app returns, and notes why in a comment. Do not remove the probe.
- No env var is needed to start (`filePaths` covers the server code).

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | ContainerForge adaptation |
| --- | --- |
| Runs as `nextjs` UID/GID 1001 | Runs as `apps` (`USER apps`), the ContainerForge rule. |
| Chart sets `runAsUser 0`, `readOnlyRootFilesystem false` | Image runs as `apps` and works with `--read-only --tmpfs /tmp`. The chart values can be simplified later (out of scope). |
| `.next/cache` (ISR, image cache) | Build-time symlink to `/tmp/next-cache`. |
| Yarn cache, npm cache | `/tmp` only (`YARN_CACHE_FOLDER`), removed in the build stage. |
| `/app` read-only at runtime | Nothing is written under `/app` at runtime. |
| Chart: `privileged: no` | No change. |
| Chart: no extra persistence | No `/config` volume. |

## 10. Risks, caveats and open questions

- **No upstream tag or release.** Pinning a commit means Renovate opens a PR for every push to `main`. Accepted precedent: `apps/fenrus`. Alternative: pin the commit and disable updates until upstream tags a release.
- **Stale upstream.** Last push 2025-07-28. Dependencies (Next 13, next-pwa, Clerk 4) may not build on Node 22+ or on current Ubuntu. Build failures are real and must be fixed in the Dockerfile, not by pinning old tools without a reason.
- **Node version** in `python-node:3.15.2` is UNVERIFIED (section 3). Blocker if below 16.14.
- **Native modules**: UNVERIFIED which dependencies compile native code (`draft-js` and `hls.js` are pure JS, `@clerk` is JS). If a native build fails, install `build-essential` in the build stage only, and purge it afterwards.
- **Reddit API**: the app needs Reddit API access; a changed Reddit policy breaks the client. This is a runtime risk, not a build risk.
- **Security expectations (draft)**: the chart runs as root and sets `readOnlyRootFilesystem: false`. ContainerForge runs as `apps`, and the image is designed for `--read-only`. Confirm both at runtime; this is the expected deviation from the chart.
- **Arm64**: Docker Hub manifests exist, but our own build is untested on arm64 (`--set image-all` not run).
- **Blockers**: none confirmed. Not musl-only (the upstream alpine base is replaced), no GPU, no privileged need.

## 11. Build and test steps

```sh
cd apps/troddit
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name troddit-probe --read-only --tmpfs /tmp \
  -v troddit-probe-config:/config -p 3000:3000 troddit:eafe83d592014e68efb9b038ef9dd9a27cb69cc4
docker logs -f troddit-probe
forgetool containers test \
  --image troddit:eafe83d592014e68efb9b038ef9dd9a27cb69cc4 \
  --config ./apps/troddit/container-test.yaml
docker rm -f troddit-probe; docker volume rm troddit-probe-config
```

Expected readiness signal: Next prints `Ready` (or `started server on 0.0.0.0:3000`) and the container stays up. Also confirm an HTTP response on port 3000 from the host. Run with an empty `/config` volume (the app does not use it, but the protocol requires the check).

## 12. PR checklist

- Branch `feat/add-troddit`, commit and PR title `feat(troddit): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it, and the `license/cla` check shows the status.
- Say what was not tested: arm64 build, the HTTP status with no configuration, the Node version of the base, and the runtime with real Reddit data.
- `docker buildx bake --print` passes, and `VERSION` equals the Dockerfile `ARG VERSION`.
