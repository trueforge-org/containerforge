# redisinsight — implementation plan
> Source: ./draft.md · Target: apps/redisinsight/ · Difficulty: medium · Role: main · Verified on 2026-11-25

The draft's binary link is wrong. The AppImage files in the release are the Electron desktop app, not the Node.js server. This plan builds the server from the pinned source tag, as the upstream Dockerfile does, but on glibc instead of musl.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `3.10.2`. Latest release (https://github.com/redis/RedisInsight/releases/latest redirects to tag 3.10.2). Chart uses `3.10.1` (Hub, 2026-11-18). Draft binary link is `3.10.0`. |
| Renovate | `// renovate: datasource=github-releases depName=redis/RedisInsight versioning=semver` (convention; not fetched) |
| License | Repo LICENSE on `main` is Server Side Public License v1 (SSPL-1.0), https://raw.githubusercontent.com/RedisInsight/RedisInsight/main/LICENSE. GitHub API reports NOASSERTION. The LICENSE at the pinned tag is UNVERIFIED: check it before writing `docker-bake.hcl`. |
| Source URL | https://github.com/redis/RedisInsight. Tag tarball `https://github.com/redis/RedisInsight/archive/refs/tags/3.10.2.tar.gz` |
| Per-arch download | Not usable as a server binary. Release assets `Redis-Insight-linux-x86_64.AppImage` and `Redis-Insight-linux-arm64.AppImage` (https://github.com/redis/RedisInsight/releases/expanded_assets/3.10.2) are Electron desktop bundles. Build from the source tarball on both arches. |
| Checksum source | None published (no `.sha256` in the release assets). Source tarball checksum: UNVERIFIED; compute and pin it in the Dockerfile during the build step. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/RedisInsight/RedisInsight/ecd3e7452cac2438bf1a69df8b4e38fc973383dd/Dockerfile (node 24.22.2 alpine, two stages; `npm ci --ignore-scripts && npx patch-package`; `npm ci --prefix redisinsight/api`; `npm run build:ui`, `build:statics`, `build:api`; `npm ci --prefix redisinsight/api --omit=dev`; `EXPOSE 5540`; `USER node`) and `docker-entry.sh` (https://raw.githubusercontent.com/RedisInsight/RedisInsight/ecd3e7452cac2438bf1a69df8b4e38fc973383dd/docker-entry.sh, `exec "$@"`) |
| Port | `5540`, hard-coded (upstream Dockerfile comment and `EXPOSE`). |
| Env vars (real) | Set in the upstream Dockerfile: `NODE_ENV=production`, `RI_SERVE_STATICS=true`, `RI_BUILD_TYPE=DOCKER_ON_PREMISE`, `RI_APP_FOLDER_ABSOLUTE_PATH=/data`, build arg `RI_SEGMENT_WRITE_KEY` (telemetry key: do not bake a value). Other runtime variables: UNVERIFIED (not read in the fetched source). |
| Data path | `RI_APP_FOLDER_ABSOLUTE_PATH=/data` upstream (local DB, plugins, logs). ContainerForge: `/config`. |
| arm64 | Yes. Hub `redislabs/redisinsight:3.10.2` amd64 and arm64 (https://hub.docker.com/v2/repositories/redislabs/redisinsight/tags?page_size=100&name=3.10). |
| copy-from | `no`. The upstream image is musl (alpine + gcompat). Copying from it does not run on glibc Ubuntu. |
| Dependencies | None. Embedded local database under the app folder. |

## 2. Target layout

- `apps/redisinsight/Dockerfile`
- `apps/redisinsight/docker-bake.hcl`
- `apps/redisinsight/settings.yaml`
- `apps/redisinsight/container-test.yaml`
- `apps/redisinsight/start.sh`

No `defaults/`, `etc/`, `health/`, `root/`. `DOWNSTREAM_CHANGES.md` not needed (not a `FROM` base).

## 3. Base image

`ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` for the build stage and the final stage. It provides Node.js on glibc, which the Node server needs. Closest sibling: `apps/budge` (python-node, node app). Python is not used by this app; the python rules do not apply.

If the Node major version in `python-node` differs from upstream 24.x, record it in section 10 and check that `npm ci` works. Node version of this base: UNVERIFIED (not fetched; read it from the base's own build).

## 4. Dockerfile

1. `FROM <python-node> AS build`; `ARG VERSION`; `ARG TARGETARCH`; `USER root`.
2. `apt-get install -y --no-install-recommends build-essential python3` only if native modules need them and the base lacks them (check first, pin against `VERSION` if added). No gcompat (glibc build).
3. Fetch and verify the source: `curl -fsSL -o /tmp/ri.tar.gz https://github.com/redis/RedisInsight/archive/refs/tags/${VERSION}.tar.gz`, then `echo "<sha256>  /tmp/ri.tar.gz" | sha256sum -c -` with the checksum computed in the build step and recorded here. Extract to `/tmp/src` with `--strip-components=1`.
4. `cd /tmp/src`, then mirror the upstream steps: `npm ci --ignore-scripts && npx patch-package`; `npm ci --prefix redisinsight/api`; `npm run build:ui`; `npm run build:statics`; `npm run build:api`; `npm ci --prefix redisinsight/api --omit=dev`. Set `npm_config_cache=/tmp/npm`.
5. Final stage `FROM <python-node>`; `USER root` only for `mkdir`/`chown`; `apt-get` only if needed.
6. Copy the built tree to `/app/redisinsight`: `redisinsight/api/dist`, `redisinsight/api/node_modules`, `redisinsight/ui/dist`, and `docker-entry.sh` (or a `start.sh`). Keep `/app` read-only at runtime.
7. License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/redisinsight/LICENSE` (the upstream LICENSE file; verify SSPL text per section 1).
8. `ENV NODE_ENV=production RI_SERVE_STATICS=true RI_BUILD_TYPE=DOCKER_ON_PREMISE RI_APP_FOLDER_ABSOLUTE_PATH=/config`. Do not set `RI_SEGMENT_WRITE_KEY`.
9. `ENV npm_config_cache=/tmp/npm HOME=/config` (no caches in `/config`).
10. Tail:

```dockerfile
COPY --chmod=0755 . /
EXPOSE 5540
VOLUME /config
USER apps
```

Use `USER apps` (not `node`), per the Dockerfile rules. The upstream `USER node` is replaced.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "redisinsight"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=redis/RedisInsight versioning=semver
  default = "3.10.2"
}

variable "LICENSE" {
  default = "SSPL-1.0"
}

variable "SOURCE" {
  default = "https://github.com/redis/RedisInsight"
}
```

`LICENSE` must match the license of the pinned tag (section 1). Then the four standard targets and the default group, copied from `apps/budge/docker-bake.hcl` (python-node precedent). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/redis/RedisInsight"
ports:
  - port: 5540
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: RI_APP_FOLDER_ABSOLUTE_PATH
    default: "/config"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only add env vars the app really reads (`RI_APP_FOLDER_ABSOLUTE_PATH` is set upstream; the app reading it is UNVERIFIED at source level). Do not list `RI_SEGMENT_WRITE_KEY`. `required: true` on the port is a choice for the UI; a sibling Node app should be checked for consistency.

## 7. start.sh

- `set -eu`; `mkdir -p /config`. Nothing else to seed: the app creates its database under the data folder on first start (UNVERIFIED: confirm with an empty `/config`).
- Ensure `RI_APP_FOLDER_ABSOLUTE_PATH` points at `/config` (default from env).
- `cd /app/redisinsight`; `exec node redisinsight/api/dist/src/main` so signals reach Node.
- Bind to all interfaces: the app's listen host is UNVERIFIED (check `redisinsight/api` config for `0.0.0.0` vs `localhost`; if it binds localhost, set the upstream host variable and record it in `settings.yaml`).
- No writes under `/app`. Logs and caches go to `/config` (app data) or `/tmp` (caches).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=<same URL as siblings>
timeoutSeconds: 120
tcp:
  - port: '5540'
http:
  - port: '5540'
    path: /
filePaths:
  - /app/redisinsight/redisinsight/api/dist/src/main.js
  - /app/redisinsight/redisinsight/ui/dist
  - /usr/share/licenses/redisinsight/LICENSE
```

Port 5540 has tcp and http probes (coverage minimum). The `/` path returns the UI HTML if statics are served (`RI_SERVE_STATICS=true`). Confirm the path returns 200 in round 1; if the app redirects (EULA or setup), use the path that returns 200 and record the reason (UNVERIFIED). `timeoutSeconds` from sibling Node apps (check `apps/budge` or `apps/changedetection`).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (local DB, plugins, logs) | `/config` through `RI_APP_FOLDER_ABSOLUTE_PATH=/config` |
| npm cache during build | `/tmp/npm` |
| `HOME` | `/config` (no caches written there; set to `/tmp` if the app writes dotfiles: UNVERIFIED) |

Draft expectations reconciled: chart runs as UID 0 with `runAsNonRoot: false`. This image runs as `apps` and works with `readOnlyRootFilesystem` because `/app` and `/tmp` are the only other writable locations. Chart `readOnlyRootFilesystem: false` is therefore not required. Chart `privileged: false` matches.

## 10. Risks, caveats and open questions

- **Build cost:** the source build is heavy (three npm installs, native modules, UI and API builds). Expect a slow build in CI and high RAM use. The `npm ci` step may need more memory than the default runner.
- **Node version:** upstream pins `node:24.22.2` (alpine). The `python-node` base version must match or be compatible; UNVERIFIED.
- **Musl vs glibc:** upstream `gcompat` shim is an alpine detail. Native modules are rebuilt on glibc; confirm they load (`node -e "require(...)"` in the build step).
- **Telemetry:** `RI_SEGMENT_WRITE_KEY` is a build arg upstream. Leave it empty; do not bake a key.
- **Auth:** the UI has no auth by default (upstream docs https://redis.io/docs/latest/operate/redisinsight/ not fetched: UNVERIFIED). Say so in the PR; users should put it behind a reverse proxy.
- **EULA:** the first use asks for EULA acceptance in the UI (inferred from the draft; UNVERIFIED on a fetched page).
- **Licence:** SSPL-1.0 on `main` (section 1). Confirm the tagged LICENSE before merging.
- **Binary link:** the draft's AppImage link is a desktop bundle and is not used.

## 11. Build and test steps

```sh
cd apps/redisinsight
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name redisinsight-probe --read-only --tmpfs /tmp \
  -v redisinsight-probe-config:/config redisinsight:3.10.2
docker logs -f redisinsight-probe
forgetool containers test --image redisinsight:3.10.2 --config ./apps/redisinsight/container-test.yaml
docker rm -f redisinsight-probe; docker volume rm redisinsight-probe-config
```

Expected readiness signal: the Node server log with a line for listening on port 5540 (exact text UNVERIFIED; capture the first 100 lines in round 1). Confirm `/config` gets files after start and `/app` is unchanged. Confirm `curl -fsS http://localhost:5540/` returns 200 from outside the container with `-p 5540:5540`.

## 12. PR checklist

- Branch `feat/add-redisinsight`, commit and PR title `feat(redisinsight): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Say what was not tested: build on arm64, the runtime HTTP check on `/`, and the license text at the pinned tag.
- `docker buildx bake --print` must pass; bake `VERSION` equals Dockerfile `ARG VERSION`.
