# docker-hub-rss — implementation plan
> Source: ./draft.md · Target: apps/docker-hub-rss/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub releases (`releases/latest` returns 404). Pin the `master` HEAD commit `23c6d2db08ac4fb44f7204cadd56faa24bf5b51a` (committed 2025-12-27). Source: `gh api repos/TheConnMan/docker-hub-rss/commits?sha=master`. Repo default branch is `dev` (pushed 2026-07-27); `master` is the branch the chart's image was built from is UNVERIFIED. package.json `version` is `0.6.2`. |
| Draft difference | Draft says "build from repository HEAD". Confirmed: no tags, no releases. The chart's image is `ghcr.io/theconnman/docker-hub-rss:latest@sha256:38eba84b…` (chart values.yaml); the commit behind that digest is UNVERIFIED. |
| Renovate | `datasource=git-refs depName=https://github.com/TheConnMan/docker-hub-rss currentValue=master` (same pattern as `apps/fenrus`; not yet proven in this repo). |
| License | MIT (GitHub API `license.spdx_id` = MIT; package.json `license` = MIT). |
| Source URL | https://github.com/TheConnMan/docker-hub-rss |
| Download | No binary. Source archive `https://github.com/TheConnMan/docker-hub-rss/archive/${VERSION}.tar.gz` (VERSION = commit SHA) plus `npm`/`yarn` dependencies. Arch-independent JavaScript. |
| Checksum source | None published. The archive is content-addressed by the commit SHA. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/TheConnMan/docker-hub-rss/master/Dockerfile: `FROM node:22-alpine`; `apk add git`; `mkdir /app && chown nobody:nogroup /app`; `USER nobody`; `COPY yarn.lock package.json`; `RUN yarn install`; `COPY . /app`; `EXPOSE 3000`; `CMD yarn start`. |
| Start command | package.json `scripts.start` = `node index.js` (https://raw.githubusercontent.com/TheConnMan/docker-hub-rss/master/package.json). |
| Port | `PORT`, default 3000 (README; `index.js`). Routes: `/info`, `/r/:username/:repository`, `/:username/:repository.atom`. |
| Env vars (real) | `PORT` (default 3000), `FLUENTD_HOST` (optional, enables a fluent log appender), `FLUENTD_TAGS` (optional, `tag:value,tag2:value2`). Both read in `index.js`. |
| Data / config paths | None. Stateless. Nothing is written to disk in `index.js` or the README. |
| Dependencies | `fluent-logger` is a git dependency (`github:theconnman/fluent-logger-node`), so the build needs git and GitHub access. Runtime needs outbound HTTPS to the Docker Hub API. |
| Chart facts | values.yaml (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/docker-hub-rss/values.yaml): `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`, `persistence: {}`, service and probes disabled. |
| arm64 | Upstream image digest list (Docker Hub `theconnman/docker-hub-rss` tag `latest`) has amd64 and arm64 manifests (last pushed 2025-12-27). Our build is arm64-native through buildx; the arm64 runtime test is UNVERIFIED. |

## 2. Target layout

- `apps/docker-hub-rss/Dockerfile`
- `apps/docker-hub-rss/docker-bake.hcl`
- `apps/docker-hub-rss/settings.yaml`
- `apps/docker-hub-rss/container-test.yaml`
- `apps/docker-hub-rss/start.sh` (thin `exec` wrapper; sets `PORT` default and runs `node index.js`)

No `defaults/`, `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base). The app source lives in `/app/docker-hub-rss/`, a read-only path; no `app/` directory is needed in the repo because the source is fetched in the build stage.

## 3. Base image

Runtime stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, following the draft's choice and the Node-app precedent `apps/budge` (which states the base ships Node 24). The porter table lists "Node → ubuntu"; the draft and budge use python-node, so this plan follows python-node. Confirm the node version in the base before the build (UNVERIFIED: the base's exact Node version).

Build stage: the same python-node image (it has npm and Node), so there is no second Node install. Closest siblings: `apps/budge` (node build on python-node), `apps/changedetection` (python-node).

## 4. Dockerfile

1. `FROM python-node@sha256:… AS build`, `ARG VERSION`, `USER root`.
2. Install `git` in the build stage only (needed for the `github:` dependency): `apt-get install -y --no-install-recommends git` (check first whether the base already has it).
3. Pin yarn 1 for the existing `yarn.lock`: `npm install -g yarn@1` (version UNVERIFIED for the current lockfile; check that `yarn install --frozen-lockfile` passes).
4. Fetch source: `curl -fL https://github.com/TheConnMan/docker-hub-rss/archive/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`, with `/tmp/src` created first.
5. `cd /tmp/src && yarn install --frozen-lockfile --production` (no dev deps). Caches go to `/tmp` via `ENV YARN_CACHE_FOLDER=/tmp/yarn` and `npm_config_cache=/tmp/npm`.
6. Final stage `FROM <python-node>`, `USER root`: `mkdir -p /app/docker-hub-rss && cp -a /tmp/src/. /app/docker-hub-rss/`, then `rm -rf /tmp/*` cleanup. Keep `apt` lists cleaned.
7. License: `install -D /tmp/src/LICENSE /usr/share/licenses/docker-hub-rss/LICENSE`.
8. `ENV PORT=3000 FLUENTD_HOST= FLUENTD_TAGS=` only where needed; keep defaults in `settings.yaml`, not the Dockerfile.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /app/docker-hub-rss
```

`VOLUME /config` is required by the template even though the app writes nothing there. Do not invent state in `/config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "docker-hub-rss"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/TheConnMan/docker-hub-rss currentValue=master
  default = "23c6d2db08ac4fb44f7204cadd56faa24bf5b51a"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/TheConnMan/docker-hub-rss"
}
```

Then the four standard targets (`image`, `image-local`, `image-all`) and `group "default" { targets = ["image-local"] }`, copied from `apps/budge/docker-bake.hcl`. Validate with `docker buildx bake --print` from `apps/docker-hub-rss/`. `ARG VERSION` in the Dockerfile must match the bake default exactly.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/TheConnMan/docker-hub-rss"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "3000"
    required: false
  - name: FLUENTD_HOST
    default: ""
    required: false
  - name: FLUENTD_TAGS
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Do not list `/config` as used by the app; it is required only by the template. The `FLUENTD_*` entries are optional; an empty default means the appender is off (`index.js` checks `FLUENTD_HOST` truthiness). `dependencies` is empty (no database).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-3000}"

cd /app/docker-hub-rss
echo "Starting docker-hub-rss on port ${PORT}"
exec node index.js
```

Idempotent, writes nothing, does not touch `/config`. It listens on `0.0.0.0` by default? `index.js` calls `app.listen(port)` with no host, which binds all interfaces (Node default `::`). Confirm in the test (UNVERIFIED for IPv4-only hosts). `exec` gives PID 1 the signals.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '3000'
http:
- port: '3000'
  path: /info
filePaths:
- /app/docker-hub-rss/index.js
- /app/docker-hub-rss/package.json
- /usr/share/licenses/docker-hub-rss/LICENSE
```

The `/info` path is the app's own helper endpoint and is the most stable probe (README). Confirm the HTTP status it returns without network access; if it calls Docker Hub, the probe may fail offline, so check the response before relying on it (UNVERIFIED). Every port in `settings.yaml` has a `tcp` probe.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Change in this image |
| --- | --- |
| Upstream runs as `nobody` in `/app` | Final stage runs as `apps` (`USER apps`); the source copy is `COPY --chmod=0755`, so no runtime writes are needed. |
| Chart runs as UID 0 with `readOnlyRootFilesystem: false` | Not copied. The app writes nothing, so `--read-only --tmpfs /tmp` is expected to pass. Verify in step 11. |
| `yarn install` cache | Build-stage only, `/tmp`. |
| Node/npm caches | `/tmp` only (`npm_config_cache`, `YARN_CACHE_FOLDER`). |
| `fluent-logger` git dependency | Build-stage only. No runtime git. |
| Outbound Docker Hub API | Runtime requires egress. Not a write path. |

Draft expectations reconciled: non-root is confirmed as possible (no state). Read-only rootfs is expected to work (no writes found). Privileged is not needed. No extra persistence.

## 10. Risks, caveats and open questions

- No tags or releases: Renovate tracks the `master` commit and bumps on every push. Consider a `limit` or a schedule in the renovate config (UNVERIFIED that the repo config allows it).
- Build reproducibility: the commit is pinned, but the git dependency `fluent-logger-node` is resolved from GitHub at build time. If GitHub is unreachable the build fails. No checksum for that dependency is published.
- The chart's `latest` digest may not match `master` HEAD. Confirm the source commit behind the digest before pinning (UNVERIFIED).
- Node version: upstream uses Node 22 (alpine). The python-node base's Node version is UNVERIFIED; the app's dependencies (`express@4`, `log4js@6`) should work on Node 24, but test it.
- Outbound network required at runtime (Docker Hub API). Container tests run without egress may return errors on `/r/...` routes; the test only covers `/info`.
- Blockers: none found (not musl-only, no GPU, no privileged, arm64 native build).

## 11. Build and test steps

```sh
cd apps/docker-hub-rss
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name docker-hub-rss-probe --read-only --tmpfs /tmp \
  -v docker-hub-rss-probe-config:/config docker-hub-rss:23c6d2db08ac4fb44f7204cadd56faa24bf5b51a
docker logs -f docker-hub-rss-probe
forgetool containers test --image docker-hub-rss:23c6d2db08ac4fb44f7204cadd56faa24bf5b51a \
  --config ./apps/docker-hub-rss/container-test.yaml
docker rm -f docker-hub-rss-probe; docker volume rm docker-hub-rss-probe-config
```

Expected readiness signal: `Docker RSS Feed listening on port 3000!` (from `index.js`). Also run once with `-p 3000:3000` and curl from the host to prove it is reachable beyond localhost. arm64 is untested until a build on an arm64 host or an `image-all` build.

## 12. PR checklist

- Branch `feat/add-docker-hub-rss`, commit and PR title `feat(docker-hub-rss): add new container`, target `main`.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; `license/cla` shows the status).
- PR Notes section includes `🤖 This PR is AI generated.`
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only applicable boxes.
- Say what is untested: the arm64 build and runtime, the source commit behind the chart digest, outbound Docker Hub calls, `/info` status code offline.
- `docker buildx bake --print` must pass; the bake `VERSION` must equal the Dockerfile `ARG VERSION`; no assertion weakened.
