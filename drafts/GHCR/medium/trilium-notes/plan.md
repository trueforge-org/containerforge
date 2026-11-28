# trilium-notes — implementation plan
> Source: ./draft.md · Target: apps/trilium-notes/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.107.0, published 2026-11-08 (https://api.github.com/repos/TriliumNext/Trilium/releases/latest). Draft pins `0.63.7` (chart image `ghcr.io/zadam/trilium:0.63.7`): outdated. Build the latest stable and note the difference. |
| Repo moved | `zadam/trilium` resolves to `TriliumNext/Trilium` (API redirect). Use https://github.com/TriliumNext/Trilium for source, releases and renovate. |
| Renovate | `datasource=github-releases depName=TriliumNext/Trilium versioning=semver` |
| License | AGPL-3.0 (GitHub SPDX `AGPL-3.0`, https://api.github.com/repos/TriliumNext/Trilium) |
| Source URL | https://github.com/TriliumNext/Trilium |
| Download amd64 | https://github.com/TriliumNext/Trilium/releases/download/v0.107.0/TriliumNotes-Server-v0.107.0-linux-x64.tar.xz (size 88744004) |
| Download arm64 | https://github.com/TriliumNext/Trilium/releases/download/v0.107.0/TriliumNotes-Server-v0.107.0-linux-arm64.tar.xz (size 86470412) |
| arm64 correction | Draft says arm64 is `compile`. A ready-made arm64 server tarball exists, so arm64 is `yes`. |
| Checksum source | GitHub asset digest from the releases API: amd64 `sha256:a217b5ac702e4bd9d401cfd5c6e9ee25f0a6f4a0c67345c65bd67dc8663d3dce`, arm64 `sha256:5dd5a06d350f4f872ebec0b7170eaef489955f76ba62d99e93256978cc902281`. No checksum file is published as an asset. |
| Upstream Dockerfile reviewed | Draft pin (old, v0.63.x): https://raw.githubusercontent.com/zadam/trilium/51939b161c4754f1a5326e2f019ac6a217bea993/Dockerfile: `FROM node:18.18.2-alpine`, WORKDIR /usr/src/app, apk build deps (python3, g++, make), npm install, npm run webpack, npm prune, `su-exec shadow`, creates `node` user, EXPOSE 8080, no ENV, no VOLUME, no USER, CMD `./start-docker.sh`. The v0.107.0 Dockerfile is UNVERIFIED (not fetched); the tarball replaces the build anyway. |
| Ports | 8080/tcp (default `TRILIUM_NETWORK_PORT`) |
| Env vars (real, https://raw.githubusercontent.com/TriliumNext/Trilium/v0.107.0/apps/server/src/services/config.ts) | `TRILIUM_NETWORK_HOST` (0.0.0.0), `TRILIUM_NETWORK_PORT` (8080), `TRILIUM_NETWORK_HTTPS` (false), `TRILIUM_NETWORK_CERTPATH`, `TRILIUM_NETWORK_KEYPATH`, `TRILIUM_NETWORK_TRUSTEDREVERSEPROXY` (false), `TRILIUM_GENERAL_INSTANCENAME`, `TRILIUM_GENERAL_NOBACKUP` (false), `TRILIUM_GENERAL_READONLY` (false), `TRILIUM_GENERAL_NOAUTHENTICATION` (false), `TRILIUM_SESSION_COOKIEMAXAGE` (1814400), `TRILIUM_LOGGING_RETENTIONDAYS` (90), `TRILIUM_SECURITY_BACKEND_SCRIPTING_ENABLED` (false), `TRILIUM_SECURITY_SQL_CONSOLE_ENABLED` (false), `TRILIUM_SYNC_SYNCSERVERHOST`, plus `TRILIUM_OAUTH_*` keys. |
| Data path | UNVERIFIED: `TRILIUM_DATA_DIR` is not in config.ts. The data dir comes from `data_dir.js` (not fetched). Draft says data lives at `/home/node`. Confirm the variable and path in the v0.107.0 source before writing `start.sh`. |
| Dependencies | None (SQLite embedded). |

## 2. Target layout

- `apps/trilium-notes/Dockerfile`
- `apps/trilium-notes/docker-bake.hcl`
- `apps/trilium-notes/settings.yaml`
- `apps/trilium-notes/container-test.yaml`
- `apps/trilium-notes/start.sh`

No `defaults/` unless a config template is needed for seeding `/config`. No `root/`, `etc/`, `health/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The draft suggested `ghcr.io/trueforge-org/python-node` as runtime base; the upstream tarball bundles its own Node runtime (x64), so a Node base is not required. Use ubuntu alone to keep the image small, unless the arm64 tarball lacks a bundled Node (UNVERIFIED: check for `node` inside the arm64 tarball). Closest sibling: `apps/adguardhome-sync` (prebuilt tarball on ubuntu, per-arch `$TARGETARCH`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map `TARGETARCH` to the asset name: `amd64` -> `linux-x64`, `arm64` -> `linux-arm64`.
3. Download `https://github.com/TriliumNext/Trilium/releases/download/v${VERSION}/TriliumNotes-Server-v${VERSION}-linux-${ARCH}.tar.xz` with curl to `/tmp`, verify the sha256 pinned in the Dockerfile (or per-arch `ARG` checksum), extract to `/app` (`tar -xJf ... --strip-components=1 -C /app`).
4. License: copy the upstream LICENSE into `/usr/share/licenses/trilium-notes/`.
5. `ENV HOME=/config`, `TMPDIR=/tmp`, `TRILIUM_NETWORK_HOST=0.0.0.0`, `TRILIUM_NETWORK_PORT=8080`. Caches stay under `/tmp`.
6. `chown -R apps:apps /app` (read-only at runtime).
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`.

The tarball may need `xz-utils` (check the ubuntu base first: do not reinstall what exists).

## 5. docker-bake.hcl

- `APP = "trilium-notes"`, `SOURCE = "https://github.com/TriliumNext/Trilium"`, `LICENSE = "AGPL-3.0-only"`.
- `VERSION` with `// renovate: datasource=github-releases depName=TriliumNext/Trilium versioning=semver` and `default = "0.107.0"`.
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, `group "default" { targets = ["image-local"] }`.
- Validate: `cd apps/trilium-notes && docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/TriliumNext/Trilium"`.
- `ports`: `8080` tcp, `required: true`.
- `env`: only vars that the app reads and `start.sh` uses: `TRILIUM_NETWORK_HOST` (`0.0.0.0`), `TRILIUM_NETWORK_PORT` (`8080`), `TRILIUM_GENERAL_NOBACKUP` (`false`) if exposed, `TZ` (`Etc/UTC`).
- `volumes`: `/config` (`required: true`) for the Trilium data dir (UNVERIFIED path, see section 1).
- `dependencies`: none.

## 7. start.sh

- `set -eu`; never write to `/app`.
- Seed nothing on first start beyond what Trilium creates itself. Make sure the data dir resolves to `/config` (via env or `config.ini`, UNVERIFIED name) before starting.
- Export `TRILIUM_NETWORK_HOST=0.0.0.0` and `TRILIUM_NETWORK_PORT` from settings defaults so the server binds all interfaces.
- Final line: `exec node /app/trilium.mjs` (UNVERIFIED: entry script name in the v0.107.0 tarball; check `ls /app` in the built image).

## 8. container-test.yaml

- forgetool schema header from a sibling Node app.
- `tcp` probe on 8080 with `timeoutSeconds` from a sibling. Optional `http` probe on `/` (expect the login or setup page).
- `filePaths`: data dir after first start (confirm path, section 1).
- Expected readiness signal: a `listening on` or `Trilium server started` line (UNVERIFIED exact text: confirm from the first run's log).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Data dir (`/home/node` in the draft) | `/config` via env or config (UNVERIFIED name) |
| Logs, temp | `/tmp` (`TMPDIR=/tmp`) |
| Backups | `/config` (UNVERIFIED: default backup dir) |

The draft's security expectations: `runAsUser 0` and `runAsNonRoot false` are chart overrides, not upstream requirements. The image runs as `apps`. Pod `fsGroup 1000` is a chart setting: the `apps` user in ContainerForge is not guaranteed to be UID 1000 (UNVERIFIED: check `apps` UID in `apps/ubuntu`). Read-only rootfs is expected to work (`--read-only --tmpfs /tmp`).

## 10. Risks, caveats and open questions

- Version jump: 0.63.7 (draft) to 0.107.0 is a large change. Data migration from the old TrueCharts image is not verified: UNVERIFIED.
- Native modules: the tarball is prebuilt for x64 and arm64 (`yes`), so no source compile is needed (draft said arm64 `compile`: corrected).
- Data path UNVERIFIED (see section 1). This is the main blocker for `start.sh`.
- Pod `fsGroup` 1000 vs ContainerForge `apps` UID (see section 9).
- First login sets the password through the web UI (manual step, not testable in the single-container suite).
- Blockers: none confirmed. The data path must be confirmed first.

## 11. Build and test steps

From `apps/trilium-notes/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker volume create trilium-notes-probe-config`, `docker run --rm -d --name trilium-notes-probe --read-only --tmpfs /tmp -v trilium-notes-probe-config:/config trilium-notes:0.107.0`, `docker logs -f trilium-notes-probe` (expect the listening line and no fatal error), then `docker rm -f trilium-notes-probe; docker volume rm trilium-notes-probe-config`.
4. `forgetool containers test --image trilium-notes:0.107.0 --config ./apps/trilium-notes/container-test.yaml`.

Round limit: 10. Arm64 only if an amd64 failure is arch-specific.

## 12. PR checklist

- Branch `feat/add-trilium-notes`, commit `feat(trilium-notes): add new container`, PR title the same.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Say what was not tested: arm64 run, data path confirmation if still UNVERIFIED, and the migration from `0.63.7`.
- Check "Built container locally" only if the build actually ran.
