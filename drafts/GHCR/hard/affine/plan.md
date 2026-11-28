# affine — implementation plan
> Source: ./draft.md · Target: apps/affine/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v0.27.4, published 2026-08-18, not a prerelease (`gh api repos/toeverything/AFFiNE/releases/latest`). Chart and draft both use `0.27.4`. |
| Renovate | `datasource=github-releases depName=toeverything/AFFiNE versioning=semver` (tags are `vX.Y.Z`). |
| License | GitHub reports `NOASSERTION`, so no SPDX is detected. UNVERIFIED: the SPDX for `LICENSE`; read the repo `LICENSE` file before writing `docker-bake.hcl`. |
| Source URL | https://github.com/toeverything/AFFiNE |
| Per-arch download | No server binary or tarball in the release. Release assets are desktop packages only (`affine-0.27.4-stable-linux-x64.appimage/.deb/.flatpak/.zip`, macOS, Windows). Not usable for a server image. |
| Checksum source | No `.sha256` files in the release. Not applicable for a source build (the source is pinned by tag). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/toeverything/AFFiNE/b4c8548c09da21b2898443559a5b846f0ccf5dd8/.github/deployment/node/Dockerfile |
| Upstream Dockerfile contents | Stage `assets`: `FROM node:22-bookworm-slim`, copies the prebuilt `./packages/backend/server` and the frontend `dist` folders (web, admin, mobile) into `/app`, runs `node ./scripts/docker-clean.mjs`. Runtime stage: `FROM node:22-bookworm-slim`, apt `openssl libjemalloc2`, `ENV LD_PRELOAD=libjemalloc.so.2`, `EXPOSE 3010`, `CMD ["node", "./dist/main.js"]`, no `USER`, no `VOLUME`, no `ENTRYPOINT`. |
| Correction to the draft | The draft says the build needs a Rust napi toolchain. The upstream Dockerfile does not compile Rust or run yarn. It packages output that the monorepo build produced beforehand. Whether Rust is needed depends on the upstream build workflow, which was not fetched: UNVERIFIED. |
| Node version | Node 22 (upstream `node:22-bookworm-slim`). Ubuntu 26.04 `resolute` ships `nodejs` 22.22.1+dfsg+~cs22.19.15-1ubuntu1 for amd64 and arm64 (https://packages.ubuntu.com/resolute/nodejs). |
| Port | `3010/http` (chart `service.main.ports.main.port: 3010`, upstream `EXPOSE 3010`). |
| Env vars (real, from the chart) | `HOME=/root`, `NODE_ENV=production`, `PORT=3010`, `REDIS_SERVER_HOST`, `REDIS_SERVER_PORT=6379`, `REDIS_SERVER_PASSWORD`, `DATABASE_URL`. Commented out in the chart: `AFFINE_SERVER_EXTERNAL_URL`, `AFFINE_SERVER_HOST`, `AFFINE_SERVER_HTTPS`, `AFFINE_INDEXER_ENABLED`. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/affine/values.yaml. UNVERIFIED: that the server code reads these names (the upstream source was not fetched). |
| Migration | Chart init container `affine-migration`: `node ./scripts/self-host-predeploy.js`, with the same `DATABASE_URL` and Redis env. Must run before the server starts. |
| Data paths | Chart mounts `/root/.affine/config` and `/root/.affine/storage`. Under ContainerForge these must move to `/config`, so `HOME=/config` and `~/.affine` becomes `/config/.affine`. |
| Dependencies | Chart: `postgresql` enabled (database `affine`, user `affine`), `valkey` enabled. Both exist locally: `apps/postgresql` and `apps/valkey` (✅). Valkey is required or optional: UNVERIFIED (the chart enables it; the upstream code was not checked). |
| arm64 | UNVERIFIED. The upstream Dockerfile takes `TARGETARCH`, but the published manifest was not checked. The draft says `compile`. |
| Upstream security (chart) | `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. Not a ContainerForge target: the ContainerForge build runs as `apps`. |

## 2. Target layout

- `apps/affine/Dockerfile`
- `apps/affine/docker-bake.hcl`
- `apps/affine/settings.yaml`
- `apps/affine/container-test.yaml`
- `apps/affine/start.sh`

`defaults/` is not needed (no seeded config beyond what `start.sh` writes). `etc/` is not needed. `root/` is never used. `DOWNSTREAM_CHANGES.md` is not needed (affine is not a `FROM` base).

## 3. Base image

- Final and build stages: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.
- Why not `python-node`: the brief maps Node-only apps to the ubuntu base. `python-node` also ships Node 24 (per the `budge` comment), and AFFiNE's upstream image uses Node 22.
- Node 22 comes from apt (`nodejs` 22.22.1 on resolute), pinned to that version in the Dockerfile.
- Closest sibling: `apps/planka` (Node app on the ubuntu-family base with a build stage and a `USER apps` final stage). The `apps/planka` base is `python-node`, so only its layout is copied, not its base.

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install build tools with `apt-get install -y --no-install-recommends nodejs=22.22.1+dfsg+~cs22.19.15-1ubuntu1` (pinned, checked against `VERSION`), plus `build-essential` and `python3` only if the upstream build needs native modules (UNVERIFIED, decide after reading the upstream build workflow).
3. Fetch the source tarball for the tag: `https://github.com/toeverything/AFFiNE/archive/refs/tags/v${VERSION}.tar.gz`, extract to `/build`. Verify against the tag's commit (no published checksum; record the tag's commit SHA in a comment).
4. Run the upstream build steps for the server bundle and the frontend `dist` folders, exactly as the upstream build workflow does (UNVERIFIED: commands; read `.github/workflows` for the build job before writing this step). Use `TARGETARCH` only where upstream does.
5. Copy `packages/backend/server` to `/app` and the frontend `dist` folders to `/app/static`, `/app/static/admin`, `/app/static/mobile`, as the upstream `assets` stage does.
6. Final stage `FROM <ubuntu>`, `ARG VERSION`, `USER root`: `apt-get install -y --no-install-recommends nodejs=<pinned> libjemalloc2 openssl ca-certificates`. Do not re-install packages the base already has.
7. `ENV LD_PRELOAD=/usr/lib/<arch>/libjemalloc.so.2` (path check against the installed package, UNVERIFIED), `HOME=/config`, `XDG_CACHE_HOME=/tmp`, `NODE_ENV=production`.
8. `COPY --from=build /build/ /app` (server bundle and static files only; UNVERIFIED layout after the build).
9. `COPY --chmod=0755 . /`, `EXPOSE 3010`, `VOLUME /config`, `USER apps`.
10. Image label `org.opencontainers.image.licenses` is set in `docker-bake.hcl`, not here.

## 5. docker-bake.hcl

- `APP = "affine"`.
- `VERSION`: `// renovate: datasource=github-releases depName=toeverything/AFFiNE versioning=semver` then `default = "0.27.4"`.
- `LICENSE`: UNVERIFIED (GitHub reports `NOASSERTION`). Set after reading the repo `LICENSE` file.
- `SOURCE = "https://github.com/toeverything/AFFiNE"`.
- Targets: `docker-metadata-action`, `image`, `image-local` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), `group "default" { targets = ["image-local"] }`.
- Validate: `cd apps/affine && docker buildx bake --print`.

## 6. settings.yaml

- Header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json` and `schema_version: 1`.
- `upstream_env_url: "https://github.com/toeverything/AFFiNE"`.
- `ports`: `- port: 3010`, `protocol: tcp` (settings.yaml uses `tcp`/`udp`, not `http`), `required: true`.
- `env` (only names the app really reads; UNVERIFIED until the upstream source is checked):
  - `DATABASE_URL` (required; generated by `start.sh` from the PostgreSQL env, see section 7).
  - `REDIS_SERVER_HOST` (default `valkey`, not required unless Valkey is mandatory).
  - `REDIS_SERVER_PORT` (default `6379`).
  - `REDIS_SERVER_PASSWORD` (optional).
  - `NODE_ENV` (default `production`).
  - `TZ` (default `Etc/UTC`, sibling convention).
- `volumes`: `- path: /config`, `required: true`.
- `dependencies`: `postgresql` (hard, required), `valkey` (optional, `opt_dependencies`; both ✅ in `apps/`).

## 7. start.sh

- Idempotent. On each start: create `/config/.affine/config` and `/config/.affine/storage` if missing. Never overwrite existing files.
- Build `DATABASE_URL` from the PostgreSQL env values on every start (so a changed password applies to existing data). Use URL-encoding for special characters in the password. Keep secrets out of the process list where possible.
- Run the migration `node ./scripts/self-host-predeploy.js` before the server starts, and fail the start if it fails.
- `cd /app` and `exec node ./dist/main.js`. Set `PORT` from the env default (3010).
- Caches go to `/tmp` (`XDG_CACHE_HOME=/tmp`). Nothing is written under `/app`.
- Bind address: UNVERIFIED. The upstream server default is not confirmed; the chart leaves `AFFINE_SERVER_HOST` commented out. Check with a probe from outside the container; the server must listen on `0.0.0.0`.

## 8. container-test.yaml

- Schema header from the sibling apps (`yaml-language-server: $schema=...forgetool.../container-settings.schema.json` style, taken from `apps/planka/container-test.yaml`).
- `tcp` probe on `3010`. `http` probe on `/` (expected status: UNVERIFIED, check the upstream health route).
- `timeoutSeconds`: copy from `apps/planka/container-test.yaml`, and raise it if the first start runs migrations.
- `filePaths`: the files `start.sh` writes under `/config/.affine` and the static assets under `/app/static`.
- DB-dependency narrowing: this app has a hard `postgresql` dependency and will not start without a database, and the single-container suite cannot wire a sidecar DB, so the exception applies. Keep the port and process checks as real assertions, and add a comment near them:
  `# narrowed: requires external postgresql; full functional test not feasible in single-container suite`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/root/.affine/config` (chart) | `/config/.affine/config`, via `HOME=/config` |
| `/root/.affine/storage` (chart) | `/config/.affine/storage`, via `HOME=/config` |
| `HOME=/root` | `HOME=/config` (persistent); caches to `/tmp` |
| Node/npm caches | `/tmp` only |
| Upstream runs as root (chart `runAsUser: 0`) | `USER apps`; no `setuid`, no root-only paths |
| `readOnlyRootFilesystem: false` (chart) | Must pass with `--read-only --tmpfs /tmp` |

## 10. Risks, caveats and open questions

- LICENSE is unknown (GitHub reports `NOASSERTION`). Blocks `docker-bake.hcl`.
- The upstream build workflow is not reproduced by the Dockerfile. Reproducing the server bundle is a long source build with high memory use. Read the upstream CI build job first.
- Draft correction: the Rust napi toolchain is not in the upstream Dockerfile (UNVERIFIED whether the build needs it).
- arm64 is unproven (draft `compile`, manifest not checked).
- PostgreSQL is required. Valkey is UNVERIFIED as required or optional.
- No release server binary exists, so `copy-from` is only available for the upstream image (`ghcr.io/toeverything/affine:0.27.4`, digest `sha256:c312116a134184947d98749c8a8e29f4e3bc97f4f2a51c9a3497f9baea2eec2b`), which is a glibc Node image. It may be used as a fallback only if the license allows it.
- Blockers: none confirmed beyond the license and the build reproduction.

## 11. Build and test steps

1. `cd apps/affine && docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Create a network, start `apps/postgresql` and `apps/valkey` containers, then run the probe on that network: `docker run --rm -d --name affine-probe --network <net> --read-only --tmpfs /tmp -v affine-probe-config:/config -e DATABASE_URL=... <image>:<version>`. Tail logs. Pass criteria: process stays up, the server reports it is listening on `3010`, and the migration log has no fatal errors. Cleanup: `docker rm -f affine-probe; docker volume rm affine-probe-config`.
4. `forgetool containers test --image <image>:<version> --config ./apps/affine/container-test.yaml`.
5. arm64 only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-affine`, commit `feat(affine): add new container`, target `main`.
- PR template `.github/PULL_REQUEST_TEMPLATE.md` filled in, keeping its sections and checkboxes; only check the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Say what was not tested (arm64, a full source-build run if not done, the DB-narrowed test).
- No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
