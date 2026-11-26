# Maintainerr/Maintainerr (upstream source)

**Source URL(s):** https://github.com/Maintainerr/Maintainerr (repo page); https://github.com/Maintainerr/Maintainerr/releases/tag/v3.33.0; https://github.com/Maintainerr/Maintainerr/releases/tag/v3.32.0; https://raw.githubusercontent.com/Maintainerr/Maintainerr/v3.33.0/LICENSE; https://registry.npmjs.org/maintainerr (npm check)
**Fetched:** 2026-11-26

## What it is
"Looks and smells like Seerr, does the opposite." A free, open-source, self-hosted library maintenance tool for Plex, Jellyfin and Emby. Rules define unused media; matches are grouped into collections with a grace period; then they are removed from the media server, the *arr apps, and Seerr/Ombi.
- Rules draw on Plex, Jellyfin, Emby, Radarr, Sonarr, Sportarr, Tautulli, Streamystats, Tracearr and Seerr.
- Actions include file deletion, unmonitoring or changing quality profiles in *arr, clearing Seerr requests, and removing files from qBittorrent.
- Default branch on GitHub is `development` (5,176 commits).
- Monorepo layout: `apps/server`, `apps/ui`, `packages/contracts`, `docker/`, `tools/`, `turbo.json`, `yarn.lock`, `.yarnrc.yml`, `release.sh`.
- Node engine: not shown on the page (package.json not expanded here). Upstream Dockerfile base is Node 26.13.0 (alpine).

## Install/build steps and build deps (upstream Dockerfile, see the Dockerfile summary)
- Source build only: no release assets (both v3.32.0 and v3.33.0 pages show "Assets 2" with names not loaded; plan.md checked the API and saw none).
- Source tarball: `https://github.com/Maintainerr/Maintainerr/archive/refs/tags/v<VERSION>.tar.gz` (archive, skipped as a download; pattern recorded here).
- Build deps (upstream builder, apk): build-base, python3, pkgconfig, cairo-dev, pango-dev, pixman-dev (node-canvas).
- Corepack enabled; `corepack install` reads `.yarnrc.yml`/`yarn.lock`; `yarn install --network-timeout 99999999`; `yarn turbo build`; `yarn workspaces focus --all --production`.
- Writes `VITE_BASE_PATH=/__PATH_PREFIX__` to `apps/ui/.env` before the build.

## Runtime deps
- Node (upstream Alpine Node 26.13.0). Runtime packages upstream: curl, cairo, pango, pixman.
- npm/npx are removed from the upstream runner image (`rm -rf` of npm, npx and `/usr/local/lib/node_modules/npm`).
- Native modules: node-canvas (cairo/pango/pixman), sharp (prebuilt glibc binaries; needs x86-64-v2 CPU on amd64 for overlay/poster features, not on arm64; see installation summary).

## Binaries / entrypoint
- Upstream `ENTRYPOINT ["/opt/app/start.sh"]`. No CMD.
- Runs `exec node dist/main` from `/opt/app/apps/server` (direct, not `npm run start`, to avoid the update banner).
- `npm_package_version` read from `package.json` (otherwise the app reports 0.0.1).

## Env vars (from installation docs, verified list)
| Variable | Default | Purpose |
| --- | --- | --- |
| TZ | host timezone | Log date formatting |
| UI_HOSTNAME | 0.0.0.0 | Listen host (`::` for IPv6) |
| UI_PORT | 6246 | Listen port |
| BASE_PATH | (empty) | Subfolder for reverse proxy; surrounding slashes trimmed |
| LOG_LEVEL | info | Overrides persisted log level (debug, verbose, info, warn, error, fatal) |
| GITHUB_TOKEN | (empty) | Higher GitHub API rate limits |
| CORS_ALLOWED_ORIGINS | (empty) | Cross-origin API access (same-origin does not need it) |
| TELEMETRY | (empty) | `off` disables the anonymous weekly usage report |
| SPORTARR_NET | (empty) | `on` allows artwork from sportarr.net |

- Upstream Dockerfile ENV: NODE_ENV=production, DEBUG=false, UI_PORT=6246, UI_HOSTNAME=0.0.0.0, GIT_SHA, VERSION_TAG=develop, BASE_PATH, DATA_DIR=/opt/data, UV_USE_IO_URING=0 (libuv workaround).
- The docs say no other env vars are officially supported. Plan.md's list (NODE_ENV, DEBUG, UI_PORT, UI_HOSTNAME, DATA_DIR, BASE_PATH, UV_USE_IO_URING) matches the Dockerfile.

## Ports
6246/tcp (HTTP). `EXPOSE 6246`.

## Volumes/paths and persistent data
- `/opt/data` (`DATA_DIR`): the data directory. Holds database, logs and the staged UI (`${DATA_DIR}/ui`). Upstream Dockerfile creates `/opt/data` and `/opt/data/logs` with mode 777 and `VOLUME ["/opt/data"]`.
- Optional `/data/media` bind mount for leftover-folder cleanup (same path that Radarr/Sonarr report).
- Upstream start.sh stages the UI from `/opt/app/apps/server/dist/ui` into `$DATA_DIR/ui` on every boot (rm + cp + sed of `/__PATH_PREFIX__` in files under `$DATA_DIR/ui` only). Read-only bundle, so the copy restores write permission.

## User/UID and permissions
- Upstream Dockerfile: `USER node` (uid 1000). Docs: default runtime UID:GID is 1000:1000; the host data directory must be readable and writable by it (for example `chown -R 1000:1000 /opt/data`). No PUID/PGID variables are documented.

## Health endpoints
- `GET /api/health/live`: 200 while the process runs (no DB check).
- `GET /api/health/ready`: runs `SELECT 1` on the DB; 200 if reachable, 503 if not.
- `GET /api/health`: alias for `/ready`.
- Paths are prefixed by `BASE_PATH` when set.
- Upstream healthcheck script: `curl -fsS http://127.0.0.1:${UI_PORT}${PATH_PREFIX}/api/health/ready` (loopback hardcoded; BASE_PATH trimmed to `/<path>`; port from UI_PORT, default 6246).
- Swagger/OpenAPI at `/api/swagger`.

## Version/release info
- Latest release: `v3.33.0`, published 2026-11-20 (marked Latest, commit `5d3146e`). Headlines: TV overlay scope setting (#3990), TMDB franchise properties in rule groups (#4096), Romanian language (#4115), BASE_PATH fixes (#4134, #4123), axios-retry replaced (#4133), ~50 dependency updates. **Breaking changes: none listed. DB migration: `overlayScope` column added to `collection`.**
- Previous: `v3.32.0`, published 2026-11-05 (commit `ad17e05`). Highlights: 14-day seeding removal rule, Plex connection settings without restart, Russian and Traditional Chinese, ZFS free-space fix.
- Renovate (plan.md): `datasource=github-releases depName=Maintainerr/Maintainerr versioning=semver`.
- **The TrueCharts chart now pins `ghcr.io/maintainerr/maintainerr:3.33.0` (see truecharts summary), not 3.32.0 as the draft and plan say.**

## Arch support
- Docs: images for amd64 and arm64 on GHCR and Docker Hub. amd64 overlays/posters need an x86-64-v2 CPU (repo README; not in the installation docs).

## License
MIT: "Copyright (c) 2026 Maintainerr" (LICENSE at v3.33.0; repo page also MIT).

## npm
`https://registry.npmjs.org/maintainerr` returns HTTP 404: no npm package (plan.md agrees).

## Gotchas
- Data dir must be writable by 1000:1000 on the host; our build runs as `apps` (568) per the ContainerForge model, so the chart's /opt/data mapping needs a path change to `/config`.
- The repo's default branch is `development`; the `:development` image tag is for unreleased code and cannot be moved back to stable (docs).
- Overlay and poster features on amd64 need x86-64-v2 (sharp); on older CPUs they are disabled, not a startup failure (repo README).
