# timvisee/send Dockerfile (master, fetched via GitLab API raw)

## Source URL(s) + date
- https://gitlab.com/api/v4/projects/timvisee%2Fsend/repository/files/Dockerfile/raw?ref=master (fetched 2026-11-27)
- https://gitlab.com/timvisee/send/-/blob/master/Dockerfile: same file (not fetched separately).

## Build (two stages, both `node:26.12.1-alpine`)
- Common: `apk add shadow`; `groupmod -g 1001 node`; `usermod -u 1001 -g 1001 node`; create group/user `app` uid/gid 1000 (home /app).
- Builder: `COPY --chown=app:app . /app`; `USER app`; `WORKDIR /app`; `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm ci && npm run build`.
- Final:
  - `USER app`, `WORKDIR /app`.
  - copies `package*.json`, `app`, `common`, `public/locales`, `server` (owner app), and `/app/dist` from builder.
  - `npm ci --omit=dev && npm cache clean --force`.
  - `mkdir -p /app/.config/configstore`; `ln -s dist/version.json version.json`.
  - `ENV PORT=1443`; `EXPOSE ${PORT}`.
  - `CMD ["node", "server/bin/prod.js"]`.
- No VOLUME, no HEALTHCHECK, no ENTRYPOINT.

## Runtime
- Port 1443. User `app` uid 1000 gid 1000.
- Writable dirs: `/app/.config/configstore`; FILE_DIR defaults to `/uploads` (config.js) and must be writable.

## Gotchas
- Node 26.12.1 base in upstream; plan notes the TrueCharts/ContainerForge base Node version is unverified.
- Upstream does not declare a volume; chart mounts `/uploads`.
