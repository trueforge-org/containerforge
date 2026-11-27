# GitHub: cglatot/pasta Dockerfile + package.json (commit 1030b05cdef24d8ea382223496af0c050d45ad46)
Source URL(s): https://raw.githubusercontent.com/cglatot/pasta/1030b05cdef24d8ea382223496af0c050d45ad46/Dockerfile , .../package.json (fetched 2026-11-27)

## Build
- Stage builder: FROM --platform=$BUILDPLATFORM node:24-alpine; ARG VITE_APP_VERSION (ENV); COPY package*.json; npm ci; COPY . .; npm run build
- npm build script: tsc -b && vite build
- Stage runtime: FROM node:24-alpine; WORKDIR /app
- ENV NODE_ENV=production, PORT=80, PASTA_MODE=server, PASTA_CONFIG_DIR=/config, PASTA_DIST_DIR=/app/dist
- RUN mkdir -p /config
- COPY from builder: /app/dist ./dist, /app/src/shared ./src/shared, /app/server/src ./server/src, /app/package.json ./package.json
- EXPOSE 80
- CMD ["node","--disable-warning=ExperimentalWarning","server/src/index.ts"]
- Runtime stage has no npm ci: no node_modules copied (server runs TypeScript directly via node)

## package.json (3.0.0)
- name pasta, version 3.0.0, type module, license/engines not set
- scripts: start:server = node --disable-warning=ExperimentalWarning server/src/index.ts; test = node --test server/src/__tests__/scanner.test.ts; build = tsc -b && vite build
- dependencies: @fortawesome/fontawesome-free, @tanstack/react-query, bootstrap, react, react-dom
- devDependencies: vite, typescript, eslint and @types (build only)

## Gotchas
- Node 24 LTS image; runs .ts source directly (native TS stripping)
- Runtime copies only server sources and frontend dist; server-side runtime npm deps are not installed in the runtime stage (package.json lists no server-only deps)
