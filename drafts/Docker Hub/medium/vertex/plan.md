# vertex — implementation plan
> Source: ./draft.md · Target: apps/vertex/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub releases (`api.github.com/repos/vertex-app/vertex/releases/latest` returns 404). Upstream pushes to `master` only; last push 2026-11-10. Pin a master commit SHA (resolve it at implementation time with `gh api repos/vertex-app/vertex/commits/master --jq .sha`; the SHA is not fixed in this plan). Docker Hub `lswl/vertex` has 41 tags (for example `stable`), but the TrueCharts draft tag is not a ContainerForge version. |
| Renovate | `datasource=git-refs depName=https://github.com/vertex-app/vertex currentValue=master` (same precedent as `apps/fenrus` and `apps/tvheadend`). UNVERIFIED: whether `currentValue=master` is needed with the commit-pinned tarball. |
| License | MIT (GitHub API `license.spdx_id`) |
| Source URL | https://github.com/vertex-app/vertex |
| Download | Source tarball `https://github.com/vertex-app/vertex/archive/${VERSION}.tar.gz` (VERSION = commit SHA). No prebuilt binary; the app is Node (`npm ci --omit=dev`). Same for amd64 and arm64. |
| Checksum source | None published. The tarball is content-addressed by commit SHA. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/vertex-app/vertex/master/docker/Dockerfile: two stages on `lswl/vertex-base:latest` (Alpine: `apk add gcc g++ python3 cmake make npm libc-dev`), `npm install --global npm@8.19.4`, `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm ci --omit=dev`, `EXPOSE 3000`, `CMD ["bash", "/app/vertex/docker/start.sh"]`, no `VOLUME`, no `USER`. |
| Port | 3000/tcp (EXPOSE 3000). |
| Env vars (real) | Only `TZ=Asia/Shanghai` is set by the upstream Dockerfile. Other variables are UNVERIFIED: `docker/start.sh` and `app/` config were not read in this run. |
| Data paths (upstream) | `/vertex` (created and `chown`ed to user `vt`), symlinked from `/app/vertex/app/data`, `/app/vertex/app/db`, `/app/vertex/logs`, `/app/vertex/torrents`, and `/app/vertex/app/config` (moved to `config_backup`, then `ln -s /vertex/config`). |
| Local services | Upstream appends `bind 127.0.0.1` and `daemonize yes` to `/app/redis.conf`, so the upstream image runs a local redis. UNVERIFIED: whether `start.sh` starts redis, and which package provides it on Ubuntu. |
| Browser | Upstream links `/usr/bin/chromium` to `/usr/bin/chromium-browser` (Puppeteer download skipped). UNVERIFIED: whether the app needs chromium at runtime for the features the chart uses. |
| apt | UNVERIFIED for Ubuntu 26.04 package names (`redis-server`, `chromium` availability). Check before pinning. |

## 2. Target layout

- `apps/vertex/Dockerfile`
- `apps/vertex/docker-bake.hcl`
- `apps/vertex/settings.yaml`
- `apps/vertex/container-test.yaml`
- `apps/vertex/start.sh` (replaces upstream `docker/start.sh`; written from scratch, not copied, because its contents were not read)
- `apps/vertex/app/` only if the app source is vendored there; the plan prefers fetching the source tarball in the build stage, so this is NOT needed.

No `defaults/` or `etc/`. No `root/`. No `DOWNSTREAM_CHANGES.md` (vertex is not a `FROM` base).

## 3. Base image

Runtime: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (node runtime included, see `apps/budge` for a python-node Node build). Build stage uses the same image, so no Alpine stage is needed.

Reason: the upstream build is Node-only. Choosing `python-node` follows the draft and the porter table (Node + Python in one base). The `ubuntu` base would also work (`npm` installed separately) and is the fallback if the `python-node` node version is too old for the vertex `package.json` engines field (UNVERIFIED: the engines field was not read).

Closest sibling: `apps/budge` (python-node, npm build, `/config` data, `start.sh` with `exec`).

## 4. Dockerfile

1. `ARG VERSION` (commit SHA) and `ARG TARGETARCH`. Keep the `docker-bake.hcl` default identical.
2. `FROM` python-node (digest as in section 3), `USER root`.
3. Build packages only when needed: native modules may need `build-essential python3 make g++` (apt). Install them with `--no-install-recommends` and purge them in the same `RUN`, as `apps/budge` does.
4. Redis (if `start.sh` needs it, see section 10): `apt-get install -y --no-install-recommends redis-server`, pinned against the Ubuntu archive version (UNVERIFIED package name).
5. Fetch and unpack source to `/app/vertex`:
   `curl -fL "https://github.com/vertex-app/vertex/archive/${VERSION}.tar.gz" -o /tmp/vertex.tar.gz && tar xzf /tmp/vertex.tar.gz -C /app/vertex --strip-components=1 && rm /tmp/vertex.tar.gz`
   Use `mkdir -p /app/vertex` first. Set `npm config set cache /tmp/npm-cache` so no cache is written to `/config`.
6. `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm ci --omit=dev` in `/app/vertex`, then `npm cache clean --force`. Remove `/tmp/*` and `/var/lib/apt/lists/*`.
7. License: `install -D /app/vertex/LICENSE /usr/share/licenses/vertex/LICENSE`.
8. Ownership: `chown -R apps:apps /app/vertex && chmod -R 755 /app/vertex` (same as `apps/adguardhome-sync`), so `/app` stays read-only at runtime.
9. `ENV HOME=/config TZ=Etc/UTC` (TZ overridden by `settings.yaml` default). Keep upstream `TZ=Asia/Shanghai` only if the user asks; the default is `Etc/UTC`.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /config
```

Step 5 also creates the upstream data symlinks, pointing into `/config` (`/app/vertex/app/data`, `db`, `config`, `/app/vertex/logs`, `torrents`), as dangling links until `start.sh` creates the targets. Their remaps are in section 9.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "vertex" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/vertex-app/vertex currentValue=master
  default = "<commit SHA resolved at implementation time>"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/vertex-app/vertex" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print` from `apps/vertex`. `ARG VERSION` in the Dockerfile must match this default exactly.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/vertex-app/vertex"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Port 3000 is confirmed by the upstream `EXPOSE`. Add env vars only after reading the app config and `start.sh` (UNVERIFIED: none confirmed in this run). Dependencies: none for the runtime plan (redis is bundled, not a sibling); add a `dependencies` entry only if redis is provided by another ContainerForge app (none found in this plan).

## 7. start.sh

Plan (to be validated when written):

```bash
#!/usr/bin/env bash
set -euo pipefail

# Persistent state under /config, created only when missing
mkdir -p /config/data /config/db /config/logs /config/torrents /config/config
# Seed the default config only when missing or empty (do not overwrite user state)
if [ ! -s /config/config/config.json ] && [ -d /app/vertex/app/config_backup ]; then
  cp -rn /app/vertex/app/config_backup/. /config/config/
fi

# The symlinks /app/vertex/app/{data,db,config} -> /config/... are created at build
# time in the Dockerfile (section 4, step 5), not here, because /app is read-only.

cd /app/vertex
exec node app/index.js --port 3000
```

Notes on this sketch:
- The entry point and the `node` command are UNVERIFIED. Read `/app/vertex/docker/start.sh` and `package.json` `scripts.start` from the pinned tarball before writing the real file. The upstream `CMD` is `bash /app/vertex/docker/start.sh`.
- `/app` is read-only at runtime, so the upstream symlinks (`/app/vertex/app/data -> /vertex/...`) must exist at build time pointing into `/config`. Create them in the Dockerfile `RUN` step (they are dangling until `start.sh` creates `/config/...`), as the `apps/fenrus` plan does. Do not create them in `start.sh`.
- If redis is used, `start.sh` starts `redis-server /app/redis.conf` (or a `/tmp` config) before the app. Use `/tmp` for redis data (`dir /tmp`).
- Bind `0.0.0.0` (see section 10 for the bind check).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
http:
- port: '3000'
  path: /
```

Add `filePaths` for `/app/vertex/package.json` and `/usr/share/licenses/vertex/LICENSE`. Use the sibling timeout (`apps/budge` uses no value; `apps/changedetection` uses 180). If the first `/` response is a redirect or a non-200 (UNVERIFIED), use the path that returns 200 and do not weaken the probe.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/vertex` (data, db, logs, torrents, config) | `/config/data`, `/config/db`, `/config/logs`, `/config/torrents`, `/config/config` (persistent, created in `start.sh` when missing) |
| `/app/vertex/app/config_backup` | Seeded into `/config/config` when missing; never written in `/app` |
| `/etc/localtime` symlink | Not needed; use `TZ` env |
| `/usr/bin/chromium` symlink | Not needed unless the chart features need it (UNVERIFIED) |
| `/app/redis.conf` append | Do not write it; if redis is used, pass a config under `/tmp` |
| npm cache | `/tmp/npm-cache` at build time; none at runtime |

Draft security expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. The image runs as `apps` (568) with `--read-only --tmpfs /tmp`, so `/config` is the only writable persistent path. Not privileged. The draft's "extra-persistence: /vertex" maps to `/config`, so existing data needs `/vertex/*` content moved to `/config/*` (document in the PR).

## 10. Risks, caveats and open questions

- No upstream release: builds change with every master push. Renovate on commits is noisy. Mitigation: pin the SHA and let renovate propose bumps.
- Upstream Dockerfile is Alpine (`lswl/vertex-base`, `apk`). Node native modules compiled on glibc (`python-node`) may differ. Verify `npm ci` succeeds on amd64 and arm64 (UNVERIFIED for arm64).
- Redis and chromium: whether the app needs them at runtime is UNVERIFIED. If yes, add the apt packages (pinned) and the start order in `start.sh`.
- Torrent daemon: peers and trackers need inbound ports. The container listens on 3000 only in this plan; BitTorrent ports are UNVERIFIED and not declared in settings.yaml.
- Blockers: none confirmed. No musl-only binary, no GPU, not privileged. Redis/chromium are the main unknowns.

## 11. Build and test steps

```sh
cd apps/vertex
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name vertex-probe --read-only --tmpfs /tmp \
  -v vertex-probe-config:/config vertex:<commit SHA>
docker logs -f vertex-probe
forgetool containers test --image vertex:<commit SHA> --config ./apps/vertex/container-test.yaml
docker rm -f vertex-probe; docker volume rm vertex-probe-config
```

Expected readiness signal: the Node/Express "listening" or app startup line on port 3000 (exact text UNVERIFIED until the app is run). Confirm `/config/data` is created on first start and reused on restart.

## 12. PR checklist

- Branch `feat/add-vertex`, commit `feat(vertex): add new container`, PR title `feat(vertex): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is needed (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Say what is untested: the build, the probe, arm64, and the redis/chromium assumptions unless they were actually run.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
