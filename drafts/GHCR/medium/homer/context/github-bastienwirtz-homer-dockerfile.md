# Upstream Dockerfile: bastienwirtz/homer @ b3f7fd87813ce4ea9c4ab91f9ffdca81c7e19db2

Source URL(s): https://raw.githubusercontent.com/bastienwirtz/homer/b3f7fd87813ce4ea9c4ab91f9ffdca81c7e19db2/Dockerfile (fetched 2026-11-27; blob URL is the same file)

## Build stage
- `FROM --platform=$BUILDPLATFORM node:24-alpine3.23 AS build-stage`
- ENV PNPM_HOME=/pnpm, PATH updated
- `corepack enable && corepack use pnpm@10`
- WORKDIR /app; COPY package.json pnpm-lock.yaml pnpm-workspace.yaml; `pnpm install --frozen-lockfile`; COPY . .; `pnpm build` (output /app/dist)

## Runtime stage
- `FROM alpine:3.23`
- ARG VERSION_TAG=latest (label version only)
- Labels: licenses "Apache-2.0", source https://github.com/homer-dashboard/homer, url https://hub.docker.com/r/b4bz/homer
- ENV GID=1000 UID=1000 PORT=8080 SUBFOLDER=/_ INIT_ASSETS=1 IPV6_DISABLE=0
- `addgroup -S lighttpd -g ${GID}`; `adduser -D -S -u ${UID} lighttpd lighttpd`
- `apk add -U --no-cache tzdata lighttpd`
- WORKDIR /www
- COPY lighttpd.conf -> /lighttpd.conf; lighttpd-ipv6.sh -> /etc/lighttpd/ipv6.sh; entrypoint.sh -> /entrypoint.sh
- COPY --from=build-stage --chown=1000:1000 /app/dist -> /www/
- COPY --from=build-stage --chown=1000:1000 /app/dist/assets -> /www/default-assets
- `USER ${UID}:${GID}`
- HEALTHCHECK `--start-period=10s --start-interval=1s --interval=30s --timeout=5s --retries=3 CMD wget --no-verbose -Y off --tries=1 --spider http://127.0.0.1:${PORT}/ || exit 1`
- EXPOSE ${PORT}
- ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
- No VOLUME instruction.

## Env vars
| var | default | use |
| --- | --- | --- |
| UID / GID | 1000 | lighttpd user |
| PORT | 8080 | listen port |
| SUBFOLDER | /_ | sub-path (`null` documented in README) |
| INIT_ASSETS | 1 | seed assets |
| IPV6_DISABLE | 0 | disable IPv6 listen |

## Gotchas
- Upstream runtime is lighttpd, not nginx. ContainerForge plan uses nginx base instead.
- Upstream `entrypoint.sh` and `lighttpd.conf` are referenced but not fetched in this pass.
