# ghostfolio — implementation plan
> Source: ./draft.md · Target: apps/ghostfolio/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 3.100.0 (latest release, published 15 Nov; matches the draft tag, commit 45d6923) |
| Renovate | `datasource=github-releases depName=ghostfolio/ghostfolio versioning=loose` (tags are plain `3.100.0`, no `v`) |
| License | AGPL-3.0 (SPDX `AGPL-3.0-only`; UNVERIFIED which of -only/-or-later: confirm in the repo `LICENSE` header before writing `LICENSE`) |
| Source URL | https://github.com/ghostfolio/ghostfolio |
| Download | No prebuilt binary. Source tarball `https://github.com/ghostfolio/ghostfolio/archive/refs/tags/${VERSION}.tar.gz` (same for amd64 and arm64; Node app, build is arch independent) |
| Checksum | Upstream publishes none. Pin by tag. UNVERIFIED: no digest to compare. |
| Upstream Dockerfile | Reviewed (main branch). Two stages on `node:22-slim`. Builder: `apt install g++ git make openssl python3`, `npm ci`, `NX_DAEMON=false npm run build:production`, then in `dist/apps/api` `npm ci` plus copying `.config`, `prisma`, original `package.json`/`package-lock.json`, then `npm run database:generate-typings`. Runtime: `NODE_ENV=production`, curl and openssl, copies `dist/apps` to `/ghostfolio/apps/`, `WORKDIR /ghostfolio/apps/api`, `EXPOSE ${PORT:-3333}`, `USER node`, `CMD /ghostfolio/entrypoint.sh`. |
| Upstream entrypoint | `npx prisma migrate deploy`, `npx prisma db seed`, `exec node main` (all `set -ex`). |
| Env vars (from `.env.example`) | `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`, `ACCESS_TOKEN_SALT`, `JWT_SECRET_KEY`, `DATABASE_URL` (`postgresql://user:pass@host:5432/db?connect_timeout=300`). `POSTGRES_DB/USER/PASSWORD` are compose-only variables used to build `DATABASE_URL`; the app does not read them. `PORT` is used by the upstream `EXPOSE` (default 3333); UNVERIFIED that the Nest app reads `PORT` (confirm in `apps/api/src/main.ts`). |
| Engine | Release 3.100.0 requires Node `>=22.23.5`. The ubuntu base ships Node 26.13.1 (`apps/ubuntu/docker-bake.hcl`), which is outside upstream's tested 22 line. See risks. |
| Ports | 3333/tcp http (web UI and API) |
| Dependencies | postgresql ✅ (hard), valkey ✅ (Redis). Upstream compose and `.env.example` treat Redis as required, so the draft's "optional" is likely wrong. UNVERIFIED: confirm in source whether the app starts without Redis. |

## 2. Target layout

```
apps/ghostfolio/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, `etc/` or `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

- Build stage: `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (Node plus python3 for node-gyp, as the draft proposes; g++/make from apt).
- Final stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (already contains Node under `/usr/local`, plus curl, openssl is added only if missing).
- Why: the repo table maps Node apps to ubuntu; the Nx build needs Python and a compiler, so only the builder uses python-node. Closest siblings: `apps/it-tools` (node builder stage, runtime stage), `apps/bookstack` (DB-backed web app).

## 4. Dockerfile

1. `FROM <python-node> AS builder`, `ARG VERSION`, `USER root`, `ENV HOME=/tmp NX_DAEMON=false npm_config_cache=/tmp/npm`.
2. `apt-get install -y --no-install-recommends g++ make git openssl` (python3 comes from the base; check before adding).
3. Download and extract the tag tarball to `/src` with `curl -fsSL`, `tar xzf --strip-components=1`.
4. `npm ci` then `npm run build:production`; then in `/src/dist/apps/api` copy `package-lock.json`, `.config`, `prisma`, original `package.json` and run `npm ci` and `npm run database:generate-typings`, mirroring upstream.
5. `FROM <ubuntu> ` final stage, `ARG VERSION`, `USER root`, `ENV NODE_ENV=production HOME=/tmp npm_config_cache=/tmp/npm PRISMA_HIDE_UPDATE_MESSAGE=1`.
6. `COPY --from=builder --chown=568:568 /src/dist/apps /app/ghostfolio/apps/` and copy the repo `LICENSE` to `/usr/share/licenses/ghostfolio/LICENSE`.
7. `COPY --chmod=0755 . /` (brings `start.sh`), `WORKDIR /app/ghostfolio/apps/api`, `EXPOSE 3333`, `VOLUME /config`, `USER apps`.
8. Prisma needs its engines inside `node_modules` (already installed in `dist/apps/api`); verify at build time with `node -e "require('@prisma/client')"` in a RUN step.
9. No apt version pinning needed (no distro package defines the version); version is carried by the tag.

## 5. docker-bake.hcl

- `APP = "ghostfolio"`, `LICENSE = "AGPL-3.0-only"` (see section 1 caveat), `SOURCE = "https://github.com/ghostfolio/ghostfolio"`.
- `VERSION` default `"3.100.0"` preceded by `// renovate: datasource=github-releases depName=ghostfolio/ghostfolio versioning=loose`.
- Targets copied from `apps/changedetection/docker-bake.hcl`: `docker-metadata-action`, `image` (args VERSION, source and licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64 and arm64), `group "default" { targets = ["image-local"] }`.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header and `schema_version: 1`, `upstream_env_url: "https://github.com/ghostfolio/ghostfolio"`.
- ports: `3333 tcp required: false`.
- env (names the app reads): `DATABASE_URL` (default `""`, required true: handled by start.sh, which fails with a clear message when empty after waiting is impossible; see risk), `REDIS_HOST` (`""`), `REDIS_PORT` (`"6379"`), `REDIS_PASSWORD` (`""`), `ACCESS_TOKEN_SALT` (`""`, generated into `/config/secrets` when empty), `JWT_SECRET_KEY` (`""`, generated when empty), `TZ` (`"Etc/UTC"`), `PORT` only if confirmed read by main.ts.
- volumes: `/config` required true (holds generated secrets only; app state is in PostgreSQL).
- dependencies: `postgresql` ✅, `valkey` ✅.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`; never write under `/app`.
- Secrets: if `ACCESS_TOKEN_SALT` or `JWT_SECRET_KEY` unset, read them from `/config/secrets/<name>`, generating with `openssl rand -hex 32` only when the file is missing (mode 0600). Export into the environment only; never echo them or pass on the command line.
- Fail fast with a clear log line if `DATABASE_URL` is empty, but keep the container alive in a "waiting for DATABASE_URL" retry loop (so the protocol's log check sees a live process). UNVERIFIED design choice; alternative is exit 1.
- Wait for TCP reachability of the DB host:port parsed from `DATABASE_URL` and of `REDIS_HOST:REDIS_PORT` using `bash` `/dev/tcp` with a retry loop; log "waiting for database".
- Run `npx prisma migrate deploy` and `npx prisma db seed` (as upstream, both idempotent) with `HOME=/tmp`, `npm_config_cache=/tmp/npm`; abort on failure.
- Bind on all interfaces: confirm Nest `listen` host (UNVERIFIED); if it binds only localhost, set `HOST=0.0.0.0` only if main.ts reads it.
- `exec node main` from `/app/ghostfolio/apps/api`.

## 8. container-test.yaml

Hard PostgreSQL dependency and the app cannot start without it; all three criteria of the protocol exception hold. Follow `apps/bookstack/container-test.yaml` style:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
# narrowed: requires external postgresql (and valkey); full functional test not feasible in single-container suite
timeoutSeconds: 240
mainRunner:
  enabled: false
runners:
- entrypoint: test -f /app/ghostfolio/apps/api/main.js
- entrypoint: test -x /start.sh
- entrypoint: node --version
filePaths:
- /start.sh
- /usr/share/licenses/ghostfolio/LICENSE
```

The `tcp 3333` probe from settings.yaml is intentionally omitted under the exception; the manual run in section 11 must show the process alive and "waiting for database" in logs. UNVERIFIED: whether `main.js` is the exact built entrypoint name; confirm after the first build.

## 9. Rootless and read-only-rootfs adaptations

- Draft says the chart runs as UID 0 with writable rootfs; target is `USER apps` (568) and `--read-only`.
- Write paths: npm/Prisma caches and update checks to `/tmp` (`HOME=/tmp`, `npm_config_cache`); secrets to `/config/secrets`. Prisma engine binaries are bundled in `node_modules` and need no writes (UNVERIFIED; check logs for EROFS).
- No extra persistence: draft lists none, all state in PostgreSQL.

## 10. Risks, caveats and open questions

- Node 26 in the ubuntu base versus upstream's Node 22 build and runtime. If Prisma or native modules fail, pin Node 22 in the builder by installing the same Node release the upstream uses, or use a `ghcr.io/trueforge-org/ubuntu`-built Node 22 layer. Decide after first build.
- Heavy Nx build (RAM and disk); CI runner may need more memory (`NODE_OPTIONS=--max-old-space-size=...`, UNVERIFIED need).
- Redis likely required, not optional (see section 1).
- Prisma migrations run at each start; concurrent replicas could race.
- Blockers: none (amd64 and arm64 are both buildable from source).

## 11. Build and test steps

```sh
cd apps/ghostfolio
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker network create gf-net
docker run -d --name gf-pg --network gf-net -e POSTGRES_DB=ghostfolio -e POSTGRES_USER=gf -e POSTGRES_PASSWORD=gfpass ghcr.io/trueforge-org/postgresql:<tag>   # tag: copy from apps/postgresql/docker-bake.hcl
docker run -d --name gf-valkey --network gf-net ghcr.io/trueforge-org/valkey:<tag>
docker run --rm -d --name ghostfolio-probe --network gf-net --read-only --tmpfs /tmp \
  -e DATABASE_URL='postgresql://gf:gfpass@gf-pg:5432/ghostfolio?connect_timeout=300' -e REDIS_HOST=gf-valkey \
  -v ghostfolio-probe-config:/config ghostfolio:3.100.0
docker logs -f ghostfolio-probe
forgetool containers test --image ghostfolio:3.100.0 --config ./apps/ghostfolio/container-test.yaml
docker rm -f ghostfolio-probe gf-pg gf-valkey; docker volume rm ghostfolio-probe-config; docker network rm gf-net
```

Expected readiness signal: Prisma "All migrations have been successfully applied" followed by Nest "Listening at http://..:3333". Also run once with no DB to confirm the container stays alive logging "waiting for database".

## 12. PR checklist

- Branch `feat/add-ghostfolio`; commit and PR title `feat(ghostfolio): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; check `license/cla`).
- Check: bake print OK, version alignment, `USER apps`, empty `/config` start, read-only rootfs.
- Untested at plan time: everything (no build or run was done), arm64, Node 26 compatibility, Redis optionality, exact license identifier.
