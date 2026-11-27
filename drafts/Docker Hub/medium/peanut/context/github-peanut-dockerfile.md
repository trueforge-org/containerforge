# GitHub: Brandawg93/PeaNUT Dockerfile + package.json (commit 7ad39fd50525a3c7e5f0979fef7defbcc7f65229)
Source URL(s): https://raw.githubusercontent.com/Brandawg93/PeaNUT/7ad39fd50525a3c7e5f0979fef7defbcc7f65229/Dockerfile , .../package.json (fetched 2026-11-27)

## Build
- Base stages: node:lts-slim (pnpm, corepack enable), deps, build, runner dhi.io/node:24
- deps: COPY package.json pnpm-lock.yaml*; pnpm fetch --frozen-lockfile; pnpm i --frozen-lockfile --ignore-scripts --prefer-offline (cache mount id=pnpm at /pnpm/store)
- build: COPY node_modules from deps; COPY . /app; pnpm run next-ws; pnpm run build; rm .next/standalone/.next/cache; mkdir -p /config
- Env in build: NODE_ENV=production, NEXT_TELEMETRY_DISABLED=1, PNPM_HOME=/pnpm

## Runtime (runner)
- COPY --chown=1000:1000 from build: .next/standalone -> ./, .next/static -> ./.next/static, /config -> /config, src/app/api -> src/app/api, package.json
- entrypoint.mjs and healthcheck.mjs copied from repo root (chmod 755)
- ENV CI=true, NODE_ENV=production, NEXT_TELEMETRY_DISABLED=1, WEB_HOST=0.0.0.0, WEB_PORT=8080, BASE_PATH="", SETTINGS_FILE=/config/settings.yml, AUTH_FILE_PATH=/config/auth.yaml, DEBUG=false
- EXPOSE $WEB_PORT
- HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD ["node","healthcheck.mjs"]
- ENTRYPOINT ["node","entrypoint.mjs"]
- LABEL licenses Apache-2.0

## package.json at this commit
- name peanut, version 6.1.2 (predates v6.2.0 tag)
- scripts: build = next build; start = node server.js; build:local = npm run build && cp -r .next/static .next/standalone/.next/; next-ws = next-ws patch --yes
- Main deps: next ^16.3.8, react/react-dom ^19.3.0, next-auth 5.0.0-beta.32, next-ws, ws, zod, bcryptjs, chokidar, js-yaml, recharts, @xterm/*, @influxdata/influxdb-client
- No engines field, no license field in package.json

## Gotchas
- Dockerfile uses dhi.io (Docker Hardened Images) base for runner, not Docker Hub public node
- Dockerfile runner has no USER directive; files owned by uid 1000
