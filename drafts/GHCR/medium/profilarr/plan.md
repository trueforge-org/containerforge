# profilarr — implementation plan
> Source: ./draft.md · Target: apps/profilarr/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest release `v2.3.1`, published 2026-10-21T16:58:26Z (https://api.github.com/repos/Dictionarry-Hub/profilarr/releases/latest). Release has no assets. The draft's version (chart image `2.3.1`) matches. |
| Renovate | `datasource=github-releases depName=Dictionarry-Hub/profilarr versioning=semver`. |
| License | AGPL-3.0 (GitHub SPDX `AGPL-3.0`). Source default branch `develop`. |
| Source URL | https://github.com/Dictionarry-Hub/profilarr |
| Download | Source tarball `https://github.com/Dictionarry-Hub/profilarr/archive/refs/tags/v${VERSION}.tar.gz`. No ready-made Profilarr binary: upstream compiles it with `deno compile`. |
| Checksum source | None published on the release page (no assets). Deno assets are listed below; Deno's `.sha256sum` assets were NOT fetched, so checksum is UNVERIFIED. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/Dictionarry-Hub/profilarr/0583ee157985e8d69cb05f6047a3c4dda9f03b33/Dockerfile (summary). |
| Deno runtime | `ARG DENO_VERSION=2.9.8` (upstream pins it). Official Linux glibc zips for Deno v2.9.8 (published 2026-10-21T15:28:53Z, https://api.github.com/repos/denoland/deno/releases/tags/v2.9.8): amd64 https://github.com/denoland/deno/releases/download/v2.9.8/deno-x86_64-unknown-linux-gnu.zip ; arm64 https://github.com/denoland/deno/releases/download/v2.9.8/deno-aarch64-unknown-linux-gnu.zip |
| Upstream builder | `FROM denoland/deno:${DENO_VERSION} AS builder`, `WORKDIR /build`, `deno ci`, writes `src/lib/shared/build.ts` with version/channel/commit/build time, `deno run -A vite build`, pre-hashes a bcrypt value, `deno compile --node-modules-dir=none --exclude-unused-npm --no-check` with net/read/write/env/ffi/run/sys permissions, entry `dist/build/mod.ts`, target `x86_64-unknown-linux-gnu` or `aarch64-unknown-linux-gnu` by `TARGETARCH`. |
| Upstream runtime | `FROM denoland/deno:alpine-${DENO_VERSION}`; apk packages git, GNU tar, curl, su-exec, ca-certificates, sqlite-libs, bash, shadow, tini; `ENTRYPOINT ["/sbin/tini","--","/entrypoint.sh"]`; no `CMD`; no `USER` (uid/gid 1000 `profilarr` created; PUID/PGID remap in entrypoint). |
| Upstream env | `PORT=6868`, `HOST=0.0.0.0`, `APP_BASE_PATH=/config`, `TZ=UTC`, `DENO_DIR=/app/deno-cache`, `DENO_SQLITE_PATH=/usr/lib/libsqlite3.so.0`, `LD_LIBRARY_PATH=/usr/local/lib/glibc` (the last two are Alpine-specific; see section 4). |
| Ports | 6868 (`EXPOSE 6868`). |
| Volumes | `/config` (`VOLUME /config`). |
| Health | `curl -sf` on `/api/v1/health` (upstream `HEALTHCHECK`). |
| Upstream entrypoint | `scripts/entrypoint.sh` in the repo (not fetched; its content is UNVERIFIED). It handles PUID/PGID/UMASK and drops privileges; we do not need root, so it is not ported as-is. |
| Dependencies | None (no database service). Profilarr syncs with Radarr/Sonarr-style apps configured in its UI (not a hard dependency). |
| arm64 | Upstream compiles for `aarch64-unknown-linux-gnu`; Deno arm64 zip exists (above). |

## 2. Target layout

- `apps/profilarr/Dockerfile`
- `apps/profilarr/docker-bake.hcl`
- `apps/profilarr/settings.yaml`
- `apps/profilarr/container-test.yaml`
- `apps/profilarr/start.sh`

No `defaults/`, `etc/`, or `root/` expected. Add `etc/` only if a Deno/sqlite config file must be shipped (none confirmed). No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

- Build stage and runtime stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.
- Reason: upstream's Deno base is Alpine (musl). We need glibc, so Deno is installed from the official glibc zip onto Ubuntu. No Deno base exists in ContainerForge.
- Closest siblings: `apps/pwndrop` (compiled in a build stage, copied to ubuntu runtime) and `apps/webgrabplus` (runtime packages on ubuntu).

## 4. Dockerfile

1. Build stage: `FROM <ubuntu> AS buildstage`, `ARG VERSION`, `ARG TARGETARCH`, `ARG DENO_VERSION=2.9.8`, `USER root`.
2. Install build tools: `apt-get install -y --no-install-recommends unzip ca-certificates curl`. `curl` is in the base already; add only what is missing.
3. Install Deno (pinned to `DENO_VERSION`) for the target arch:
   ```sh
   case "${TARGETARCH}" in amd64) DARCH=x86_64;; arm64) DARCH=aarch64;; *) exit 1;; esac
   curl -fL -o /tmp/deno.zip "https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno-${DARCH}-unknown-linux-gnu.zip"
   unzip -o /tmp/deno.zip -d /usr/local/bin && chmod 0755 /usr/local/bin/deno
   ```
   Verify the zip against Deno's published `.sha256sum` for that asset before use (UNVERIFIED that the asset exists; fetch it in the build).
4. Fetch source: `curl -fL https://github.com/Dictionarry-Hub/profilarr/archive/refs/tags/v${VERSION}.tar.gz -o /tmp/profilarr.tar.gz && mkdir -p /tmp/profilarr && tar xf /tmp/profilarr.tar.gz -C /tmp/profilarr --strip-components=1`.
5. Environment for the build: `ENV DENO_DIR=/tmp/deno-cache DENO_NO_UPDATE_CHECK=1 VITE_CHANNEL=stable VITE_PLATFORM=docker-${TARGETARCH}`. Caches stay in `/tmp`.
6. Mirror the upstream builder steps in `/tmp/profilarr`:
   - `deno ci`
   - write `src/lib/shared/build.ts` with the version, channel, commit (use `unknown` if not known), and build time (same content as the upstream heredoc).
   - `deno run -A vite build`
   - `deno compile --node-modules-dir=none --exclude-unused-npm --no-check <permission flags from upstream> --target <x86_64|aarch64>-unknown-linux-gnu -o /app/profilarr/profilarr dist/build/mod.ts`
   The exact permission flags and the bcrypt pre-hash step are in upstream's Dockerfile (summarised here; read the full file in the build). Copy `static/`, `server.js`, and the Deno plugin cache as upstream does (UNVERIFIED which exact paths; confirm from the build output).
7. Runtime stage: `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
   - `apt-get install -y --no-install-recommends git sqlite3 libsqlite3-0 bash tar curl ca-certificates` (confirm `git` is needed by the app at runtime (UNVERIFIED); drop it if not). Ubuntu provides `libsqlite3.so.0` under the multiarch path, so `DENO_SQLITE_PATH` must point to the real file (confirm with `dpkg -L libsqlite3-0`).
   - `COPY --from=buildstage /app/profilarr/ /app/profilarr/`
   - `install -D /tmp/profilarr/LICENSE /usr/share/licenses/profilarr/LICENSE` (run in build stage, copy across).
   - `chown -R apps:apps /app/profilarr && chmod -R 755 /app/profilarr`.
8. `ENV PORT=6868 HOST=0.0.0.0 APP_BASE_PATH=/config TZ=UTC HOME=/config DENO_DIR=/tmp/deno-cache`. Drop `LD_LIBRARY_PATH=/usr/local/lib/glibc` and `DENO_SQLITE_PATH=/usr/lib/libsqlite3.so.0` from upstream (Alpine-specific); set `DENO_SQLITE_PATH` to the Ubuntu path confirmed in step 7 if the runtime needs it.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 6868
VOLUME /config
WORKDIR /config
```

`ENTRYPOINT`/`CMD` are not set in the Dockerfile; `start.sh` runs the binary.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "profilarr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Dictionarry-Hub/profilarr versioning=semver
  default = "2.3.1"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/Dictionarry-Hub/profilarr"
}
```

Then the default group and the four standard targets copied from `apps/adguardhome-sync/docker-bake.hcl`. The Dockerfile `ARG VERSION` must match: `2.3.1`, with `v` added only in the tarball URL. Validate with `docker buildx bake --print` in `apps/profilarr/`.

Renovate note: the Deno version (`DENO_VERSION=2.9.8`) is pinned in the Dockerfile, not bake. Keep it manually aligned with upstream's `DENO_VERSION` on each Profilarr bump, or add a second renovate annotation (UNVERIFIED that renovate can track `ARG` in Dockerfile for `denoland/deno`; check the repo's renovate config).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Dictionarry-Hub/profilarr"
ports:
  - port: 6868
    protocol: tcp
    required: true
env:
  - name: PORT
    default: "6868"
    required: false
  - name: HOST
    default: "0.0.0.0"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Rules check: `PORT`, `HOST`, `TZ` are read by the app or the image (upstream ENV). `APP_BASE_PATH` is a fixed path (`/config`) and is not user-facing, so it is not listed. Do not list PUID/PGID/UMASK: the entrypoint that reads them is not ported.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config /tmp/deno-cache

export PORT="${PORT:-6868}" HOST="${HOST:-0.0.0.0}" APP_BASE_PATH=/config TZ="${TZ:-Etc/UTC}"

cd /app/profilarr || exit 1
exec /app/profilarr/profilarr
```

- Idempotent: `mkdir -p` only; the app creates its own state under `/config`.
- Never writes to `/app`. `DENO_DIR` is in `/tmp`.
- Runs as `apps` (no privilege drop needed; upstream's entrypoint is not used).
- `HOST=0.0.0.0` so other containers can reach it.
- `exec` the binary as PID 1 handoff. If the app needs an init (zombie reaping), use `tini` only if installed in the base (UNVERIFIED); otherwise accept direct exec.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '6868'
```

- One TCP probe for the single port in `settings.yaml`.
- Optional: an HTTP probe on `/api/v1/health` if the forgetool schema accepts it (confirm in the build); it matches upstream `HEALTHCHECK`.
- Empty environment is supported (defaults are in the Dockerfile and `start.sh`), so no `filePaths` needed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | Our version | Reason |
| --- | --- | --- |
| No `USER`; PUID/PGID remap in entrypoint (root start) | `USER apps` | Rootless rule. The entrypoint's privilege drop is not ported. |
| Chart: `runAsUser 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false` | Ours: non-root, read-only-compatible | Deliberate deviation from the chart's overrides. The user must confirm this is wanted (see section 10). |
| `DENO_DIR=/app/deno-cache` | `DENO_DIR=/tmp/deno-cache` | `/app` is read-only; caches go to `/tmp`. |
| `/config` as `HOME` | Same | Persistent state. |
| `apk`/Alpine packages (`su-exec`, `shadow`, `tini`) | Not installed unless needed | Ubuntu base; no privilege drop. |

## 10. Risks, caveats and open questions

- Chart overrides root and writable rootfs (`runAsUser 0`, `readOnlyRootFilesystem false`). Our image runs as `apps` and is read-only-compatible. Confirm with the user that deviating from the chart is intended.
- Deno version: pinned to `2.9.8` (upstream). The binary must match what the source expects; a bump needs the same check.
- The bcrypt pre-hash and the `build.ts` heredoc are upstream build steps; their exact commands must be copied from the full Dockerfile in the build (summary only was read).
- `scripts/entrypoint.sh` is not fetched (UNVERIFIED content). If it does more than PUID/PGID (for example first-run config), port that logic into `start.sh`.
- Ubuntu package paths: `libsqlite3.so.0` location and `git` need are UNVERIFIED.
- Profilarr expects Radarr/Sonarr instances to be reachable; the container test cannot cover that.
- arm64: Deno arm64 zip exists; the Profilarr compile for arm64 is UNVERIFIED until built.
- Blockers: none confirmed. Stop and report if `deno compile` cannot produce a glibc binary on Ubuntu.

## 11. Build and test steps

Run from `apps/profilarr/`, in this order:

1. `docker buildx bake --print`: must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`: must build.
3. Probe with an empty config volume:
   ```sh
   docker volume create profilarr-probe-config
   docker run --rm -d --name profilarr-probe --read-only --tmpfs /tmp \
     -v profilarr-probe-config:/config profilarr:<version>
   docker logs -f profilarr-probe
   ```
   Expected readiness signal: the app logs that it is listening on port 6868 (exact text UNVERIFIED; confirm in the build). The container must stay running. Also check `curl -sf http://127.0.0.1:6868/api/v1/health` from inside the container.
   Cleanup: `docker rm -f profilarr-probe; docker volume rm profilarr-probe-config`.
4. Test suite: `forgetool containers test --image profilarr:<version> --config ./apps/profilarr/container-test.yaml`.

## 12. PR checklist

- Branch: `feat/add-profilarr` from `main`.
- Commit: `feat(profilarr): add new container`.
- PR title: `feat(profilarr): add new container`.
- PR description: fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and tick only what was done. Note the Deno version (2.9.8) and the deliberate non-root and read-only deviation from the chart.
- Notes section: `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. Tell the user when the PR opens.
- Not tested (state in the PR if it applies): arm64 build and run, the Radarr/Sonarr sync, the Deno checksum verification, and any run that has not been executed.
