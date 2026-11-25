# audiobookshelf — implementation plan
> Source: ./draft.md · Target: apps/audiobookshelf/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2.38.0, published 2026-11-17 (https://api.github.com/repos/advplyr/audiobookshelf/releases/latest). Matches the chart tag `ghcr.io/advplyr/audiobookshelf:2.38.0`. |
| Renovate | `datasource=github-releases depName=advplyr/audiobookshelf versioning=semver` (versioning choice is our convention, UNVERIFIED upstream). |
| License | GPL-3.0 (GitHub repo metadata, https://api.github.com/repos/advplyr/audiobookshelf). |
| Source URL | https://github.com/advplyr/audiobookshelf |
| Binary | None. The v2.38.0 release has no attached assets, so the app is built from source. |
| Per-arch download | Source tarball https://github.com/advplyr/audiobookshelf/archive/refs/tags/v2.38.0.tar.gz (UNVERIFIED: the tag archive URL was not fetched). |
| Checksum source | None published (no release assets). Pin the tag and verify the extracted tree is the tag commit (UNVERIFIED how to pin the commit). |
| Upstream Dockerfile reviewed | Commit 1430c9fc642d586ff91c8d4cbed20aab2c47e473 (draft trace). Four stages, all `node:24-alpine` (musl). `build-client` runs `npm ci` and `npm run generate`. `compile-server` runs `npm run build:server` on `$BUILDPLATFORM`. `build-server` runs `npm ci --omit=dev` and downloads a per-arch nunicode-sqlite library zip (`libnusqlite3-linux-musl-x64.zip` and `libnusqlite3-linux-musl-arm64.zip`). Final stage installs `tzdata ffmpeg tini` with apk. |
| ENTRYPOINT / CMD | `ENTRYPOINT ["tini", "--"]`, `CMD ["node", "dist-server/index.js"]` (Dockerfile at the commit above). |
| USER | Not set upstream (runs as root). |
| EXPOSE / VOLUME | `EXPOSE 80`. No `VOLUME`. |
| Real env vars (from Dockerfile) | `NODE_ENV=production`, `PORT=80`, `CONFIG_PATH=/config`, `METADATA_PATH=/metadata`, `SOURCE=docker`, `NUSQLITE3_DIR=/usr/local/lib/nusqlite3`, `NUSQLITE3_PATH=/usr/local/lib/nusqlite3/libnusqlite3.so`. Other runtime env vars: UNVERIFIED (server source not read). |
| Data paths | `/config` (CONFIG_PATH), `/metadata` (METADATA_PATH). The audiobook library is a user mount (chart PVC); its path inside the app is UNVERIFIED. |
| Dependencies | None confirmed. The app embeds SQLite. |
| ffmpeg | Upstream uses Alpine `apk add ffmpeg`. On ubuntu it is the apt package `ffmpeg`. Availability on ubuntu 26.04 is UNVERIFIED (check with `apt-cache policy ffmpeg` in the build). |
| arm64 | The Dockerfile has arch logic only for the nunicode-sqlite download. Published arm64 image: UNVERIFIED. |

## 2. Target layout

- `apps/audiobookshelf/Dockerfile`
- `apps/audiobookshelf/docker-bake.hcl`
- `apps/audiobookshelf/settings.yaml`
- `apps/audiobookshelf/container-test.yaml`
- `apps/audiobookshelf/start.sh`

No `defaults/`, `etc/` or `health/` unless the build proves they are needed. Never use `root/`. No `DOWNSTREAM_CHANGES.md` (the app is not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Reason: the app is a Node server, and the base provides Node and Python on the ubuntu userland. The draft named python-node, and sibling `apps/budge` uses the same base for an npm build. Node 24 is required by the upstream build. Confirm the node version in the pinned base with `node --version` in step 2 of the build (UNVERIFIED). If the base has an older Node, pin Node 24 in the build stage instead.

Closest siblings: `apps/budge` (python-node, npm build, `/app` plus `/config`) and `apps/bazarr` (layout reference).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`. Build stage `FROM <python-node> AS build` with `USER root`.
2. Install build deps with apt: `apt-get install -y --no-install-recommends ffmpeg` in the final stage only; build stage needs `build-essential python3` only if a native module has no prebuilt binary (UNVERIFIED, see section 10).
3. Download the source at the tag. Use the same URL pattern as `apps/budge`:
   `curl -fL -o /tmp/abs.tar.gz "https://github.com/advplyr/audiobookshelf/archive/refs/tags/v${VERSION}.tar.gz"` then `tar xf /tmp/abs.tar.gz -C /tmp/src --strip-components=1`. The `v` prefix matters: the tag is `v2.38.0` while `VERSION` is `2.38.0`.
4. Client build: `cd /tmp/src/client && npm ci && npm run generate` (client script names as in the upstream Dockerfile; UNVERIFIED for the tag).
5. Server build: `cd /tmp/src && npm ci --include=dev --ignore-scripts && npm run build:server`, then `npm ci --omit=dev` in the same tree.
6. nunicode-sqlite: the upstream zip is musl-only and cannot be used on glibc ubuntu. Do not copy it. Confirm at build time whether the server runs without `NUSQLITE3_PATH` (UNVERIFIED). If it needs the library, that is a blocker (section 10).
7. Final stage: `FROM <python-node>` again (or the same base), `USER root`, `apt-get install -y --no-install-recommends ffmpeg tini tzdata`, then clean apt lists.
8. `mkdir -p /app/audiobookshelf` and `COPY --from=build /tmp/src/dist-server /app/audiobookshelf/dist-server`, `/tmp/src/client/dist /app/audiobookshelf/client/dist`, `/tmp/src/node_modules`, `/tmp/src/package.json`. License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/audiobookshelf/LICENSE`.
9. ENV (`/app` stays read-only): `NODE_ENV=production`, `CONFIG_PATH=/config`, `METADATA_PATH=/metadata`, `SOURCE=docker`, `HOME=/config`, `XDG_CACHE_HOME=/tmp`, `PORT` set to the chosen port (section 9).
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE <port>
VOLUME /config
WORKDIR /app/audiobookshelf
```

Add `/metadata` as a second volume only if the chart needs it. The upstream image does not declare it, so set `VOLUME /config` only and keep `/metadata` as a path under `/config` (see section 9).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "audiobookshelf" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=advplyr/audiobookshelf versioning=semver
  default = "2.38.0"
}
variable "LICENSE" { default = "GPL-3.0" }
variable "SOURCE" { default = "https://github.com/advplyr/audiobookshelf" }
```

Four standard targets and the default group copied from `apps/budge/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/advplyr/audiobookshelf"
ports:
  - port: <chosen port>
    protocol: tcp
    required: true
env:
  - name: PORT
    default: "<chosen port>"
    required: false
  - name: CONFIG_PATH
    default: "/config"
    required: false
  - name: METADATA_PATH
    default: "/config/metadata"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only list env vars the app reads and that `start.sh` uses. Do not add the nunicode variables unless the server reads them (UNVERIFIED). The port must match section 9.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config /config/metadata
cd /app/audiobookshelf
exec node dist-server/index.js
```

- Idempotent. Seeds nothing: Audiobookshelf creates its own database and config under `/config` on first start (UNVERIFIED for the tag).
- Writes only under `/config`. Caches go to `/tmp` through `XDG_CACHE_HOME`.
- Bind address: the server must listen on all interfaces. Check the listen call in the source at the tag (UNVERIFIED) and add `HOST=0.0.0.0` only if the server reads it.
- The final `exec` keeps tini as PID 1 (`ENTRYPOINT` in the Dockerfile).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '<chosen port>'
http:
- port: '<chosen port>'
  path: /
filePaths:
- /app/audiobookshelf/dist-server/index.js
- /app/audiobookshelf/client/dist/index.html
- /usr/share/licenses/audiobookshelf/LICENSE
```

- Every port in `settings.yaml` has a `tcp` probe. The `http` probe on `/` is expected to return a 200 for the web UI (UNVERIFIED; confirm with a local run and use a path that returns 200 if `/` redirects).
- `timeoutSeconds: 120` because the Node server and first-run database setup take time. Check the value against a Node sibling such as `apps/budge` before committing.
- The test runs with no env vars, so no required-env code paths are covered. Node paths for `NUSQLITE3_PATH` (if any) go to `filePaths`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (CONFIG_PATH; database, settings, metadata cache) | Stays `/config`, which is the persistent volume. |
| `/metadata` (METADATA_PATH; covers, metadata) | Remap to `/config/metadata` through `METADATA_PATH` so the chart PVC covers it. |
| Audiobook library (`/audiobooks` in the chart) | User mount, read-only where possible. Not written by this container except for uploads. |
| Node/npm and yt-dlp caches | `/tmp` through `XDG_CACHE_HOME=/tmp` and `HOME=/config` (not a cache path). |
| `/app/audiobookshelf` | Read-only at runtime. The build writes only to `/tmp/src` and to the copied tree. |

- Port 80 is below 1024. A rootless `apps` user cannot bind it. Choose a port above 1024 (for example 8000, which is our convention, UNVERIFIED) and set both `PORT` and `EXPOSE`, `settings.yaml`, `container-test.yaml` to it. Record the change in the PR. Do not use `ip_unprivileged_port_start` in the image.
- The draft's expectation that the chart sets `readOnlyRootFilesystem: false` is compatible with this plan: the image supports `--read-only --tmpfs /tmp` with a fresh `/config`.
- `PUID` and `PGID` from the chart are not read by the image (the Dockerfile sets no such env, UNVERIFIED). Do not add them.
- No `privileged` or extra capabilities are needed (draft: privileged no, confirmed by the upstream Dockerfile having no capability setup).

## 10. Risks, caveats and open questions

- Draft caveat confirmed: ffmpeg is needed at runtime. Transcoding and library scans use CPU and RAM (inferred).
- Draft caveat confirmed: the initial admin user is created in the web UI on first start (inferred, UNVERIFIED for 2.38.0).
- Blocker candidate: the upstream sqlite helper (`nusqlite3`) is musl-only. If the server requires it on glibc, the image cannot be built from the upstream libraries. Open question for the builder: does the server fall back to a standard sqlite binding when `NUSQLITE3_PATH` is absent? Check in the source at v2.38.0 before writing the Dockerfile.
- Draft's `apt: ffmpeg` is confirmed as an option, but ubuntu 26.04 package availability is UNVERIFIED.
- Upstream Dockerfile is Alpine-based and runs as root. The ubuntu port is a rewrite of the install steps, not a copy.
- The draft named port 80 (inferred). Upstream is `PORT=80` (confirmed). The rootless change to a higher port is a deviation from upstream and must be visible in the PR.
- arm64: no published arm64 image was confirmed. Build arm64 only if the amd64 build is clean (protocol section 2).

## 11. Build and test steps

From `apps/audiobookshelf/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run, with a fresh empty `/config` volume:

```sh
docker volume create audiobookshelf-probe-config
docker run --rm -d --name audiobookshelf-probe --read-only --tmpfs /tmp \
  -v audiobookshelf-probe-config:/config audiobookshelf:2.38.0
docker logs -f audiobookshelf-probe
```

   Expected readiness signal: a startup line from the server naming the chosen port (exact text UNVERIFIED; take it from the first real run). The container must still be running, with no fatal errors.
4. `forgetool containers test --image audiobookshelf:2.38.0 --config ./container-test.yaml`, or the manual checks if forgetool is unavailable.
5. Clean up: `docker rm -f audiobookshelf-probe; docker volume rm audiobookshelf-probe-config`.

Not tested here: arm64, the database-dependent path (none expected), and the audiobook library mount.

## 12. PR checklist

- Branch: `feat/add-audiobookshelf`.
- Commit: `feat(audiobookshelf): add new container`.
- PR title: `feat(audiobookshelf): add new container`.
- PR body: use `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Say what was not tested: arm64 build, the upstream sqlite helper, and any path not covered by `container-test.yaml`. Do not check "Built container locally" unless the image was built.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- Conventional commit scope `audiobookshelf` for every commit.
