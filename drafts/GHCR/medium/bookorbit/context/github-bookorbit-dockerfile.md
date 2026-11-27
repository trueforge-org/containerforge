# Upstream Dockerfile, server entrypoint and .env example: bookorbit/bookorbit (commit c1dd6b4f)

**Source URL(s):** https://raw.githubusercontent.com/bookorbit/bookorbit/c1dd6b4f1947ff50843a155e12e70f1e7d15f0c7/Dockerfile (blob URL in urls.txt is the same file); .../server/entrypoint.sh; .../.env.example (fetched 2026-11-27). Commit is pre-3.10.0 per plan.md; not the v3.10.0 tag.

## Base
- `ARG NODE_IMAGE=node:26.13.1-alpine3.24@sha256:6bd9ab43...`; `base`: `npm install -g pnpm@11.28.9`.

## Stages
1. **client-builder**: copies package.json, pnpm-workspace.yaml, pnpm-lock.yaml, patches/, packages/types, client/package.json; `pnpm install --filter client... --frozen-lockfile` (cache mount); copies packages/ and client/; `pnpm --config.verify-deps-before-run=false --filter client run build-only`.
2. **server-builder**: same pattern with server; `pnpm --filter server run build`; `pnpm --config.allow-unused-patches=true --filter server deploy --prod --legacy /deploy`; copies `server/dist` and `server/src/db/migrations` into `/deploy`.
3. **runtime** (`NODE_IMAGE`):
   - ARG `APP_VERSION=dev`; ENV `APP_VERSION`, `KOBO_CLOUDSCRAPER_PYTHON=/opt/bookorbit-python/bin/python`, `KOREADER_PLUGIN_PATH=/app/koreader-plugin/bookorbit.koplugin`, `NODE_ENV=production`, `PORT=3000`.
   - apk: `libexpat>=2.9.0-r0 poppler-utils djvulibre util-linux su-exec ffmpeg python3 py3-pip tini tzdata`.
   - venv `/opt/bookorbit-python`; pip installs `server/requirements/kobo-cloudscraper.txt`; then pip uninstalled and py3-pip deleted; npm, npx removed.
   - COPY deploy to `./` (node:node); client dist to `./public`; client locales to `./locales`; `entrypoint.sh`, `file-env.sh` to `/app`; LICENSE, NOTICE, ADDITIONAL_TERMS.md; `bin/kepubify/`; `vendor/foliate/`; `koreader-plugin/bookorbit.koplugin/`.
   - RUN: `sed -i 's/\r$//'` on entrypoint and file-env; chmod kepubify; `mkdir -p /books /data/covers /data/book-bucket /tmp`; `chown -R node:node /data /tmp`.
   - `EXPOSE 3000`
   - HEALTHCHECK every 30s: wget `http://${HOST}:${PORT}/api/v1/health` (HOST default 127.0.0.1 handling for ::, 0.0.0.0).
   - `ENTRYPOINT ["/sbin/tini", "-s", "--"]`, `CMD ["sh", "/app/entrypoint.sh"]`.
   - LABEL licenses `AGPL-3.0-only`; source github; url https://bookorbit.app.

## server/entrypoint.sh (key behaviour)
- Sources `file-env.sh` (`_FILE` env support; load_file_env).
- `DATABASE_URL` built if empty: `postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST:-postgres}:${POSTGRES_PORT:-5432}/${POSTGRES_DB}` (values URL-encoded via node).
- `APP_DATA_PATH` default `/data`; `book_bucket_path=$APP_DATA_PATH/book-bucket`; `HOME` default `/tmp`.
- `APP_UID`/`APP_GID` from PUID/PGID (default 1000); must be numeric.
- `NODE_MAX_OLD_SPACE_SIZE` default `auto` (cgroup-based heap sizing), or numeric MB.
- Creates `$APP_DATA_PATH`, `$APP_DATA_PATH/covers`, `$book_bucket_path`.
- Root branch: fixes ownership (unless `BOOKORBIT_FIX_PERMISSIONS=false`; only within /data or /tmp), checks writability, `exec su-exec` to PUID:PGID running `node dist/scripts/migrate.js && exec node --max-old-space-size=... dist/main.js`.
- Non-root branch: checks writability as current user, then `node dist/scripts/migrate.js`, then `exec node --max-old-space-size="$NODE_MAX_OLD_SPACE_SIZE" dist/main.js`.

## .env.example (container-relevant)
| Var | Example / note |
| --- | --- |
| APP_IMAGE | compose only |
| APP_PORT | host publish port 3000 (compose only, not container) |
| HOST | optional listen address (commented) |
| BOOKS_HOST_PATH | compose only, mounts at /books |
| PUID / PGID | 1000 |
| POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DB | bookorbit |
| JWT_SECRET | required (placeholder in example) |
| SETUP_BOOTSTRAP_TOKEN | required for initial /auth/setup (x-setup-token header) |
| APP_URL | external URL |
| NODE_MAX_OLD_SPACE_SIZE | 2048 (number or auto) |
| DATABASE_URL / DATABASE_URL_FILE | optional override; needs uuid-ossp, pg_trgm, vector extensions |
| CLIENT_URL | CORS origin when frontend on other domain |
| LIBRARY_BROWSE_ROOT | e.g. /books |
| BOOKORBIT_FIX_PERMISSIONS | default true |
| *_FILE | `POSTGRES_PASSWORD_FILE`, `JWT_SECRET_FILE`, `SETUP_BOOTSTRAP_TOKEN_FILE`, `DATABASE_URL_FILE` |
| READ_ALOUD_* | optional worker, compose profile (not needed for base image) |

## Ports
- 3000

## Volumes/paths
- `/data` (covers, book-bucket, app data), `/books` (library), `/tmp`. No VOLUME.

## User/UID
- Image has `node` user; root branch uses PUID/PGID via su-exec.

## Gotchas
- Requires PostgreSQL with uuid-ossp, pg_trgm, unaccent, vector (pgvector) per chart values comment and .env.example.
- Healthcheck uses wget (Alpine busybox).
