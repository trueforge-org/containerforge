# Upstream Dockerfile and entrypoint: lklynet/aurral

**Source URL(s):** https://raw.githubusercontent.com/lklynet/aurral/84535c99df51/Dockerfile (commit 84535c99df51, i.e. the 3.0.0-era build the draft traces; not v3.1.0); https://raw.githubusercontent.com/lklynet/aurral/84535c99df51/backend/docker-entrypoint.sh (fetched 2026-11-27)

## Base images (all digest-pinned upstream)
- `node-base`: `node:26.13.0-trixie-slim@sha256:e4db4c91...` (glibc Debian)
- `vite-plus`: `ghcr.io/voidzero-dev/vite-plus:1.7.0@sha256:dcdbe528...`
- `ffmpeg`: `mwader/static-ffmpeg:9.0.2-1@sha256:f5d10018...`
- `cloudflared`: `cloudflare/cloudflared:2026.11.0@sha256:b94b96ed...`

## Stages
1. **builder** (`vite-plus`): COPY package.json, pnpm-lock.yaml, pnpm-workspace.yaml, .nvmrc, backend/, frontend/, docs/ package.json; `vp install --frozen-lockfile --filter aurral-frontend` (cache mount on pnpm store, uid/gid 1000).
   - COPY frontend/ and lib/; ARGs `APP_VERSION=unknown`, `GITHUB_REPO=lklynet/aurral`, `RELEASE_CHANNEL=stable` -> ENV `VITE_APP_VERSION`, `VITE_GITHUB_REPO`, `VITE_RELEASE_CHANNEL`.
   - `pnpm --filter aurral-frontend run build`.
2. **backend-deps** (`vite-plus`): `vp install --frozen-lockfile --prod --filter aurral --filter aurral-backend`; `cd backend && node -e "require('sharp')"`.
3. **runtime** (`node-base`):
   - apt (no-install-recommends): `fontconfig fonts-dejavu-core fonts-noto-color-emoji python3 ca-certificates libjemalloc2 tini`.
   - `groupadd --gid 1001 nodejs`; `useradd --uid 1001 --gid nodejs --shell /usr/sbin/nologin --create-home nodejs`; `mkdir -p /config && chown -R nodejs:nodejs /config`.
   - ENV `LD_PRELOAD=libjemalloc.so.2`, `MALLOC_CONF=background_thread:true,dirty_decay_ms:1000,muzzy_decay_ms:1000`.
   - COPY `ffmpeg`, `ffprobe` -> `/usr/local/bin/`; `cloudflared` -> `/usr/local/bin/`.
   - `ADD --chmod=755 --checksum=sha256:e51e69e89489f199530f13d32a4342da3ddb2cf34842f364603a066db05afbf3 https://github.com/yt-dlp/yt-dlp/releases/download/2026.10.26/yt-dlp /usr/local/bin/yt-dlp`.
   - `RUN yt-dlp --version && ffmpeg -version && ffprobe -version && cloudflared --version`.
   - COPY package.json, backend/package.json, frontend/package.json; node_modules from backend-deps; `backend/`, `lib/`, `frontend/dist` from builder; `docker-entrypoint.sh` -> `/usr/local/bin/` (chmod 755).
   - ARG `APP_VERSION`, `GITHUB_REPO` -> ENV.
   - `EXPOSE 3001`
   - `ENTRYPOINT ["tini", "-s", "--", "docker-entrypoint.sh"]`
   - `CMD ["node", "--max-semi-space-size=4", "backend/server.ts"]`
   - No USER directive.

## docker-entrypoint.sh
- If `id -u` = 0: saves LD_PRELOAD/MALLOC_CONF and unsets them.
- Target UID/GID from `AURRAL_UID`/`AURRAL_GID`, else `PUID`/`PGID`, else nodejs (1001/1001).
- Creates group `aurral` and user `aurral` (nologin, `-M`) if no matching entry.
- `data_dir=${AURRAL_DATA_DIR:-/config}`; `mkdir -p`; `chown -R uid:gid`.
- `exec setpriv --reuid $uid --regid $gid --groups $gid env LD_PRELOAD=... MALLOC_CONF=... "$@"`.
- If not root: `exec "$@"`.

## Env vars
| Var | Value / note |
| --- | --- |
| LD_PRELOAD | libjemalloc.so.2 |
| MALLOC_CONF | background_thread:true,dirty_decay_ms:1000,muzzy_decay_ms:1000 |
| APP_VERSION | build arg (default unknown) |
| GITHUB_REPO | build arg (default lklynet/aurral) |
| AURRAL_UID / AURRAL_GID | entrypoint: target user/group (optional) |
| PUID / PGID | entrypoint fallback |
| AURRAL_DATA_DIR | entrypoint: data dir (default /config) |

## Ports
- 3001

## Volumes/paths
- `/config` (created, owned by nodejs). No VOLUME.

## User/UID
- `nodejs` UID/GID 1001 created; image runs as root and entrypoint drops privileges via setpriv when root.

## Arch
- Not stated in Dockerfile.

## Gotchas
- Fetched Dockerfile is commit 84535c99df51 (cloudflared 2026.11.0). Newer v3.1.0 pins cloudflared 2026.11.1 per plan.md (not verified here).
