# Upstream: gethomepage/homepage (Dockerfile, docker-entrypoint.sh, README, release page)

## Source URL(s) + date
- https://raw.githubusercontent.com/gethomepage/homepage/08a0c1df566464bfdb327f3fd8f1f5a058d56640/Dockerfile (fetched 2026-11-27; blob URL same file)
- https://raw.githubusercontent.com/gethomepage/homepage/08a0c1df566464bfdb327f3fd8f1f5a058d56640/docker-entrypoint.sh (fetched 2026-11-27)
- https://raw.githubusercontent.com/gethomepage/homepage/main/README.md (fetched 2026-11-27; repo main page)
- https://github.com/gethomepage/homepage/releases/tag/v2.8.0 (HTML, title "Release v2.8.0 · gethomepage/homepage"; no download links in page)
- API `releases/tags/v2.8.0`: 403 (see README).
- Renamed from benphelps/homepage (old name, do not use).

## What it is
- Homepage: self-hosted services landing page with docker and service integrations. Next.js app (`node server.js` standalone). License Apache-2.0 (Dockerfile LABEL).

## Build (Dockerfile)
| Stage | Base | Steps |
| --- | --- | --- |
| builder | `node:24-slim` | `WORKDIR /app`; `mkdir config`; `COPY . .`; ARGs `CI`, `BUILDTIME`, `VERSION`, `REVISION`; if `CI != true`: `corepack enable`, `corepack prepare pnpm@latest --activate`, `pnpm install --frozen-lockfile --prefer-offline`, `pnpm run build` with `NEXT_TELEMETRY_DISABLED=1` and `NEXT_PUBLIC_BUILDTIME/VERSION/REVISION`. Otherwise uses prebuilt app from CI context. |
| runner | `node:24-alpine` | labels (title, description, url, documentation, source, licenses Apache-2.0); `WORKDIR /app`; `COPY --link --chown=1000:1000 /public ./public/`; `COPY --link --chmod=755 docker-entrypoint.sh /usr/local/bin/`; copy `.next/standalone/` and `.next/static`; `apk add --no-cache su-exec iputils-ping shadow`; `USER root` |

- Note: pnpm version in builder is `latest` (unpinned in Dockerfile).

## Entrypoint/flags
- `ENTRYPOINT ["docker-entrypoint.sh"]`, `CMD ["node", "server.js"]`.
- Entrypoint: `set -e`; `PUID` default 0, `PGID` default 0; symlink `/app/config` -> `/config` if `/app/config` missing; `HOMEPAGE_BUILDTIME=$(date +%s)`; `HOSTNAME` default `::` with a node-based IPv6 bind test, falls back to `0.0.0.0` on failure; if `PUID != 0`: chown `/app/config` (when owner differs), mkdir + chown `/app/config/logs`, chown `/app/.next` (when `PUID != 0`); drop privileges with `exec su-exec ${PUID}:${PGID} "$@"` when root and PUID != 0; else `exec "$@"`.

## Env vars (Dockerfile ENV and entrypoint)
| Name | Value / default |
| --- | --- |
| NODE_ENV | production |
| HOSTNAME | `::` (entrypoint default; fallback 0.0.0.0) |
| PORT | 3000 |
| PUID | 0 (entrypoint default) |
| PGID | 0 (entrypoint default) |
| HOMEPAGE_BUILDTIME | set by entrypoint (date +%s) |
| HOMEPAGE_ALLOWED_HOSTS | required host allow-list (README: `gethomepage.dev` example; "may need port") |
| CI | build ARG; prebuilt app when `true` |
| NEXT_TELEMETRY_DISABLED | 1 (builder only) |

## Ports
- `EXPOSE $PORT` (3000).

## Volumes/paths
- `/app/config` (symlink to `/config` when absent). Logs in `/app/config/logs`.
- `/public` copied to `/app/public`.

## User/UID
- Image sets `USER root` and relies on PUID/PGID + su-exec to run as that uid.

## Healthcheck
- `HEALTHCHECK --interval=10s --timeout=3s --start-period=20s CMD wget --no-verbose --tries=1 --spider -Y off http://127.0.0.1:$PORT/api/healthcheck || exit 1`.

## Version/asset naming
- Tag `v2.8.0`. Release page has no asset download links. Image tags are `v`-prefixed on GHCR (chart).

## Arch
- Not stated in fetched sources. Node-based, arch-neutral source. Runner alpine (musl), so `copy-from` from this image is not portable to glibc (plan note).

## Gotchas
- `su-exec` drops privileges to PUID:PGID only when running as root and PUID != 0.
- Runner is alpine (`iputils-ping`, `shadow` installed).
- Next.js host check uses `HOMEPAGE_ALLOWED_HOSTS`; probes in chart send `Host: localhost:3000`.
