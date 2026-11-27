# snippet-box — implementation plan
> Source: ./draft.md · Target: apps/snippet-box/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub releases (API 404) and no GitHub tags readable (API rate-limited). Docker Hub has three tags, none used by the draft: `latest` (2021-10-14, amd64), `dev` (2021-11-18, amd64/arm64/arm), `arm` (2021-10-14, arm64/arm). Pin the master commit `f501941a22ead0fccd196d109098e9b065205d98` (the commit the draft's Dockerfile link uses). The repo's last push is 2023-04-05. Source: https://api.github.com/repos/pawelmalak/snippet-box (via `gh api`). |
| Renovate | `datasource=git-refs depName=https://github.com/pawelmalak/snippet-box currentValue=master` (precedent: `apps/tvheadend`; `apps/fenrus` does not exist yet, it is only a plan) |
| License | MIT (GitHub API `license.spdx_id`) |
| Source URL | https://github.com/pawelmalak/snippet-box |
| Download | Source tarball `https://github.com/pawelmalak/snippet-box/archive/${VERSION}.tar.gz` (VERSION = commit SHA). No prebuilt binary; interpreted Node app built on the image. |
| Checksum source | None published. The tarball is content-addressed by the commit SHA. |
| Upstream Dockerfile reviewed | `FROM node:14-alpine`, `WORKDIR /app`, `COPY package*.json`, `COPY . .`, `RUN npm install`, client `npm install` and `npm rebuild node-sass`, `npm run build`, `npm prune --production`, `ENV NODE_ENV=production`, `EXPOSE 5000`, `CMD ["node","build/server.js"]`. Source: https://raw.githubusercontent.com/pawelmalak/snippet-box/f501941a22ead0fccd196d109098e9b065205d98/Dockerfile. Upstream `Dockerfile.arm` is also `node:14-alpine`. |
| Port | `PORT` env, default `5000` (`src/index.ts`). The chart uses `5039`: its value is not confirmed as a container port (UNVERIFIED how the chart sets it). |
| Env vars (real) | `PORT` (read by `src/index.ts`), `NODE_ENV` (`src/db/index.ts` checks `development`). |
| Data path | Sequelize SQLite, `storage: 'data/db.sqlite3'` relative to the working directory (`src/db/index.ts`). Chart mount `/app/data`. |
| Dependencies | None (embedded SQLite). |
| Blockers | Upstream is Node 14 (EOL). `node-sass` (client) and `sqlite3` (server) are native modules that must compile on the target Node. Repo not updated since 2023-04. |
| UNVERIFIED | (a) the Node major in `ghcr.io/trueforge-org/python-node:3.15.2` (no `apps/python-node` in this repo; check with `docker run --rm <base> node -v` in the build step); (b) whether `node-sass` builds on that Node major; (c) the `PORT` value the chart uses (5039). |

## 2. Target layout

- `apps/snippet-box/Dockerfile`
- `apps/snippet-box/docker-bake.hcl`
- `apps/snippet-box/settings.yaml`
- `apps/snippet-box/container-test.yaml`
- `apps/snippet-box/start.sh`

No `defaults/`, `etc/` or `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Final and build stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`. It provides Node and npm, as `budge` and `changedetection` use it. Closest sibling: `apps/budge` (Node build in the image, `/config` as writable data, `WORKDIR /config`). The Node major of this base is UNVERIFIED (section 1). If it is not compatible, the fallback is the ubuntu base with a pinned Node install, which is a larger change and needs a separate decision.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install build tools for the native modules, as `budge` does: `apt-get install -y --no-install-recommends build-essential python3 python3-dev python-is-python3`.
3. Fetch the source at the pinned commit with the `budge` pattern: `curl -fL -o /tmp/snippet-box.tar.gz "https://github.com/pawelmalak/snippet-box/archive/${VERSION}.tar.gz"`, then `tar xf ... -C /app/snippet-box --strip-components=1`.
4. Server deps and build: `cd /app/snippet-box && npm install && npm run build && npm prune --omit=dev`. `npm run build` runs `build:client` (React) and `build:tsc`.
5. Client deps are installed by `build:client` through `npm --prefix=client`. If `node-sass` fails on the chosen Node, stop and ask: the fix is a dependency change (`node-sass` to `sass`), which needs approval because it changes upstream code.
6. Data redirect (build time, as root): `mkdir -p /config/data` is not possible at build time for a volume, so create the link: `ln -s /config/data /app/snippet-box/data`. `start.sh` creates `/config/data`.
7. License: `mkdir -p /usr/share/licenses/snippet-box && cp LICENCE.md /usr/share/licenses/snippet-box/LICENSE.md` (UNVERIFIED: upstream file is believed to be `LICENCE.md`; confirm the exact source filename in the tarball. The target name `LICENSE.md` matches `container-test.yaml`).
8. Ownership: `chown -R apps:apps /app/snippet-box`, `chmod -R 755 /app/snippet-box`.
9. Clean: `npm cache clean --force`, `apt-get purge -y --auto-remove build-essential python3-dev`, `rm -rf /tmp/* $HOME/.cache /var/lib/apt/lists/*`.
10. Tail:

```dockerfile
ENV NODE_ENV=production PORT=5000 HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 5000
VOLUME /config
WORKDIR /app/snippet-box
```

`WORKDIR /app/snippet-box` so the relative `data/db.sqlite3` resolves through the symlink to `/config/data`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "snippet-box" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/pawelmalak/snippet-box currentValue=master
  default = "f501941a22ead0fccd196d109098e9b065205d98"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/pawelmalak/snippet-box" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`. The `Dockerfile` reads the same value through `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/pawelmalak/snippet-box"
ports:
  - port: 5000
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "5000"
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
```

Port 5000 is upstream's default. The chart's 5039 is a mismatch to resolve (section 10). Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data

export PORT="${PORT:-5000}"
export NODE_ENV="${NODE_ENV:-production}"

cd /app/snippet-box
echo "Starting snippet-box on port ${PORT}"
exec node build/server.js
```

Idempotent: it only creates `/config/data`, and SQLite creates `db.sqlite3` on first run. Nothing is written under `/app`. `exec` for signal handling. The server listens on `process.env.PORT` through `app.listen(PORT)` with no host, which binds all interfaces (UNVERIFIED: confirm in the built output).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5000'
http:
- port: '5000'
  path: /
filePaths:
- /app/snippet-box/build/server.js
- /usr/share/licenses/snippet-box/LICENSE.md
```

Every settings.yaml port has a probe. The `http` path is UNVERIFIED: the root may serve the React client or redirect; use the status the probe sees. No required env var code path.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `data/db.sqlite3` (relative, `/app/data` in the chart) | build-time symlink `/app/snippet-box/data` to `/config/data` |
| npm and native build caches | removed in the build stage, never in the final image |

Draft expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. The image is designed to run as `apps` with `--read-only --tmpfs /tmp`, which removes the need for root. Users migrating from the chart must move `/app/data` content to `/config/data`.

## 10. Risks, caveats and open questions

- Node 14 is EOL and the image needs a Node major that the repo's dependencies compile on. Check `node -v` in the base, and verify `node-sass` and `sqlite3` build. If they do not, the port is blocked until a dependency change is approved.
- Unpinned upstream: the chart uses `latest`, and this plan pins a 2023 commit. The repo has had no pushes since 2023-04-05, so there will be no security updates.
- Port mismatch: upstream default is 5000, the chart uses 5039. Confirm how the chart sets `PORT` before choosing the default; the plan keeps 5000 to match the upstream image.
- The `ln -s` data redirect is only correct if the app reads `data/` relative to the working directory (confirmed for `src/db/index.ts`; the app's `cwd` is set by `WORKDIR`).
- Blockers: none confirmed beyond the native module build and the EOL Node base.

## 11. Build and test steps

```sh
cd apps/snippet-box
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name snippet-box-probe --read-only --tmpfs /tmp \
  -v snippet-box-probe-config:/config snippet-box:f501941a22ead0fccd196d109098e9b065205d98
docker logs -f snippet-box-probe
forgetool containers test --image snippet-box:f501941a22ead0fccd196d109098e9b065205d98 --config ./apps/snippet-box/container-test.yaml
docker rm -f snippet-box-probe; docker volume rm snippet-box-probe-config
```

Readiness: the process stays up and logs a listen line on port 5000 (exact text UNVERIFIED until a run). Check `/config/data/db.sqlite3` exists after start.

## 12. PR checklist

- Branch `feat/add-snippet-box`, commit and PR title `feat(snippet-box): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the Node major of the base, the native module builds, the `--read-only` run, the probe paths, and arm64.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`.
