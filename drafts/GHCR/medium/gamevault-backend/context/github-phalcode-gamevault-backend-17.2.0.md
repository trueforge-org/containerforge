# Upstream: Phalcode/gamevault-backend 17.2.0 (Dockerfile, entrypoint.sh, README)

## Source URL(s) + date
- https://raw.githubusercontent.com/Phalcode/gamevault-backend/17.2.0/Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/Phalcode/gamevault-backend/17.2.0/entrypoint.sh (fetched 2026-11-27)
- https://raw.githubusercontent.com/Phalcode/gamevault-backend/17.2.0/README.md (fetched 2026-11-27)
- Blob URL https://github.com/Phalcode/gamevault-backend/blob/17.2.0/Dockerfile = same file (not fetched).

## What it is
- GameVault backend: Node app (`dist/src/main.js`), self-hosted DRM-free game library. Built with pnpm.
- License (README): CC BY-NC-SA 4.0 (non-commercial).

## Build stages (Dockerfile)
| Stage | Base | Steps |
| --- | --- | --- |
| base | `node:lts-slim` | apt: build-essential, ca-certificates, curl, g++, make, p7zip-full, p7zip-rar, postgresql-common, python-is-python3, python3, sudo; PGDG postgresql-client (latest, via `apt.postgresql.org.sh`); `npm i -g pnpm@11`; `WORKDIR /app` |
| build | base | `COPY package.json pnpm-lock.yaml pnpm-workspace.yaml`, `pnpm install --frozen-lockfile`, `COPY . .`, `pnpm run build` |
| prod-deps | base | same copy, `pnpm install --prod --frozen-lockfile` |
| release | base | `NODE_ENV=production`; copies `dist` (from build) and `node_modules` (from prod-deps), `entrypoint.sh` -> `/usr/local/bin/`; chmod +x |

- Debian base (`sed` edits `/etc/apt/sources.list.d/debian.sources` to add non-free, contrib). Not alpine.
- Chromium download skipped (`PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true`).

## Entrypoint/flags
- `ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]`, `CMD ["dist/src/main.js"]`.
- entrypoint.sh: `set -e`, prints banner. If `id -u` = 0: chown -R PUID:PGID and chmod -R 775 on `/app/dist /config /files /media /logs /db /plugins /savefiles`; if PUID/PGID != 1000 then `groupmod`/`usermod` node user; then `exec sudo -u "#${PUID}" -g "#${PGID}" -E node "$@"`. Non-root: `exec node "$@"`.

## Env vars (Dockerfile ENV)
| Name | Default |
| --- | --- |
| TZ | Etc/UTC |
| PUID | 1000 |
| PGID | 1000 |
| PUPPETEER_SKIP_CHROMIUM_DOWNLOAD | true |
| NPM_CONFIG_PREFIX | /home/node/.npm-global |
| PNPM_HOME | /pnpm |
| SERVER_PORT | 8080 |
| SERVER_HTTPS_PORT | 8443 |
| YES | yes |
| PATH | prepends /home/node/.npm-global/bin:/pnpm |
| NODE_ENV (release stage) | production |

## Ports
- `EXPOSE ${SERVER_PORT}/tcp`, `EXPOSE ${SERVER_HTTPS_PORT}/tcp` (8080, 8443).

## Volumes/paths
- Dockerfile mkdir: `/config /files /media /logs /db /plugins /savefiles`. Build: `chown -R node:node` and `chmod -R 777` on `/app/dist` plus those dirs.
- No VOLUME instruction.

## User/UID
- No USER in Dockerfile (root default). Entrypoint drops to `PUID:PGID` (default 1000:1000) via sudo.
- Entrypoint assumes a `node` user exists (it is re-mapped with groupmod/usermod).

## Healthcheck
- `HEALTHCHECK --start-period=300s CMD curl -f http://localhost:${SERVER_PORT}/api/status || exit 1`.

## Version/asset naming
- No release binary assets (per plan, verified earlier). Build from source at tag `17.2.0`.
- Release page https://github.com/Phalcode/gamevault-backend/releases/tag/17.2.0 returned title "Release Version 17.2.0".

## Gotchas
- `sudo` is installed and used by the entrypoint; keep it for PUID/PGID drop, or the drop fails.
- Entrypoint uses `groupmod`/`usermod` which requires root start.
- Debian `sources.list.d/debian.sources` sed assumes Debian (DEB822 format) base.
- Dockerfile copies `entrypoint.sh` from build context root.
- Chart probes use `/api/v1/health`; Dockerfile healthcheck uses `/api/status`.
