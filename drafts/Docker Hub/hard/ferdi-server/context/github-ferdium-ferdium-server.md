# ferdium/ferdium-server

Source URL(s) + fetch date:
- https://github.com/ferdium/ferdium-server (repo, via tags page)
- https://github.com/ferdium/ferdium-server/tags (fetched 2026-11-26)
- https://github.com/ferdium/ferdium-server/releases (plan link; the tags page shows no published GitHub releases, see below)
- https://raw.githubusercontent.com/ferdium/ferdium-server/v2.0.14/Dockerfile
- https://raw.githubusercontent.com/ferdium/ferdium-server/v2.0.14/README.md
- https://raw.githubusercontent.com/ferdium/ferdium-server/v2.0.14/docker/entrypoint.sh
- https://raw.githubusercontent.com/ferdium/ferdium-server/v2.0.14/.env.example
- https://raw.githubusercontent.com/ferdium/ferdium-server/v2.0.14/LICENSE

## What it is

Ferdium server: the self-hosted AdonisJS (v5) backend for the Ferdium desktop app (sync, accounts, custom recipes). Successor to the dead `getferdi/server`.

## Install/build steps and build deps (upstream Dockerfile, v2.0.14)

Two stages, both `node:24.22.1-alpine`.

Builder stage:
- `WORKDIR /server-build`
- `apk add --no-cache python3 make gcc g++ libc-dev sqlite-dev`
- `ENV CI=true`
- `COPY package*.json ./`, `COPY .npmrc ./`, `COPY pnpm-workspace.yaml ./`, `COPY patches ./patches`
- `RUN npm i -gf "pnpm@$(node -p 'require("./package.json").engines.pnpm')" && pnpm -v`
- `RUN pnpm install --config.build-from-source=sqlite --config.sqlite=/usr/local`
- `COPY . .` then `RUN pnpm build`

Runtime stage:
- `WORKDIR /app`, `LABEL maintainer="ferdium"`
- `ENV HOST=0.0.0.0 PORT=3333 DATA_DIR="/data"`
- `apk add --no-cache sqlite-libs curl su-exec python3 make g++ py3-pip git py3-pip sqlite` (Dockerfile comments say this list is unreviewed, "are all these packages needed")
- `COPY --from=builder /server-build /app`
- `RUN npm i -g @adonisjs/cli`
- `HEALTHCHECK --start-period=5s --interval=30s --retries=5 --timeout=3s CMD curl -sSf http://localhost:${PORT}/health`
- `COPY docker/entrypoint.sh /entrypoint.sh`, `COPY docker/.env /app/.env`
- `ENTRYPOINT ["/entrypoint.sh"]`

Not present in the Dockerfile: `ARG`, `USER`, `EXPOSE`, `VOLUME`, `CMD`. The container runs as root.

Manual setup (README): clone with submodule, install AdonisJS CLI, copy `.env.example` to `.env`, `npm install`, `node ace migration:run`, `npm start`.

## Runtime deps

- Node 24.22.1 (from Dockerfile base; `engines.node` per plan).
- pnpm version read at build time from `package.json` `engines.pnpm` (Dockerfile and entrypoint both read it).
- Runtime packages: `curl`, `git` (entrypoint clones/pulls recipes), `sqlite-libs`, `su-exec`, python3/make/g++ (kept in runtime image).

## Binaries/entrypoint/CLI flags

- Entrypoint: `/entrypoint.sh`. Sequence (`docker/entrypoint.sh`):
  1. Prints ASCII banner.
  2. Saves `NODE_ENV`, sets `NODE_ENV=development` (so devDependencies install).
  3. If `/app/recipes/.git` missing: `git clone --depth 1 --branch main https://github.com/ferdium/ferdium-recipes recipes` (run in `/app`). Otherwise: `chown -R root /app/recipes`, `git stash -u`, `git pull -r`, `git stash pop`.
  4. `cd recipes`; `git config --global --add safe.directory /app/recipes`; `npm i -gf pnpm@$EXPECTED_PNPM_VERSION` (read from recipes `package.json` `engines.pnpm`); `pnpm i`; `pnpm package`; `cd ..`.
  5. Restores `NODE_ENV`.
  6. App key: `key_file=${DATA_DIR}/FERDIUM_APP_KEY.txt`. If `APP_KEY` empty and key file absent: `adonis key:generate --force`, reads `APP_KEY` from `.env` via grep, writes to key file. Otherwise reads key file. Prints the key to the log (`print_app_key_message`).
  7. JWT: if `JWT_USE_PEM=true`, and `${DATA_DIR}/FERDIUM_JWT_PUBLIC_KEY.pem` / `FERDIUM_JWT_PRIVATE_KEY.pem` missing: `node ace jwt:generate-keys $DATA_DIR`, then `mv ${DATA_DIR}/public.pem` and `private.pem` to the FERDIUM_JWT_* names. Exports `JWT_PUBLIC_KEY`, `JWT_PRIVATE_KEY` from the files.
  8. `export APP_KEY`; `set -e`; `sh /app/scripts/adonisjs-4-to-5.sh` (v4 migration); `set +e`.
  9. `node ace migration:run --force`.
  10. `node build/server.js` (exec-less: the entrypoint does not `exec`).
- Build-time run command per plan: `node build/server.js`; build: `node ace build --production` (from `package.json`, per plan).

## Env vars (table)

From `.env.example`, README `docker create` example and `entrypoint.sh`. Defaults are the example-file values unless noted.

| Name | Example/default | Notes |
| --- | --- | --- |
| `NODE_ENV` | `development` (example) | Entrypoint forces development during recipe install then restores. README `docker create` uses `development`. |
| `APP_URL` | `localhost` (example) | README docker example: `<ferdium-server-url>`. |
| `APP_KEY` | empty | Required by AdonisJS; generated if empty and no key file. |
| `DATA_DIR` | `data` (example), `/data` in Dockerfile | Key file, JWT PEMs, sqlite db location. |
| `HOST` | `127.0.0.1` (example), `0.0.0.0` in Dockerfile | |
| `PORT` | `3333` | Dockerfile default. |
| `DB_CONNECTION` | `sqlite` | Default sqlite. Alternatives per third-party Hub page: `mysql`, `pg`. |
| `DB_HOST` | `127.0.0.1` (example) | |
| `DB_PORT` | `3306` (example) | example file is MySQL-ish; Postgres uses 5432. |
| `DB_USER` | `root` (example) | |
| `DB_PASSWORD` | `password` (example) | |
| `DB_DATABASE` | `ferdium` | sqlite file name base. |
| `DB_SSL` | `false` | README: `true` only for hosted Postgres (GCP/AWS). |
| `DB_SQLITE_JOURNAL_MODE` | `WAL` | Options DELETE, TRUNCATE, PERSIST, MEMORY, WAL, OFF. |
| `DB_SQLITE_SYNCHRONOUS` | `FULL` | Options OFF, NORMAL, FULL, EXTRA. |
| `DB_BUSY_TIMEOUT` | `5000` | ms. |
| `MAIL_CONNECTION` | `smtp` | |
| `SMTP_HOST` | `127.0.0.1` (example) | |
| `SMTP_PORT` | `2525` (example) | |
| `MAIL_SSL` | `false` | |
| `MAIL_USERNAME` | `username` (example) | |
| `MAIL_PASSWORD` | `password` (example) | |
| `MAIL_SENDER` | `noreply@ferdium.org` (example) | |
| `IS_CREATION_ENABLED` | `true` | Custom recipe creation. |
| `IS_DASHBOARD_ENABLED` | `true` | |
| `IS_REGISTRATION_ENABLED` | `true` | |
| `CONNECT_WITH_FRANZ` | `false` (example), `true` in README docker example | Franz recipe library and account import. |
| `JWT_USE_PEM` | not in example; entrypoint checks `= "true"` | |
| `CACHE_VIEWS` | `false` (example) | "overridden" per example comment. |
| `LOG_LEVEL` | not in fetched sources | plan lists it; not verified here. |

## Ports

- 3333/tcp (`PORT`, `EXPOSE` absent). README `docker run`: `-p <port>:3333`.
- Health: `GET /health` on `${PORT}` (Dockerfile HEALTHCHECK).

## Volumes/paths and persistent data

- README docker examples: `-v <path to data>:/data` and `-v <path to recipes>:/app/recipes`.
- Data dir `DATA_DIR` (Dockerfile default `/data`). Key file `${DATA_DIR}/FERDIUM_APP_KEY.txt`; JWT PEMs `${DATA_DIR}/FERDIUM_JWT_{PUBLIC,PRIVATE}_KEY.pem`; sqlite db `${DATA_DIR}/${DB_DATABASE}.sqlite` (per plan, not re-verified here).
- Recipes: entrypoint clones to `/app/recipes` (relative `recipes` from `/app`). README mounts `/app/recipes`. The plan's README claim `/app/build/recipes` is not in the fetched README (see corrections).
- `/app/.env` is copied in at build time from `docker/.env` (Dockerfile).

## User/UID & permissions

- No `USER` in Dockerfile: runs as root. Entrypoint does `chown -R root /app/recipes` on update. `git config --global safe.directory`.

## Config files and formats

- `.env` (dotenv). `docker/.env` baked into `/app/.env` at build time.
- Deprecated per README: `config.txt` (Hub page also calls `/config/config.txt` deprecated).

## Healthcheck/readiness endpoints

- `GET http://localhost:${PORT}/health` (Dockerfile HEALTHCHECK, `curl -sSf`, start-period 5s, interval 30s, retries 5, timeout 3s).

## Version/release info and asset naming

- Tags (newest first, from tags page): v2.0.14 Oct 23 2026; v2.0.13 Mar 28 2026; v2.0.12 Mar 28 2026; v2.0.11 Jun 24 2025; v2.0.10 Dec 15 2024; v2.0.9 Dec 15 2024; v2.0.8 Oct 18 2024; v2.0.7 Oct 18 2024; v2.0.6 Jan 15 2024; v2.0.5 Jan 8 2024.
- Tags page shows commit messages "2.0.x [skip ci]" and zip/tar.gz archive links. No published GitHub release entries were shown on the tags page, so the releases list is effectively empty (consistent with plan).
- Source archive: `https://github.com/ferdium/ferdium-server/archive/refs/tags/v2.0.14.tar.gz` (plan). Not downloaded here (binary archive, skip rule).
- Docker Hub image listed as `ferdium/ferdium-server:latest` in the README docker pull example.

## Arch support

- Not stated in the fetched upstream sources. Base image `node:24.22.1-alpine` is multi-arch; plan says Hub image amd64+arm64 (unverified here).

## License

- MIT License, "Copyright (c) 2022 Ferdium Contributors" (LICENSE at v2.0.14). Note: the fetch tool for entrypoint.sh added an unsupported "AGPL-3.0" remark; the LICENSE file itself says MIT.

## Gotchas

- Upstream Dockerfile runtime runs as root and `entrypoint.sh` writes into `/app` (recipes, `.env`), which conflicts with a read-only rootfs.
- Entrypoint prints the app key to stdout.
- Entrypoint runs `pnpm i` and `pnpm package` on recipes every start, and needs network to GitHub on first run.
- `adonis key:generate --force` writes into `/app/.env`; the key is read back from that file.
- Dockerfile says `docker/.env` is copied to `/app/.env`.
- The entrypoint script is not `exec`ed, so `node build/server.js` is a child of the shell.
- Postgres driver: upstream README and `.env.example` do not give the exact value. The TrueCharts chart uses `DB_CONNECTION: pg` (see truecharts file), but that chart pins the old 1.3.2 image.

## Contradictions with plan.md

- plan.md section 1: "README `docker create` and compose mount `/app/build/recipes`". Fetched README mounts `/app/recipes` (and the entrypoint clones to `/app/recipes`).
- plan.md section 1: "Postgres driver value UNVERIFIED". The TrueCharts chart uses `pg` (not an upstream source for 2.x).
