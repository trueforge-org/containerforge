# anything-llm — implementation plan
> Source: ./draft.md · Target: apps/anything-llm/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v1.20.0, published 2026-11-17, not a prerelease (`gh api repos/Mintplex-Labs/anything-llm/releases/latest`). The chart uses `ghcr.io/mintplex-labs/anything-llm:latest` (rolling tag, not used for pinning). The upstream Dockerfile sets `DEPLOYMENT_VERSION=1.19.0`, which does not match v1.20.0: UNVERIFIED which version the image reports. |
| Renovate | `datasource=github-releases depName=Mintplex-Labs/anything-llm versioning=semver`. |
| License | MIT (GitHub `spdx_id: MIT`, https://api.github.com/repos/Mintplex-Labs/anything-llm via `gh api`). |
| Source URL | https://github.com/Mintplex-Labs/anything-llm |
| Per-arch download | Release assets are desktop Electron builds only: `AnythingLLMDesktop.AppImage` (amd64), `AnythingLLMDesktop-Arm64.AppImage` (arm64), plus `.exe`, `.dmg`, `installer.sh`, `version.txt`. The draft's AppImage links are NOT a server build. The server image must come from source. |
| Checksum source | `AnythingLLMDesktop.AppImage.sha256` and `AnythingLLMDesktop-Arm64.AppImage.sha256` exist for the desktop AppImages. Contents not read (UNVERIFIED). For the source build, pin the tag `v1.20.0` and the commit SHA. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/Mintplex-Labs/anything-llm/eb498cf2c211/docker/Dockerfile |
| Upstream Dockerfile contents | Base `FROM ubuntu:noble-20251013`. Stages: `build-amd64` and `build-arm64` (apt including Vulkan and Mesa, Node.js 24 from NodeSource, Yarn 1.22.19 `.deb`, uv/uvx 0.6.10 in `/usr/local/bin`, user `anythingllm`, helper scripts to `/usr/local/bin`, `docker/.env.example` copied to `/app/server/.env`; arm64 also downloads a patched Chromium to `/app/chrome-linux`). `frontend-build` on `node:24-slim` (`yarn build`, output `/app/frontend/dist`). `backend-build` runs `yarn install --production` for `server` and `collector`. Final: `ENTRYPOINT ["/bin/bash", "/usr/local/bin/docker-entrypoint.sh"]`, `HEALTHCHECK` via `/usr/local/bin/docker-healthcheck.sh`, `ENV NODE_ENV=production ANYTHING_LLM_RUNTIME=docker`, `USER anythingllm`. No `EXPOSE`, no `VOLUME`, no `CMD`. |
| Entrypoint | `docker/docker-entrypoint.sh` runs `npx prisma generate` and `npx prisma migrate deploy`, warns if `STORAGE_DIR` is unset, then runs `node /app/server/index.js` and `node /app/collector/index.js` in the background and `wait -n`. It does not `exec` and does no seeding. Source: https://raw.githubusercontent.com/Mintplex-Labs/anything-llm/eb498cf2c211/docker/docker-entrypoint.sh |
| Ports | `3001/http` (chart `service.main.ports.main.port: 3001`, `SERVER_PORT` in `.env.example`). Collector port `8888` (`COLLECTOR_PORT` in `.env.example`): exposure UNVERIFIED. |
| Env vars (real) | Active in `.env.example` (sample values, not confirmed defaults): `SERVER_PORT=3001`, `STORAGE_DIR="/app/server/storage"`, `UID=1000`, `GID=1000`. Chart uses `STORAGE_DIR` and `SERVER_PORT` and the password-policy vars (`PASSWORDMINCHAR=8`, `PASSWORDMAXCHAR=250`, `PASSWORDLOWERCASE=1`, `PASSWORDUPPERCASE=1`, `PASSWORDNUMERIC=1`, `PASSWORDSYMBOL=1`, `PASSWORDREQUIREMENTS=4`), plus `JWT_SECRET` from a Kubernetes secret. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/anything-llm/values.yaml. Everything else in `.env.example` is commented out. Do not add provider or vector-DB env vars without a confirmed default. |
| Data paths | Chart mounts `/app/server/storage`, `/app/collector/hotdir`, `/app/collector/outputs`. Under ContainerForge these must go to `/config`. The collector writes `hotdir` and `outputs` inside `/app/collector` (UNVERIFIED that these paths are configurable by env). |
| Dependencies | None in the chart. LLM provider and vector DB are external services chosen by the user (LanceDB is the default vector DB: UNVERIFIED default value). |
| arm64 | Upstream builds an arm64 variant with a patched Chromium download. The published image arch list was not checked (UNVERIFIED). |
| Upstream security (chart) | `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`, `capabilities.add: SYS_ADMIN`. Not acceptable for ContainerForge without a reason: see section 10. |

## 2. Target layout

- `apps/anything-llm/Dockerfile`
- `apps/anything-llm/docker-bake.hcl`
- `apps/anything-llm/settings.yaml`
- `apps/anything-llm/container-test.yaml`
- `apps/anything-llm/start.sh` (replaces upstream `docker-entrypoint.sh`)
- `apps/anything-llm/defaults/` only if a seed `.env` is needed in `/config` (decide at build time; reason: the app reads `/app/server/.env`).

`root/` is never used. `DOWNSTREAM_CHANGES.md` is not needed (not a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (the digest is the one used by `apps/budge`).
- Why: the upstream frontend and server need Node 24. The `budge` comment says the python-node base ships Node 24, which matches. The collector is Python-based, so a Python base is also needed.
- Closest siblings: `apps/budge` (python-node, node-based build), `apps/changedetection` (python-node with a venv).
- UNVERIFIED: the exact Node and Python versions in the base. The build stage must run `node --version` and `python3 --version` as the first check and stop if Node is not 24.x.
- Note: `python-node` runs as `apps` by default; the upstream `anythingllm` user is replaced by `apps`.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install the native build deps needed by LanceDB and sqlite (UNVERIFIED package list, pin against the base; do not re-install what the base has). Install `yarn` 1.22.19 with `npm install --global yarn@1.22.19` (pin), and `uv` 0.6.10 as upstream does (checksum from the uv release, UNVERIFIED).
3. Fetch the source tarball `https://github.com/Mintplex-Labs/anything-llm/archive/refs/tags/v${VERSION}.tar.gz` and extract to `/build`.
4. Frontend: `cd /build/frontend && yarn install && yarn build` (output `/build/frontend/dist`). Server: `cd /build/server && yarn install --production`. Collector: `cd /build/collector && yarn install --production`. Caches to `/tmp` (`YARN_CACHE_FOLDER=/tmp/yarn`, `npm_config_cache=/tmp/npm`).
5. Copy the built frontend to `/build/server/public`, as upstream does.
6. Chromium: the upstream arm64 build downloads a patched Chromium, and the amd64 build does not. Decide how amd64 gets Chromium (UNVERIFIED; upstream amd64 path not read). Prefer the apt or Puppeteer path that works with `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD` and a pinned version.
7. Final stage `FROM <python-node>`, `ARG VERSION`, `USER root`: copy `/build/server` to `/app/server`, `/build/collector` to `/app/collector`, the built frontend, and `docker/.env.example` as `/app/server/.env.example` (not `.env`, since `/app` is read-only).
8. Symlinks at build time (not at runtime): `/app/server/storage -> /config/storage`, `/app/collector/hotdir -> /config/hotdir`, `/app/collector/outputs -> /config/outputs`. Build-time symlinks are allowed; `/app` stays unchanged at runtime.
9. `ENV NODE_ENV=production ANYTHING_LLM_RUNTIME=docker STORAGE_DIR=/config/storage HOME=/config XDG_CACHE_HOME=/tmp`.
10. `COPY --chmod=0755 . /`, `EXPOSE 3001`, `VOLUME /config`, `USER apps`.

## 5. docker-bake.hcl

- `APP = "anything-llm"`.
- `VERSION`: `// renovate: datasource=github-releases depName=Mintplex-Labs/anything-llm versioning=semver` then `default = "1.20.0"`.
- `LICENSE = "MIT"`.
- `SOURCE = "https://github.com/Mintplex-Labs/anything-llm"`.
- Targets: `docker-metadata-action`, `image`, `image-local` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), `group "default" { targets = ["image-local"] }`.
- Validate: `cd apps/anything-llm && docker buildx bake --print`.

## 6. settings.yaml

- Header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json` and `schema_version: 1`.
- `upstream_env_url: "https://github.com/Mintplex-Labs/anything-llm"`.
- `ports`: `- port: 3001`, `protocol: tcp` (settings.yaml uses `tcp`/`udp`, not `http`), `required: true`.
- `env`:
  - `SERVER_PORT` (default `3001`, required false).
  - `STORAGE_DIR` (default `/config/storage`, required false).
  - `JWT_SECRET` (required false; generated by `start.sh` on first start and kept in `/config`; UNVERIFIED that v1.20.0 reads this name).
  - `PASSWORDMINCHAR` (`8`), `PASSWORDMAXCHAR` (`250`), `PASSWORDLOWERCASE` (`1`), `PASSWORDUPPERCASE` (`1`), `PASSWORDNUMERIC` (`1`), `PASSWORDSYMBOL` (`1`), `PASSWORDREQUIREMENTS` (`4`) (values from the chart; UNVERIFIED that the app reads them under these names).
  - `TZ` (default `Etc/UTC`, sibling convention).
- `volumes`: `- path: /config`, `required: true`.
- `dependencies`: none.

## 7. start.sh

- Idempotent: create `/config/storage`, `/config/hotdir`, `/config/outputs` if missing. Never overwrite existing files.
- Generate `JWT_SECRET` into `/config` only if no secret exists yet. Keep it out of the process list.
- Run `npx prisma migrate deploy` on every start (before the server), and fail the start if it fails. Do `npx prisma generate` at build time, not at runtime, since it writes inside `/app`. UNVERIFIED: the Prisma schema's SQLite path; confirm it resolves under `/config` (set `DATABASE_URL` or a symlink, decided at build).
- Start the collector and the server. Upstream uses `wait -n`; ContainerForge should keep both processes and `exec` the server as PID 1 only if the collector is not needed. Decide after reading whether the server needs the collector at startup (UNVERIFIED).
- Caches to `/tmp`. Nothing written under `/app`.
- Bind `0.0.0.0` for the server (the upstream default is UNVERIFIED; check from outside the container).

## 8. container-test.yaml

- Schema header from the sibling apps (`apps/planka/container-test.yaml` style).
- `tcp` on `3001`. `http` on `/` (expected status: UNVERIFIED, check the route and the upstream `docker-healthcheck.sh`).
- `timeoutSeconds`: start-up runs `prisma migrate deploy` and a large Node server, so use a value above the python-node sibling default (UNVERIFIED; check `apps/budge/container-test.yaml`).
- `filePaths`: `/config/storage`, `/app/server/public/index.html` (UNVERIFIED path after build).
- No database dependency in settings, so no narrowing is needed. The test runs with no env vars: `JWT_SECRET` is generated on first start, so the empty-env path must work.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/app/server/storage` (chart) | `/config/storage` via build-time symlink and `STORAGE_DIR` |
| `/app/collector/hotdir` (chart) | `/config/hotdir` via build-time symlink |
| `/app/collector/outputs` (chart) | `/config/outputs` via build-time symlink |
| `/app/server/.env` (copied by upstream build) | Not written at runtime; env comes from the settings defaults |
| Prisma client (`prisma generate`) | Done at build time |
| Chromium cache and profile | `/tmp` |
| `USER anythingllm` (upstream) | `USER apps` |
| `SYS_ADMIN` capability (chart) | Not requested. Chromium needs `--no-sandbox` (documented in `.env.example` as `ANYTHINGLLM_CHROMIUM_ARGS`), which is the usual rootless route. Verify before enabling any capability. |

## 10. Risks, caveats and open questions

- Desktop AppImages in the draft are not a server build. The server image must be built from source.
- Node 24 must be present in the base. Blocker if python-node ships another Node version (check first in step 3 of section 1).
- Chromium on amd64: the upstream amd64 path is not read. Blocker for any PDF or web-scrape features until resolved (UNVERIFIED).
- `SYS_ADMIN` in the chart: assumed to be for Chromium sandboxing. Not granted here; if the app fails rootless, the fix is `--no-sandbox` flags, not a capability.
- The upstream image tag is `latest` (rolling). ContainerForge pins `1.20.0`, which differs from the upstream `DEPLOYMENT_VERSION=1.19.0`: UNVERIFIED which version the built image reports.
- An LLM provider key or local model is needed for chat and embedding. The container must start without one (the app runs with no provider configured: UNVERIFIED).
- Build is large and slow (Node monorepo, native LanceDB and sqlite).
- arm64 is unproven (Chromium variant, published arch not checked).
- Blockers: Node 24 availability in the base, Chromium strategy on amd64, and the collector start model.

## 11. Build and test steps

1. `cd apps/anything-llm && docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe: `docker run --rm -d --name anything-llm-probe --read-only --tmpfs /tmp -v anything-llm-probe-config:/config <image>:1.20.0`. Tail logs. Pass criteria: the process stays up, the server logs its listening port (`3001`) or the app's ready line, and the prisma migration log has no fatal error. Cleanup: `docker rm -f anything-llm-probe; docker volume rm anything-llm-probe-config`.
4. `forgetool containers test --image <image>:1.20.0 --config ./apps/anything-llm/container-test.yaml`.
5. arm64 only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-anything-llm`, commit `feat(anything-llm): add new container`, target `main`.
- PR template `.github/PULL_REQUEST_TEMPLATE.md` filled in, keeping its sections and checkboxes; only check the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Say what was not tested (arm64, Chromium features, LLM providers, the collector path).
- No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
