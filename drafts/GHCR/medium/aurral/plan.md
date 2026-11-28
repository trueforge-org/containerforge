# aurral — implementation plan
> Source: ./draft.md · Target: apps/aurral/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest release v3.1.0, published 2026-11-23 (https://api.github.com/repos/lklynet/aurral/releases/latest). The draft's chart tag is `ghcr.io/lklynet/aurral:3.0.0`, one minor version behind. Build v3.1.0 unless the builder finds a reason to stay on 3.0.0. |
| Renovate | `datasource=github-releases depName=lklynet/aurral versioning=semver` (convention choice, UNVERIFIED upstream). |
| License | MIT (GitHub repo metadata, https://api.github.com/repos/lklynet/aurral). |
| Source URL | https://github.com/lklynet/aurral |
| Binary | No release assets on the v3.1.0 release. Build from source. |
| Per-arch download | Source tarball `https://github.com/lklynet/aurral/archive/refs/tags/v${VERSION}.tar.gz` (UNVERIFIED: not fetched). |
| Checksum source | None on the release. The yt-dlp and cloudflared inputs are covered below. |
| Upstream Dockerfile reviewed | Read at tag v3.1.0 (`gh api repos/lklynet/aurral/contents/Dockerfile?ref=v3.1.0`); the draft traces commit 84535c99df51 (3.0.0). |
| Upstream base images | `node:26.13.0-trixie-slim` (glibc Debian, named `node-base`), `ghcr.io/voidzero-dev/vite-plus:1.7.0` (builder and backend-deps, uses `vp install`), `mwader/static-ffmpeg:9.0.2-1` (ffmpeg, ffprobe), `cloudflare/cloudflared:2026.11.2@sha256:55c7e3e8d89d5e8d20b75a82f3602cbf98e06db406e73e282073cfdc5a9a3af6` (cloudflared; checked at tag v3.1.0). All pinned by digest upstream. |
| Upstream build steps | `builder`: `vp install --frozen-lockfile --filter aurral-frontend`, then `pnpm --filter aurral-frontend run build` with `APP_VERSION`, `GITHUB_REPO=lklynet/aurral`, `RELEASE_CHANNEL=stable` mapped to `VITE_*`. `backend-deps`: `vp install --frozen-lockfile --prod --filter aurral --filter aurral-backend`, then a check that `sharp` loads. |
| Runtime apt packages | `fontconfig fonts-dejavu-core fonts-noto-color-emoji python3 ca-certificates libjemalloc2 tini` (`--no-install-recommends`). |
| yt-dlp | `ADD --chmod=755 --checksum=sha256:e51e69e8…` from `https://github.com/yt-dlp/yt-dlp/releases/download/2026.10.26/yt-dlp` to `/usr/local/bin/yt-dlp`. Full checksum at v3.1.0: `e51e69e89489f199530f13d32a4342da3ddb2cf34842f364603a066db05afbf3` (from the upstream Dockerfile, not re-derived from yt-dlp's SHA2-256SUMS). |
| cloudflared | Upstream (v3.1.0) copies `/usr/local/bin/cloudflared` from `cloudflare/cloudflared:2026.11.2` (digest-pinned). No separate checksum. |
| ENTRYPOINT / CMD | `ENTRYPOINT ["tini", "-s", "--", "docker-entrypoint.sh"]`, `CMD ["node", "--max-semi-space-size=4", "backend/server.ts"]`. `backend/docker-entrypoint.sh` (read at v3.1.0): if root, it creates the user from `AURRAL_UID`/`AURRAL_GID` or `PUID`/`PGID`, `chown -R`s `AURRAL_DATA_DIR` (default `/config`) and drops privileges with `setpriv`; otherwise it just `exec "$@"`. Nothing else, so a non-root `start.sh` loses no behaviour. |
| USER | Not set. The `nodejs` user (UID/GID 1001) is created and not selected, so upstream runs as root unless the entrypoint drops privileges (UNVERIFIED). |
| EXPOSE / VOLUME | `EXPOSE 3001`. No `VOLUME`. `/config` is created and owned by `nodejs`. |
| ENV (Dockerfile) | `LD_PRELOAD=libjemalloc.so.2`, `MALLOC_CONF=background_thread:true,dirty_decay_ms:1000,muzzy_decay_ms:1000`, `APP_VERSION`, `GITHUB_REPO`. Other runtime env vars: UNVERIFIED. |
| Dependencies | No database confirmed. External music-library services and API keys are entered after start (draft, UNVERIFIED here). |
| Arch | The Dockerfile has no arch conditionals. Published arm64 image: UNVERIFIED. |

## 2. Target layout

- `apps/aurral/Dockerfile`
- `apps/aurral/docker-bake.hcl`
- `apps/aurral/settings.yaml`
- `apps/aurral/container-test.yaml`
- `apps/aurral/start.sh`

Add `defaults/` only if the app needs a seeded config. Never use `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Reason: the app is a Node backend, and yt-dlp needs Python 3, which the base already has. The draft gives python-node as the runtime. Upstream `.nvmrc` is 26.12.0 and the upstream image uses `node:26.13.0`; the base's Node (24 per the `apps/budge` comment) must run `backend/server.ts` directly (type stripping), UNVERIFIED. Closest siblings: `apps/budge` (python-node, npm build) and `apps/changedetection` (python-node with a Node build).

The `ffmpeg` and `ffprobe` binaries come from a separate stage (see section 4). `cloudflared` also comes from a separate stage. Neither is a `COPY --from` of a musl-built image: `mwader/static-ffmpeg` is a static build, and `cloudflare/cloudflared` is glibc-independent Go.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS builder` with `ARG VERSION`, `ARG APP_VERSION`, `ARG GITHUB_REPO=lklynet/aurral`, `ARG RELEASE_CHANNEL=stable`, `USER root`.
2. Source: `curl -fL "https://github.com/lklynet/aurral/archive/refs/tags/v${VERSION}.tar.gz" | tar xz -C /tmp/src --strip-components=1`. The `v` prefix matches the tag.
3. pnpm: install the version pinned in the repo's `packageManager` field (UNVERIFIED; upstream uses `vp`, the vite-plus CLI, which is a separate binary). Decision for the builder: either run `pnpm install --frozen-lockfile` with the pinned pnpm, or take the `vp` binary from `ghcr.io/voidzero-dev/vite-plus:1.7.0@sha256:dcdbe5282b3c...` as a `COPY --from`. Prefer the pnpm route if it works, because it avoids a third-party build image.
4. Frontend: `pnpm --filter aurral-frontend run build` with `VITE_APP_VERSION=${APP_VERSION}`, `VITE_GITHUB_REPO=${GITHUB_REPO}`, `VITE_RELEASE_CHANNEL=${RELEASE_CHANNEL}`.
5. Backend deps: `pnpm install --frozen-lockfile --prod --filter aurral --filter aurral-backend`, then `node -e "require('sharp')"` in `backend/`.
6. Final stage `FROM <python-node>` with `USER root`:
   - `apt-get install -y --no-install-recommends fontconfig fonts-dejavu-core fonts-noto-color-emoji libjemalloc2` (python3 and ca-certificates are already in the base; check before installing; `tini` is already in the ubuntu base).
   - `COPY --from=ghcr.io/trueforge-org/...`: not used. Copy ffmpeg and ffprobe with `COPY --from=mwader/static-ffmpeg:9.0.2-1@sha256:f5d100184884eb3e82b0eb14bb5ebf98da99826ac824989720297fb9ef21c822 /ffmpeg /ffprobe /usr/local/bin/` (same form as upstream v3.1.0).
   - `COPY --from=cloudflare/cloudflared:2026.11.2@sha256:55c7e3e8d89d5e8d20b75a82f3602cbf98e06db406e73e282073cfdc5a9a3af6 /usr/local/bin/cloudflared /usr/local/bin/cloudflared`.
   - yt-dlp: `ADD --chmod=755 --checksum=sha256:<full hash> https://github.com/yt-dlp/yt-dlp/releases/download/2026.10.26/yt-dlp /usr/local/bin/yt-dlp` (full hash from SHA2-256SUMS, see section 1).
   - Copy the built app: `/app/aurral/` from the builder: `backend/`, `lib/`, `frontend/dist`, `node_modules`, and `package.json` files. Keep `/app` read-only at runtime.
   - License: `COPY --from=builder /tmp/src/LICENSE /usr/share/licenses/aurral/LICENSE`. Also ship the notices for yt-dlp and cloudflared (licenses UNVERIFIED; check the release assets).
   - Verify with `RUN ffmpeg -version && ffprobe -version && cloudflared --version && yt-dlp --version`.
7. ENV: `LD_PRELOAD=libjemalloc.so.2`, `MALLOC_CONF=background_thread:true,dirty_decay_ms:1000,muzzy_decay_ms:1000`, `APP_VERSION`, `GITHUB_REPO`, `HOME=/config`, `XDG_CACHE_HOME=/tmp`, `TMPDIR=/tmp`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3001
VOLUME /config
WORKDIR /app/aurral
```

`start.sh` replaces the upstream `docker-entrypoint.sh` and owns the command through the base image's `ENTRYPOINT` (`tini -- /entrypoint.sh`, from `apps/ubuntu`); do not set a new `ENTRYPOINT`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "aurral" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=lklynet/aurral versioning=semver
  default = "3.1.0"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/lklynet/aurral" }
```

Four standard targets and the default group copied from `apps/budge/docker-bake.hcl`. The `APP_VERSION` and `GITHUB_REPO` build args go in the `image` target `args`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/lklynet/aurral"
ports:
  - port: 3001
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`AURRAL_DATA_DIR` (default `/config`) is read by upstream's entrypoint at v3.1.0 and may be listed; further names only after reading the backend config at the tag (UNVERIFIED). Do not invent `PORT` or `HOST` names.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
cd /app/aurral
exec node --max-semi-space-size=4 backend/server.ts
```

- Idempotent: creates `/config` only, seeds nothing (the app's first-run data layout is UNVERIFIED).
- Writes only to `/config` and `/tmp`. Caches go to `/tmp` through `XDG_CACHE_HOME`.
- Replaces the upstream `docker-entrypoint.sh`, which only drops privileges and ensures `/config` (read at v3.1.0), so nothing needs porting. Keep `LD_PRELOAD`/`MALLOC_CONF` from the Dockerfile `ENV`.
- Bind address: check that the server listens on all interfaces at the tag (UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3001'
http:
- port: '3001'
  path: /
filePaths:
- /app/aurral/backend/server.ts
- /app/aurral/frontend/dist/index.html
- /usr/local/bin/yt-dlp
- /usr/local/bin/cloudflared
- /usr/local/bin/ffmpeg
- /usr/share/licenses/aurral/LICENSE
```

- Port 3001 has `tcp` and `http` probes, per the coverage minimum.
- `timeoutSeconds: 180` because the Node backend with native `sharp` loads slowly. Check the value against a Node sibling before committing.
- Paths above are the expected layout. Confirm each with a local run before committing (UNVERIFIED).
- The test runs with no env vars. External music-library API keys are entered after start, so the test covers the "no keys" start path only. Note that in the PR.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (created and owned by `nodejs` upstream) | Persistent volume; fresh start must work with an empty `/config`. |
| App data and logs (path UNVERIFIED) | Point at `/config` through the app's own env or a symlink created at build time, once the path is known. |
| `HOME` for yt-dlp and cloudflared caches | `HOME=/config` would put caches in `/config`. Set `XDG_CACHE_HOME=/tmp` and keep `HOME` on `/tmp` if caches are written there. |
| Node and sharp caches | `/tmp` only. |
| yt-dlp self-update | Disabled by design: the binary is read-only in `/usr/local/bin`. |

- Upstream runs as root (no USER). Our image runs as `apps` (UID per the base image) with `--read-only --tmpfs /tmp`.
- Port 3001 is above 1024, so no port change is needed.
- Draft expectations hold: non-root and read-only rootfs are compatible with this plan, provided the app writes only to `/config` and `/tmp`. Verify both in the probe run.
- Chart `/var/cache` emptyDir maps to `/tmp` here. Record this in the PR.

## 10. Risks, caveats and open questions

- Draft caveats confirmed: the cloudflared binary is per-arch by image digest (no build-time download), and the pnpm monorepo build is large and slow.
- `docker-entrypoint.sh` was read (section 1): only a privilege drop and `AURRAL_DATA_DIR` default `/config`; not needed for a rootless image. `AURRAL_DATA_DIR` is an upstream env name (could be added to `settings.yaml`, default `/config`).
- Unresolved: the server's data path. The chart mounts `/config`, but the app's own path is UNVERIFIED.
- Unresolved: whether the `vp` CLI is required. The pnpm route is preferred; if it cannot reproduce the build, use the vite-plus image as a build stage and note it in the PR.
- Version: the draft targets 3.0.0, upstream latest is 3.1.0. Build the latest tag, and state the change in the PR.
- Copy-from: the upstream image is glibc-based, so `COPY --from=ghcr.io/lklynet/aurral:3.1.0` would be possible. It is not the plan: the source build keeps the ContainerForge base and pins inputs.
- arm64: no arch conditionals upstream, but the published arm64 manifest is UNVERIFIED. Build amd64 first.
- Blocker candidates: none confirmed. External API keys are a runtime requirement, not a build blocker.

## 11. Build and test steps

From `apps/aurral/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run with a fresh empty `/config` volume:

```sh
docker volume create aurral-probe-config
docker run --rm -d --name aurral-probe --read-only --tmpfs /tmp \
  -v aurral-probe-config:/config aurral:3.1.0
docker logs -f aurral-probe
```

   Expected readiness signal: a startup line from the backend naming port 3001 (exact text UNVERIFIED; take it from the first real run). The container must still be running, with no fatal errors.
4. `forgetool containers test --image aurral:3.1.0 --config ./container-test.yaml`, or the manual checks if forgetool is unavailable.
5. Clean up: `docker rm -f aurral-probe; docker volume rm aurral-probe-config`.

Not tested here: arm64, the external music-library services, and any API-key path.

## 12. PR checklist

- Branch: `feat/add-aurral`.
- Commit: `feat(aurral): add new container`.
- PR title: `feat(aurral): add new container`.
- PR body: use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Say what was not tested: arm64, the external API integrations, and the entrypoint behavior not yet compared with upstream.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- Conventional commit scope `aurral` for every commit.
