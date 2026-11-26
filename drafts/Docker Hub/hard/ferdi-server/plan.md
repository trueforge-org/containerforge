# ferdi-server — implementation plan
> Source: ./draft.md · Target: apps/ferdi-server/ · Difficulty: hard · Role: main · Verified on 2026-11-24

Corrections to the draft: the Hub image `getferdi/ferdi-server:1.3.2` is the dead Ferdi server. The maintained successor is `ferdium/ferdium-server` and this plan builds that, from the source tag. Upstream defaults to SQLite, so PostgreSQL is optional, not a hard dependency. Consider naming the app `ferdium-server` (matching upstream); this plan keeps `ferdi-server` to match the draft folder, and the choice should be confirmed before the PR.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `2.0.14` (git tag `v2.0.14`; Hub tag `2.0.14` pushed 2026-10-23). The draft tag `1.3.2` is the obsolete getferdi image. The repo has NO GitHub releases (release API returns an empty list), only tags |
| Renovate | `datasource=github-tags depName=ferdium/ferdium-server versioning=semver extractVersion=^v(?<version>.+)$` |
| License | MIT |
| Source URL | https://github.com/ferdium/ferdium-server |
| Download (arch independent) | `https://github.com/ferdium/ferdium-server/archive/refs/tags/v2.0.14.tar.gz`; sha256 computed locally `1a02739fc05297d224ae55a33a7645f0b4bffb5f28594ae25d1e1d715663517d`. Upstream publishes no checksum; Hub image is amd64+arm64 |
| Upstream Dockerfile reviewed | `Dockerfile` (main): two stages `node:24.22.1-alpine`. Builder: apk `python3 make gcc g++ libc-dev sqlite-dev`, `CI=true`, copies `package*.json .npmrc pnpm-workspace.yaml patches`, installs pnpm at the `engines.pnpm` version, `pnpm install`, copies source, `pnpm build`. Runtime: `HOST=0.0.0.0 PORT=3333 DATA_DIR="/data"`, copies `/server-build` to `/app`, installs `@adonisjs/cli` globally, `docker/entrypoint.sh`, `docker/.env` to `/app/.env`; HEALTHCHECK `curl http://localhost:${PORT}/health`; no EXPOSE or VOLUME |
| Runtime requirements | `package.json` engines: node `24.22.1`, pnpm `12.15.0`; build script `node ace build --production`; start `node build/server.js`. `.nvmrc` is 24.22.1 |
| Entrypoint behaviour | `docker/entrypoint.sh`: clones `ferdium-recipes` (branch main) into `recipes` on first run, otherwise `git pull`s, then `pnpm i` and `pnpm package` there; generates `APP_KEY` with `adonis key:generate --force` and stores it in `${DATA_DIR}/FERDIUM_APP_KEY.txt`; when `JWT_USE_PEM=true` generates keys in `${DATA_DIR}/FERDIUM_JWT_{PUBLIC,PRIVATE}_KEY.pem` via `node ace jwt:generate-keys`; runs `sh /app/scripts/adonisjs-4-to-5.sh`, `node ace migration:run --force`, then `node build/server.js` |
| Env vars (from `.env.example`, README and `config/*.ts`) | `NODE_ENV`, `APP_URL`, `APP_KEY`, `DATA_DIR`, `HOST`, `PORT`, `DB_CONNECTION` (default `sqlite`), `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_DATABASE` (default `ferdium`), `DB_SSL`, `MAIL_CONNECTION`, `SMTP_HOST`, `SMTP_PORT`, `MAIL_SSL`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_SENDER`, `IS_CREATION_ENABLED`, `IS_DASHBOARD_ENABLED`, `IS_REGISTRATION_ENABLED`, `CONNECT_WITH_FRANZ`, `JWT_USE_PEM`, `LOG_LEVEL`, `DB_SQLITE_JOURNAL_MODE`, `DB_SQLITE_SYNCHRONOUS`, `DB_BUSY_TIMEOUT`. SQLite file is `${DATA_DIR}/${DB_DATABASE}.sqlite` |
| Postgres driver value | `DB_CONNECTION` for PostgreSQL: UNVERIFIED (README has a "supported databases and drivers" table; read it before writing settings.yaml; `pg` 8.12.0 is a dependency) |
| Ports | 3333/tcp (draft matches) |
| Recipes path | README `docker create` mounts `/app/recipes`, while `entrypoint.sh` clones into `/app/recipes`. UNVERIFIED which one the server reads; check `config/app.ts` or `app/` for the `recipes` path at build time |

## 2. Target layout

- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`
- No `defaults/` needed (recipes are baked and seeded from `/app/recipes-seed`). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (as the draft proposes). Reason: it carries Node and a Python toolchain for node-gyp (sqlite3 native build). Because engines pin `node: 24.22.1` exactly, confirm `node -v` in the base equals `v24.22.1` (UNVERIFIED); if not, either relax with `--engine-strict=false` after checking compatibility, or install the exact Node from nodejs.org with its SHASUMS check as `apps/ubuntu/Dockerfile` does. Closest siblings: `apps/hedgedoc`, `apps/planka`, `apps/thelounge` (Node apps on python-node).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`; `ENV HOME=/config NODE_ENV=production`-free during build (devDependencies are required to build; set `NODE_ENV=production` only at runtime via `start.sh`).
2. apt (check each against the base before adding): `build-essential python3 python-is-python3 libsqlite3-dev git` for the build; keep `git` only if recipes are updated at runtime (see start.sh).
3. `npm install -g pnpm@12.15.0` (read the exact value from the tag's `package.json` `engines.pnpm`; bump it with VERSION). Caches: `ENV npm_config_cache=/tmp/npm PNPM_HOME=/tmp/pnpm npm_config_store_dir=/tmp/pnpm-store`.
4. Download tarball with `sha256sum -c` against `1a02739f...` (an `ARG SOURCE_SHA256`), extract to `/app/ferdi-server` (`--strip-components=1`).
5. `cd /app/ferdi-server && CI=true pnpm install --frozen-lockfile && pnpm build` (`node ace build --production` makes `build/`). The upstream build sets the sqlite build-from-source config; if install fails on arm64, copy that `pnpm config` step from the upstream Dockerfile (UNVERIFIED exact flags; open the upstream file during implementation). `pnpm prune --prod` afterward; confirm `node ace` and `@adonisjs/cli` still resolve (upstream installs `@adonisjs/cli` globally; do the same with `npm i -g @adonisjs/cli` into `/usr/local`).
6. Recipes: `git clone --depth 1 --branch main https://github.com/ferdium/ferdium-recipes /app/recipes-seed`, then `cd` into it and `pnpm i && pnpm package` as the entrypoint does (recipes need their own pnpm version from their `package.json` `engines.pnpm`). The recipes repo has no tags: record the commit in a label (`org.opencontainers.image.ferdium-recipes`) and accept drift per rebuild. Remove `.git` after reading the commit if size matters, but then runtime `git pull` is impossible, so no auto-update.
7. Link the server's recipes directory to persistent storage: `ln -s /config/recipes /app/ferdi-server/recipes` (and `/app/ferdi-server/build/recipes` if that is the path the server reads; decide with the check in section 1).
8. Licenses: copy `LICENSE` to `/usr/share/licenses/ferdi-server/` (MIT, ships in the tarball), plus the recipes repo license (MIT per GitHub).
9. Cleanup: purge build packages, `rm -rf /tmp/* /var/lib/apt/lists/*`; `chown -R apps:apps /app && chmod -R 755 /app`.
10. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 3333`; `VOLUME /config`; `WORKDIR /app/ferdi-server`.

## 5. docker-bake.hcl

`APP="ferdi-server"`; `VERSION` default `2.0.14` preceded by `// renovate: datasource=github-tags depName=ferdium/ferdium-server versioning=semver extractVersion=^v(?<version>.+)$`; `LICENSE="MIT"`; `SOURCE="https://github.com/ferdium/ferdium-server"`. Standard targets: `docker-metadata-action {}`; `image` (args `VERSION`, `SOURCE_SHA256`; OCI `source` and `licenses` labels); `image-local` (`type=docker`, tag `${APP}:${VERSION}`); `image-all` (amd64 and arm64); `group "default" { targets = ["image-local"] }`. Validate with `docker buildx bake --print`. The Dockerfile `ARG VERSION` must be consumed with the `v` prefix added in the URL only.

## 6. settings.yaml

Header, `schema_version: 1`, `upstream_env_url: "https://github.com/ferdium/ferdium-server"`.
- ports: `3333/tcp required: false`.
- env (only variables the app reads, defaults matching `start.sh`): `TZ` `Etc/UTC`; `NODE_ENV` `production`; `APP_URL` `""` (required false; set to the public URL); `APP_KEY` `""` (required false; generated into `/config/data/FERDIUM_APP_KEY.txt` when empty); `DATA_DIR` `/config/data`; `HOST` `0.0.0.0`; `PORT` `3333`; `DB_CONNECTION` `sqlite`; `DB_HOST` `""`; `DB_PORT` `5432`; `DB_USER` `""`; `DB_PASSWORD` `""`; `DB_DATABASE` `ferdium`; `DB_SSL` `false`; `IS_CREATION_ENABLED` `true`; `IS_DASHBOARD_ENABLED` `true`; `IS_REGISTRATION_ENABLED` `true`; `CONNECT_WITH_FRANZ` `false`; `JWT_USE_PEM` `true`. Add the `MAIL_*` and `SMTP_*` set (`MAIL_CONNECTION` `smtp`, `SMTP_HOST`, `SMTP_PORT`, `MAIL_SSL`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_SENDER`) as optional with empty defaults.
- volumes: `/config` required true.
- `opt_dependencies`: `postgresql` (✅ exists), used when `DB_CONNECTION` is the Postgres driver. No hard `dependencies`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
export NODE_ENV="${NODE_ENV:-production}" HOST="${HOST:-0.0.0.0}" PORT="${PORT:-3333}"
export DATA_DIR="${DATA_DIR:-/config/data}"
mkdir -p "$DATA_DIR" /config/recipes
# Seed recipes only when empty (do not overwrite user/custom recipes)
[ -n "$(ls -A /config/recipes 2>/dev/null)" ] || cp -a /app/recipes-seed/. /config/recipes/
key_file="$DATA_DIR/FERDIUM_APP_KEY.txt"
if [ -z "${APP_KEY:-}" ]; then
  [ -s "$key_file" ] || node ace generate:key --show 2>/dev/null > "$key_file"   # command UNVERIFIED; upstream uses `adonis key:generate --force` and reads .env
  APP_KEY="$(cat "$key_file")"
fi
export APP_KEY
# JWT keys when JWT_USE_PEM=true: reuse upstream logic (node ace jwt:generate-keys "$DATA_DIR", then mv to FERDIUM_JWT_*.pem, export JWT_PUBLIC_KEY and JWT_PRIVATE_KEY)
cd /app/ferdi-server
node ace migration:run --force
exec node build/server.js
```
Notes: idempotent; `APP_KEY` is never printed (upstream prints it; ours must not, secrets stay out of logs); DB password comes from env at every start (nothing written to files). Upstream writes `/app/.env` via `adonis key:generate`; since `/app` is read-only, the key command must not write a file: verify what `generate:key` or `adonis key:generate` does, or generate with `openssl rand -base64 32` (check AdonisJS key format requirement, UNVERIFIED). The upstream migration script `scripts/adonisjs-4-to-5.sh` is only for v4 users and is skipped here (fresh installs); if migrating a getferdi/Ferdium v4 DB is needed, port it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3333'
http:
- port: '3333'
  path: /health
filePaths:
- /app/ferdi-server/build/server.js
```
Upstream HEALTHCHECK uses `/health`. The test runs with no env vars: default SQLite starts without any DB, so no DB narrowing is needed and the DB-exception criteria do not hold. The Postgres path is checked by hand (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `DATA_DIR=/data` (sqlite db, app key, JWT PEMs) | `/config/data` |
| `/app/recipes` (clone, pnpm install, package) | baked at build in `/app/recipes-seed`, runtime copy in `/config/recipes` via symlink |
| `/app/.env` written by key generation | no file; `APP_KEY` via env/`/config/data` |
| `git pull` in recipes, `npm i -g pnpm`, `chown -R root` at runtime | removed (needs root and writes outside `/config`) |
| pnpm, npm caches | `/tmp` |

Draft expectations: TrueCharts runs as root with `/app/data` and `/app/recipes` persistence; ours is UID 568 and a single `/config` volume. Users migrating must move data to `/config/data` and recipes to `/config/recipes`. Not privileged.

## 10. Risks, caveats and open questions

- Name: upstream is Ferdium; decide `ferdi-server` versus `ferdium-server`.
- Node version coupling: exact `engines.node` 24.22.1 and pnpm 12.15.0 change on every upstream bump; Renovate bumps VERSION only, so the Dockerfile must read versions from the tag's `package.json` (not hardcode them).
- Recipes are fetched from `ferdium/ferdium-recipes` main at build time, so the image is not reproducible and recipe updates need a rebuild.
- Exact recipes directory the server reads (`/app/recipes` vs `/app/build/recipes`): UNVERIFIED.
- Postgres driver name and `DB_SSL` semantics: UNVERIFIED until the README table is read.
- Draft caveat "PostgreSQL hard dependency" is wrong: default is SQLite.
- Alpine to glibc: upstream builds on musl; sqlite3 native module must rebuild for glibc (the plan does, via build tools).
- `getferdi/ferdi-server:1.3.2` data is not guaranteed to be compatible with 2.x (AdonisJS v4 to v5 migration script exists upstream).

## 11. Build and test steps

```sh
cd apps/ferdi-server && docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ferdi-server-probe --read-only --tmpfs /tmp -v ferdi-server-probe-config:/config ferdi-server:2.0.14
docker logs -f ferdi-server-probe
forgetool containers test --image ferdi-server:2.0.14 --config ./apps/ferdi-server/container-test.yaml
docker rm -f ferdi-server-probe; docker volume rm ferdi-server-probe-config
```
Readiness signal: UNVERIFIED exact line; expect AdonisJS "started server on 0.0.0.0:3333" (or similar) after migrations, and `curl -fsS http://localhost:3333/health` succeeding. Also run once more with the same volume to confirm the key and DB persist, once with `APP_KEY` set, and once against `apps/postgresql` with the Postgres driver variables.

## 12. PR checklist

- Branch `feat/add-ferdi-server`; commit and PR title `feat(ferdi-server): add new container`.
- PR template filled in; Notes include `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Check: version alignment, renovate comment, `USER apps`, `COPY --chmod=0755 . /`, empty `/config` start, read-only rootfs.
- Untested until built: the pnpm build, exact Node match, recipes path, key generation without a writable `/app`, Postgres mode, arm64, migration from getferdi data.
