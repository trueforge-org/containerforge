# Upstream Dockerfile and entrypoint: Dictionarry-Hub/profilarr (commit 0583ee15)

Source URL(s) + date:
- https://raw.githubusercontent.com/Dictionarry-Hub/profilarr/0583ee157985e8d69cb05f6047a3c4dda9f03b33/Dockerfile (2026-11-27)
- https://raw.githubusercontent.com/Dictionarry-Hub/profilarr/0583ee157985e8d69cb05f6047a3c4dda9f03b33/scripts/entrypoint.sh (2026-11-27)
- https://github.com/Dictionarry-Hub/profilarr/blob/0583ee.../Dockerfile: raw variant used

What it is: Deno app (SvelteKit built with Vite, then compiled with `deno compile` into a single binary `/app/profilarr`).

Build args: `DENO_VERSION=2.9.8` (base `denoland/deno:${DENO_VERSION}`), `TARGETARCH` (buildx), `VITE_CHANNEL=stable`, `PROFILARR_VERSION=dev`, `PROFILARR_COMMIT=unknown`, `PROFILARR_BUILT_AT=unknown`.

Stages:
1. `builder` (`denoland/deno:2.9.8`): `deno ci`, writes `src/lib/shared/build.ts`, `deno run -A vite build` (APP_BASE_PATH=/build/dist/build), warms bcrypt via `deno eval`, `deno compile --node-modules-dir=none --exclude-unused-npm --no-check --allow-net --allow-read --allow-write --allow-env --allow-ffi --allow-run --allow-sys --target <x86_64|aarch64>-unknown-linux-gnu --output dist/build/profilarr dist/build/mod.ts`
2. Runtime (`denoland/deno:alpine-2.9.8`): apk git, tar, curl, su-exec, ca-certificates, sqlite-libs, bash, shadow, tini; `apk upgrade`.
   - Copies `/app/profilarr`, `/app/server.js`, `/app/static`, `/app/deno-cache/plug`, `/entrypoint.sh`.
   - Removes `deno` user/group, creates `profilarr` UID/GID 1000 (home `/config`, nologin).
   - `mkdir /config`

Runtime:
- `ENV PORT=6868`, `HOST=0.0.0.0`, `APP_BASE_PATH=/config`, `TZ=UTC`, `DENO_DIR=/app/deno-cache`, `DENO_SQLITE_PATH=/usr/lib/libsqlite3.so.0`, `LD_LIBRARY_PATH=/usr/local/lib/glibc`
- `EXPOSE 6868`
- `HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 CMD curl -sf http://localhost:${PORT}/api/v1/health || exit 1`
- `VOLUME /config`
- `ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]`
- LABEL org.opencontainers.image.licenses="AGPL-3.0"

entrypoint.sh:
- Converts any `*_FILE` env vars into their file contents (warns if missing).
- If not root (`id -u` != 0): `umask ${UMASK:-022}`, mkdir `/config/{data,logs,backups,databases}`, `exec /app/profilarr`.
- If root: uses PUID/PGID (default 1000) to create or modify group `profilarr` and user `profilarr` (`useradd -d /config -s /bin/bash`), sets umask UMASK, mkdir `/config/{data,logs,backups,databases}`, `chown -R PUID:PGID /config`, `exec su-exec <user> /app/profilarr`.

Env vars read: PUID, PGID, UMASK, PORT, HOST, APP_BASE_PATH, TZ, DENO_DIR, DENO_SQLITE_PATH, LD_LIBRARY_PATH, VITE_CHANNEL (build), PROFILARR_* (build).

Ports: 6868/tcp.

Volumes/paths: `/config` (data, logs, backups, databases subdirs). 

User/UID: profilarr UID/GID 1000 (or PUID/PGID when root at start).

Healthcheck: `/api/v1/health`.

Gotchas:
- Non-root start (`--user 1000` or runAsUser) skips PUID/PGID logic and runs `/app/profilarr` directly; `/config` subdirs are created by the entrypoint only in that branch too.
- Deno version is pinned to 2.9.8 (matches the chart-free plan pin).
