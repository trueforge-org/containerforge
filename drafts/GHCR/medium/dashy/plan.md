# dashy — implementation plan
> Source: ./draft.md · Target: apps/dashy/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **4.10.0** (latest, not prerelease, published 2026-11-22). Draft pins 4.9.0, which is outdated. Source: https://api.github.com/repos/lissy93/dashy/releases/latest |
| Renovate | `datasource=github-releases depName=Lissy93/dashy versioning=semver` |
| License | MIT (GitHub API `license.spdx_id` = `MIT`, https://api.github.com/repos/Lissy93/dashy) |
| Source URL | https://github.com/Lissy93/dashy |
| Download | https://github.com/lissy93/dashy/releases/download/4.10.0/dashy-4.10.0.tar.gz (same for amd64 and arm64: not an arch-specific binary) |
| Checksum source | https://github.com/lissy93/dashy/releases/download/4.10.0/dashy-4.10.0.tar.gz.sha256 (also a provenance file `.tar.gz.intoto.jsonl`, not verified by us) |
| Contents of the tarball | UNVERIFIED: whether it holds source or a prebuilt `dist/`. Plan assumes source (builder stage runs `yarn install --frozen-lockfile` and `yarn build`, as upstream does). Confirm on first download and adjust the build stage if `dist/` is already present. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/Lissy93/dashy/master/Dockerfile: three stages on `node:24-alpine`, `yarn install --frozen-lockfile`, `yarn build`, final stage copies `node_modules` (prod), `dist`, `public`, `services`, `server.js`, `package.json`, config schema, `user-data/conf.yml`. Final: `ENV NODE_ENV=production IS_DOCKER=true PORT=8080`, `EXPOSE 8080`, `USER 1000:1000`, `ENTRYPOINT ["/sbin/tini", "--"]`, `CMD ["node", "server.js"]`, HEALTHCHECK `node services/healthcheck.js`, no VOLUME. |
| Ports | 8080/tcp (`EXPOSE 8080`, `PORT=8080`) |
| Env vars (real) | `NODE_ENV`, `IS_DOCKER`, `PORT` (from upstream Dockerfile). Further vars read by the server are UNVERIFIED: not fetched in this run. |
| Data write paths | `user-data/` (holds `conf.yml`, written when the user saves config in the UI). Icons: chart persists `/app/public/item-icons` (draft). Whether upstream writes icons at runtime: UNVERIFIED. |
| arm64 | Yes: pure JS/Node, no arch-specific binary. Node 24 on arm64 is the upstream assumption. |
| copy-from | no (upstream image is musl/alpine, `node:24-alpine`, not usable on glibc Ubuntu) |
| Upstream image | `ghcr.io/lissy93/dashy:latest` (chart tag). Chart tag drift vs pinned 4.10.0: noted in section 10. |

## 2. Target layout

- `apps/dashy/Dockerfile`
- `apps/dashy/docker-bake.hcl`
- `apps/dashy/settings.yaml`
- `apps/dashy/container-test.yaml`
- `apps/dashy/start.sh`

No `defaults/`, `etc/`, `health/` needed unless the default `conf.yml` must be seeded (see section 7). Never `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

Build stage and final stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`.

Why: the draft's runtime is Node, and `python-node` is the ContainerForge base that carries Node, so no extra Node install is needed in the final stage. Closest siblings: `apps/changedetection` and `apps/budge` (python-node base with a Node frontend).

UNVERIFIED: the exact Node major shipped in `python-node:3.15.2` (must be 24 or newer to match upstream `node:24`). Check with `docker run --rm <image> node --version` before writing the Dockerfile. Also UNVERIFIED: whether `yarn` is present. If not, use `corepack enable` in the build stage (as root, writes to /usr/local, not /app) or `npm i -g yarn@<pinned>`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (not needed for the code itself; used only for OCI labels if present in siblings).
2. Build stage `FROM <python-node> AS build`, `USER root`.
3. `ENV YARN_CACHE_FOLDER=/tmp/yarn NPM_CONFIG_CACHE=/tmp/npm DO_NOT_TRACK=1`. All caches to `/tmp`, never `/config` or `/app`.
4. Fetch the release tarball and verify it against the published checksum, then extract to `/tmp/src`:
   ```dockerfile
   RUN set -eux; \
       mkdir -p /tmp/src; \
       curl -fsSL -o /tmp/dashy.tar.gz "https://github.com/Lissy93/dashy/releases/download/${VERSION}/dashy-${VERSION}.tar.gz"; \
       curl -fsSL -o /tmp/dashy.tar.gz.sha256 "https://github.com/Lissy93/dashy/releases/download/${VERSION}/dashy-${VERSION}.tar.gz.sha256"; \
       (cd /tmp && sha256sum -c dashy.tar.gz.sha256); \
       tar -xzf /tmp/dashy.tar.gz -C /tmp/src --strip-components=1
   ```
   The `.sha256` file format must be confirmed on the first download (it may name a different filename; adjust `sha256sum -c` accordingly).
5. `cd /tmp/src && yarn install --frozen-lockfile --network-timeout 600000 && yarn build`.
6. Production deps in a separate step: `yarn install --production --frozen-lockfile --network-timeout 600000 && yarn cache clean` (as in upstream `deps` stage).
7. Final stage `FROM <python-node>` (same digest), `USER root`:
   - `mkdir -p /app/dashy`, `COPY --from=build --chown=root:root /tmp/src/dist /app/dashy/dist` and the same for `public`, `services`, `server.js`, `package.json`, the config schema, and `node_modules` from the prod-deps step. Exact file list: copy what upstream's final stage copies (section 1).
   - License: `install -Dm0644 /tmp/src/LICENSE /usr/share/licenses/dashy/LICENSE` (ship the upstream LICENSE in `/usr/share/licenses/<app>/`).
   - `ln -s /config/user-data /app/dashy/user-data` (upstream writes config here; symlink so writes land in `/config`). Dangling until `start.sh` creates `/config/user-data`.
   - Optional icons: `ln -s /config/item-icons /app/dashy/public/item-icons` (draft/chart path; confirm the write path with a run before keeping it).
   - `ENV NODE_ENV=production IS_DOCKER=true PORT=8080`.
   - No `tini` needed if `start.sh` `exec`s node, since `tini` is only the upstream PID 1 helper. Decision: keep `start.sh` `exec` and skip tini; mention in section 10 if signals misbehave.
8. Ownership and mode: `chown -R root:root /app/dashy && chmod -R 0755 /app/dashy` (read-only at runtime, `apps` cannot write).
9. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8080
   VOLUME /config
   WORKDIR /app/dashy
   ```
   `WORKDIR` matches the app root so `node server.js` resolves `dist`, `public` and `user-data` relatively.

Build-time only: no apt packages are needed (the base already has curl and tar; `python-node` provides Node and npm).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "dashy"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Lissy93/dashy versioning=semver
  default = "4.10.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Lissy93/dashy"
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

Renovate sets VERSION; Dockerfile `ARG VERSION` must be 4.10.0 too. Validate with `docker buildx bake --print` from `apps/dashy`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Lissy93/dashy"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: PORT
    default: "8080"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Only `PORT` is confirmed (upstream Dockerfile). `NODE_ENV` and `IS_DOCKER` are set by the image, not user-facing; do not list them. Any further env vars the server reads: UNVERIFIED, add only after reading the upstream source.
- Dependencies: none (no database; upstream is a stateless dashboard that stores config in `user-data/conf.yml`).
- Note: `PORT` must match the port in `container-test.yaml`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export HOME=/tmp

mkdir -p /config/user-data /config/item-icons

port="${PORT:-8080}"
export PORT="${port}"

cd /app/dashy
exec node server.js
```

- Idempotent: creates only the missing directories under `/config`. Does not overwrite `conf.yml`. Empty `/config` works: the dashboard starts with its built-in defaults until the user saves a config in the UI.
- Seeding: a default `conf.yml` is NOT seeded by default (upstream ships `user-data/conf.yml` in the image). Decision for the writer: copy `/app/dashy/user-data/conf.yml` to `/config/user-data/conf.yml` only if it is missing, and only if the server fails to start without it (verify on the empty-`/config` run in section 11).
- Server binds all interfaces: `server.js` must listen on `0.0.0.0` (UNVERIFIED: confirm in the run, connect from the host network as the network check in section 11).
- Writes: `/config` only. `HOME=/tmp` keeps any tool caches out of `/config`.
- Process model: `exec node server.js` so signals reach node (see section 4, step 7 on tini).

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
- /app/dashy/server.js
- /app/dashy/dist
- /usr/share/licenses/dashy/LICENSE
```

- One tcp and one http probe for port 8080 (the only port in `settings.yaml`).
- `timeoutSeconds` 120: Node + Vue start is quick, but the image has no build step at runtime; 120 matches typical Node siblings (check `apps/changedetection/container-test.yaml` for the family value and align if different).
- No required env vars are needed to start, so no `filePaths` entries for env-only code paths.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/dashy/user-data` (config saved from UI) | symlink to `/config/user-data` |
| `/app/dashy/public/item-icons` (chart PVC) | symlink to `/config/item-icons` (write path UNVERIFIED: confirm in run) |
| npm/yarn caches (build only) | `/tmp` |
| Node runtime temp | `HOME=/tmp` |

Draft expectations reconciled:
- Draft says non-root: already met. Upstream runs as `USER 1000:1000`; the ContainerForge image runs as `apps`. No `usermod` or root wrapper needed.
- Draft says `readOnlyRootFilesystem` is possible: this plan keeps `/app` read-only and writes only to `/config` and `/tmp`, so `--read-only --tmpfs /tmp` should work (proved in section 11).
- Not privileged. No extra security settings.
- The chart persists `/app/public/item-icons`: this plan maps that to `/config/item-icons`, so existing chart users must move their icons into `/config/item-icons` (note in PR).

## 10. Risks, caveats and open questions

- Version drift: chart tag is `latest`, draft binary pins 4.9.0, and the current release is 4.10.0. Pin 4.10.0 and call out that the chart's `latest` may be newer.
- UNVERIFIED: whether the release tarball contains source or dist (section 1). Affects the build stage.
- UNVERIFIED: the Node major in `python-node:3.15.2` (section 3). Upstream targets Node 24.
- UNVERIFIED: `.sha256` file format (section 4, step 4).
- UNVERIFIED: whether dashy writes to `public/item-icons` at runtime.
- Signals: upstream uses `tini` as PID 1. Plan execs node directly. If the container does not exit on SIGTERM, add `tini` from apt (not in base; pin version against the Ubuntu archive) to the final stage.
- Frontend build is large (many npm deps, slow first build): expected, not a blocker.
- No blockers: no musl-only dependency in the app itself, no GPU, no privileged needs, arm64 supported.

## 11. Build and test steps

```sh
cd apps/dashy
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name dashy-probe --read-only --tmpfs /tmp \
  -p 8080:8080 \
  -v dashy-probe-config:/config dashy:4.10.0
docker logs -f dashy-probe
curl -fsS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/
docker rm -f dashy-probe; docker volume rm dashy-probe-config

forgetool containers test --image dashy:4.10.0 --config ./apps/dashy/container-test.yaml
```

- Expected readiness signal: node logs listening on port 8080 (exact line UNVERIFIED: confirm from the first run) and no crash loop. HTTP `/` returns 200 with a fresh empty `/config`.
- Also run once with a saved `conf.yml` written from the UI to prove `/config/user-data` persistence across a restart (reuse the volume).
- Network check: run with `-p 8080:8080` and curl from the host (not from inside the container) to confirm bind to all interfaces.
- Health check: upstream has a HEALTHCHECK; decide whether to keep it (not in section 4; the platform tests are the readiness check).

## 12. PR checklist

- Branch `feat/add-dashy`, commit `feat(dashy): add new container`, PR title matches, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it; `license/cla` shows the status.
- Note the chart item-icons migration (section 9).
- Untested to say in the PR: arm64 run, the Node version of the base, the `.sha256` format, the icons write path, the exact readiness log line, and any run with the chart's own values.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION` (4.10.0).
