# slink docker/Dockerfile.prod (commit aefc970)

Source URL(s): https://github.com/andrii-kryvoviaz/slink/blob/aefc97065c20c543299d23b7315551c979705378/docker/Dockerfile.prod (raw), fetched 2026-11-26.

## Build args (declared, no defaults here)
- `ALPINE_VERSION`, `COMPOSER_VERSION`, `UPLOAD_MAX_FILESIZE_IN_BYTES`, `VERSION` (default `dev`)
- Parser directive: `# check=skip=InvalidDefaultArgInFrom`

## Stages
| Stage | Base | Purpose |
| --- | --- | --- |
| deps-client-prod | `node` | `pnpm install --prod --frozen-lockfile --ignore-scripts` in /client from services/client (package.json, pnpm-lock.yaml, pnpm-workspace.yaml); prunes *.md *.ts *.map |
| build-client | `node` | `pnpm install --frozen-lockfile`; copies plugins, src, static, tsconfig.json, vite.config.ts, wuchale.config.js; `pnpm exec svelte-kit sync`; `NODE_OPTIONS="--max-old-space-size=2048 --expose-gc" pnpm build` |
| source | `dhi.io/alpine-base:${ALPINE_VERSION}-dev` | copies services/api {bin,config,public,shared,src,composer.json} to /source; chmod -R g+r |
| vendor | `composer:${COMPOSER_VERSION}` | `composer install --ignore-platform-reqs --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts` (cache mount /tmp/cache) |
| prod | `FROM common` (common stage defined in docker/Dockerfile, NOT fetched) | final image |

## prod stage steps
- `rm -rf /sbin/apk /etc/apk /lib/apk /usr/share/apk /var/cache/apk` (apk removed from final image)
- COPY s6 rc.d: `./docker/config/s6-overlay/s6-rc.d/prod/` -> `/etc/s6-overlay/s6-rc.d/` (--chmod=755)
- ENV: `APP_ENV=prod`, `NODE_ENV=production`, `BODY_SIZE_LIMIT=Infinity`, `MERCURE_HUB_URL=http://localhost:8080/.well-known/mercure`, `MERCURE_PUBLIC_URL=/sse`
- `mkdir -p /data/redis /data/caddy /app/var/data/keys /app/slink/images`
- `chown -R slink:slink /services /app /data`; `chown slink:slink /run`; `chmod -R 770 /app /data`; `chmod -R g+s /app /services /data`; `chmod 750 /app/var/data/keys`
- COPY --from=vendor -> ./api/vendor; --from=source -> ./api; --from=build-client /client/build -> ./client/svelte-kit; package.json -> ./client/svelte-kit/package.json; services/client/server.js -> ./client/svelte-kit/server.js; --from=deps-client-prod node_modules -> ./client/svelte-kit/node_modules; services/api/.env.example -> ./api/.env
- `RUN slink cache:warm --no-optional-warmers --quiet && slink cache:clear --quiet && chown -R slink:slink /services/api/var`

## Ports / healthcheck
- `EXPOSE 3000`
- HEALTHCHECK `--interval=30s --timeout=10s --start-period=5s --retries=3`: `wget --no-verbose --tries=1 --spider http://127.0.0.1:8080/api/health`
- Note: health checks port 8080, EXPOSE is 3000.

## Final
- `ARG VERSION=dev`; `ENV SLINK_VERSION=${VERSION}`
- Runtime user: `slink` (named user in common stage).

## Gotchas
- Final image runs s6-overlay; Dockerfile.prod `common` base not available in this context (see README).
- Dependencies: Symfony (PHP via composer), SvelteKit (node), redis, Mercure hub on 8080, caddy (/data/caddy).
