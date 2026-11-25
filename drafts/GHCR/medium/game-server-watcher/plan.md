# game-server-watcher — implementation plan
> Source: ./draft.md · Target: apps/game-server-watcher/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 3.1.26. Git tag `v3.1.26` -> commit `2010cd81bc2354d7b3ad10dabd44e340440ac3a5`. `package.json` at that commit says `3.1.26`. No GitHub Release object exists (`releases/latest` returns 404). Tag date: UNVERIFIED. |
| Renovate | `datasource=github-tags depName=a-sync/game-server-watcher versioning=semver` (tags are `v`-prefixed; the bake `VERSION` is `3.1.26`, so the annotation must handle the `v` prefix). |
| License | AGPL-3.0 per GitHub API; `package.json` says `AGPL-3.0-or-later`. Use `AGPL-3.0-or-later`. |
| Source URL | https://github.com/a-sync/game-server-watcher |
| Binary | No prebuilt binary. Build from the tag tarball `https://github.com/a-sync/game-server-watcher/archive/refs/tags/v${VERSION}.tar.gz`. |
| npm package | WARNING: the draft's `npm:game-server-watcher` is not this project. `npm view game-server-watcher@3.1.26` returns E404, and the `latest` package is an unrelated `0.0.0` ISC package. Do not install from npm. |
| Checksum | None published. Pin the tag commit `2010cd81...` and verify the tarball against it. |
| Upstream Dockerfile | https://raw.githubusercontent.com/a-sync/game-server-watcher/2010cd81bc2354d7b3ad10dabd44e340440ac3a5/Dockerfile: `node:20` base; builder runs `npm ci --include=dev`, `npm run build` (tsc), `rm -rf node_modules`; final `npm ci --omit=dev`; `ENV NODE_ENV=production`; `EXPOSE 8080`; no USER (root); no VOLUME; `CMD ["npm","run","start"]` (= `node ./dist/server.js`). |
| Engines | `node >=16.20.0` (package.json) |
| Dependencies | gamedig, discord.js, grammy, @slack/bolt, lowdb (JSON state), neoip; optional native builds bufferutil, zlib-sync, utf-8-validate, and `erlpack` from `github:discord/erlpack` (optional, so an install failure is tolerated). |
| Ports | Upstream `EXPOSE 8080`. The draft's web UI port 3000 is UNVERIFIED and conflicts with that. The app may be a chat-bot with no listener at all. Decide from the source (open question, section 10). |
| Data path | lowdb writes a JSON file. The path is UNVERIFIED (not read in source). |
| Env vars | UNVERIFIED: the env names the app reads were not confirmed from source or README. |
| Chart | Chart tag pinned `ghcr.io/a-sync/game-server-watcher:v3.1.26`. Chart uses `/data` (pvc). |

## 2. Target layout

- `apps/game-server-watcher/Dockerfile`
- `apps/game-server-watcher/docker-bake.hcl`
- `apps/game-server-watcher/settings.yaml`
- `apps/game-server-watcher/container-test.yaml`
- `apps/game-server-watcher/start.sh`

No `defaults/`, `etc/`, `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base). The app is built from source, so no `app/` directory is needed.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`. The draft chooses the node-providing base, and the closest sibling is `apps/budge` (same base, node build). The node major version in the base is UNVERIFIED: it must satisfy `engines` (>=16.20) and the build (`tsc`). Upstream builds on `node:20`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Build stage `FROM <python-node> AS build`:
   - `curl -fL https://github.com/a-sync/game-server-watcher/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1` (checksum: verify the tarball extracts to commit `2010cd81...` via the tag, or compare the tarball SHA-256 recorded in the PR).
   - `cd /tmp/src && npm ci --include=dev && npm run build && npm prune --omit=dev`.
   - `ENV NPM_CONFIG_CACHE=/tmp/npm` for all npm calls. Do not write caches to `/config` or `/app`.
3. Final stage `FROM <python-node>`:
   - `mkdir -p /app/game-server-watcher && COPY --from=build /tmp/src /app/game-server-watcher` (copy `dist/`, `node_modules/`, `package.json`).
   - License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/game-server-watcher/LICENSE`.
   - `apt-get` not needed (no OS packages; confirm the base already has `curl`).
4. `ENV NODE_ENV=production`, `ENV HOME=/tmp`.
5. `EXPOSE` only the port decided in section 10.
6. `VOLUME /config`, `WORKDIR /app/game-server-watcher`.
7. Final: `USER apps`, `COPY --chmod=0755 . /`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "game-server-watcher" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=a-sync/game-server-watcher versioning=semver
  default = "3.1.26"
}
variable "LICENSE" { default = "AGPL-3.0-or-later" }
variable "SOURCE" { default = "https://github.com/a-sync/game-server-watcher" }
```

Four standard targets and the default group copied from `apps/budge/docker-bake.hcl`. `image-all` platforms: `linux/amd64`, `linux/arm64` (native deps build on arm64, verify). Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/a-sync/game-server-watcher"
ports: []        # replace with the listener if the source has one (section 10)
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Env: UNVERIFIED for app-specific names. Add each variable the source reads (bot tokens, webhook, server list) only after confirming it from the source. The config file path must be decided from the source (open question). Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config
cd /app/game-server-watcher
# point the lowdb state file at /config (env name UNVERIFIED; confirm from source)
export DB_PATH="${DB_PATH:-/config/db.json}"
exec node ./dist/server.js
```

Rules: no write to `/app`; state in `/config`; seed nothing (lowdb creates its file); `exec` the process. Confirm the real env name for the data path and make sure the app does not fall back to a path under `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
filePaths:
- /app/game-server-watcher/dist/server.js
- /usr/share/licenses/game-server-watcher/LICENSE
```

Add a `tcp` probe only for a port that is actually listened on (section 10). Coverage minimum: every settings port needs a probe. If the app has no port, the coverage rule does not apply, and say so in the PR.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (chart PVC) | `/config` |
| lowdb JSON state (location UNVERIFIED) | `/config` via env (section 7) |
| npm cache, HOME | `/tmp` |
| Upstream runs as root | `USER apps`; the app needs no privileged port (8080 if used) |

Draft expectations reconciled: chart `runAsUser: 0` and `readOnlyRootFilesystem: false` are not required here. The image should pass `--read-only --tmpfs /tmp`, provided the app writes nothing else (verify on run).

## 10. Risks, caveats and open questions

- BLOCKER, port: the draft's web UI on 3000 is inferred and conflicts with upstream `EXPOSE 8080`. Read the source at tag `v3.1.26` (`src/`, the server entry `dist/server.js`) to find whether any listener exists. If there is none, `ports: []` and no http probe.
- BLOCKER, data path and env names: not confirmed. Read the source for the lowdb path and the config/env names before writing `start.sh` and `settings.yaml`.
- The npm package named in the draft is a different project. Build from git only.
- `erlpack` is a git dependency (`github:discord/erlpack`) inside `optionalDependencies`. Its build can fail on arm64 or offline. Optional deps failing is tolerated by npm, but verify the arm64 build.
- Chart tag `v3.1.26` is pinned; renovate keeps the bake in step.
- The watched game servers must be reachable over the network, and the notifier needs a bot or webhook token (user setup).
- Release date of the tag: UNVERIFIED.

## 11. Build and test steps

```sh
cd apps/game-server-watcher
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name game-server-watcher-probe --read-only --tmpfs /tmp \
  -v game-server-watcher-probe-config:/config game-server-watcher:3.1.26
docker logs -f game-server-watcher-probe
forgetool containers test --image game-server-watcher:3.1.26 --config ./apps/game-server-watcher/container-test.yaml
docker rm -f game-server-watcher-probe; docker volume rm game-server-watcher-probe-config
```

Expected readiness signal: UNVERIFIED (the app's startup log line). The process must stay up with no bot token set, or it must fail with a clear missing-config message (confirm which from source).

## 12. PR checklist

- Branch `feat/add-game-server-watcher`, commit and PR title `feat(game-server-watcher): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep the sections, check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows status.
- Not tested, state in the PR: the build and run (if not done), arm64 build (erlpack), the port and env decisions (source not yet read).
