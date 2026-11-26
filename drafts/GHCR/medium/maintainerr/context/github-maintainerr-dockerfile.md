# Maintainerr upstream Dockerfile, docker/start.sh and docker/healthcheck.sh (commit e6327bbb68b9)

**Source URL(s):** https://github.com/Maintainerr/Maintainerr/blob/e6327bbb68b9/Dockerfile (fetched via https://raw.githubusercontent.com/Maintainerr/Maintainerr/e6327bbb68b9/Dockerfile); https://raw.githubusercontent.com/Maintainerr/Maintainerr/e6327bbb68b9/docker/start.sh; https://raw.githubusercontent.com/Maintainerr/Maintainerr/e6327bbb68b9/docker/healthcheck.sh
**Fetched:** 2026-11-26

## Dockerfile

### base stage
- `FROM` Node 26.13.0 Alpine, pinned by digest (plain `-alpine` tag for Dependabot).

### builder stage (from base)
- WORKDIR `/app`.
- apk (no cache): build-base, python3, pkgconfig, cairo-dev, pango-dev, pixman-dev (node-canvas build deps).
- `npm install -g corepack@latest` then `corepack enable`.
- Copies `package.json`, `yarn.lock`, `.yarnrc.yml`, `turbo.json`; `corepack install`.
- Copies `.yarn/releases`, plus package.json files for `apps/server`, `apps/ui`, `packages/contracts`.
- `yarn install --network-timeout 99999999`.
- `COPY . .`.
- Appends `VITE_BASE_PATH=/__PATH_PREFIX__` to `./apps/ui/.env` (heredoc).
- `yarn turbo build`.
- `yarn workspaces focus --all --production`.
- `mkdir -p ./packages/contracts/node_modules ./apps/server/node_modules`.

### runner stage (from base)
- WORKDIR `/opt/app`.
- `COPY --from=builder --chmod=755 --chown=node:node`:
  - `/app/node_modules` -> `./node_modules`
  - `/app/apps/server/dist` -> `./apps/server/dist`
  - `/app/apps/server/package.json` -> `./apps/server/package.json`
  - `/app/apps/server/node_modules` -> `./apps/server/node_modules`
  - `/app/apps/ui/dist` -> `./apps/server/dist/ui`
  - `/app/apps/server/assets` -> `./apps/server/dist/assets` (fonts)
  - `/app/packages/contracts/dist`, `package.json`, `node_modules` -> matching `./packages/contracts/` paths
- Copies `docker/start.sh` and `docker/healthcheck.sh` to `/opt/app/` (755, node:node).
- `mkdir -m 777 /opt/data /opt/data/logs` then `chown -R node:node /opt/data`.
- `apk --no-cache upgrade`; `apk --update --no-cache add curl cairo pango pixman`; then removes npm, npx and `/usr/local/lib/node_modules/npm`.
- ENV/ARG: `NODE_ENV=production`, `DEBUG=false`, `UI_PORT=6246`, `UI_HOSTNAME=0.0.0.0`, `GIT_SHA`, `VERSION_TAG=develop`, `BASE_PATH` (no default). `DATA_DIR=/opt/data`. `UV_USE_IO_URING=0`.
- `USER node`; `EXPOSE 6246`.
- `HEALTHCHECK` interval 30s, timeout 5s, start-period 40s, retries 3, runs `/opt/app/healthcheck.sh`.
- `VOLUME ["/opt/data"]`; `ENTRYPOINT ["/opt/app/start.sh"]`; no CMD.

## docker/start.sh
- Reads `BASE_PATH` (default empty) into `BASE_PATH_REPLACE`; `DATA_DIR` (default `/opt/data`).
- Source: `/opt/app/apps/server/dist/ui` (bundled UI). Destination: `$DATA_DIR/ui`.
- Steps: `chmod -R u+w` on the destination if present; `rm -rf` destination; `mkdir -p`; `cp -R` bundle in; `chmod -R u+w` copy. Any failure prints a message to stderr and exits 1 (says the data directory must be writable by the container user).
- `find` regular files under the destination and `sed -i "s,/__PATH_PREFIX__,$BASE_PATH_REPLACE,g"` (exit 1 on failure).
- `cd /opt/app/apps/server` (exit 1 on failure). `npm_package_version` from `node -p "require('./package.json').version"`, exported (comment: otherwise app shows 0.0.1).
- `exec node dist/main` (direct, not npm, to avoid the update banner).
- Rationale in comments: rewrite happens in the data dir so the app tree need not be world-writable; bundle is read-only, so `cp` preserves that mode and write permission is restored before and after the copy.
- No log files written by the script.

## docker/healthcheck.sh
- `#!/bin/sh`. URL `http://127.0.0.1:${PORT}${PATH_PREFIX}/api/health/ready`.
- Port: `UI_PORT`, default 6246. `BASE_PATH` read (trimmed of leading and trailing `/`), and `PATH_PREFIX` built as `/<value>` or empty. `UI_HOSTNAME` is not read; host is hardcoded to 127.0.0.1.
- `exec curl -fsS` (fails on HTTP 4xx/5xx); exit status is curl's.

## Gotchas for our build
- Upstream base is Node 26 Alpine (musl). Our `python-node` base is glibc; the Node version there is not verified (plan.md section 3).
- Upstream writes `/opt/data/ui` and `/opt/data/logs`; the plan moves these to `/config` (`DATA_DIR=/config`).
- Upstream `mkdir -m 777` and `chown` are not needed in our layout.
- `start.sh` must be kept or rewritten with `/config` paths. The plan's `start.sh` mirrors this logic.
- `healthcheck.sh` is for the upstream `HEALTHCHECK`; ContainerForge uses `container-test.yaml` probes instead (plan.md).
