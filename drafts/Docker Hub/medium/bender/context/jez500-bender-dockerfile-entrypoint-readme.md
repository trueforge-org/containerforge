# jez500/bender: Dockerfile, entrypoint.sh, README

## Source URL(s) + date
- https://raw.githubusercontent.com/jez500/bender/fd780e5/Dockerfile (fetched 2026-11-26; commit fd780e5 from urls.txt)
- https://raw.githubusercontent.com/jez500/bender/fd780e5/entrypoint.sh (fetched 2026-11-26, follow-up)
- https://raw.githubusercontent.com/jez500/bender/master/README.md (fetched 2026-11-26)

## What it is
- Link dashboard (Nuxt 2 / Vue 2) with UI-managed config. No database. Config in one file `static/config.json`.
- Inspired by Homer. Light and dark mode. FontAwesome icons. Image lookup from `static/images`.

## Install/build steps (Dockerfile)
- Build stage: `FROM node:lts-alpine AS build-stage`, `WORKDIR /app`
  - `COPY package*.json ./`; `RUN npm install --frozen-lockfile` (note: `--frozen-lockfile` is a yarn flag, npm does not document it)
  - `COPY . .`; `RUN npm run build`
- Production stage: `FROM node:lts-alpine`
  - `ENV GID 1000`, `ENV UID 1000`, `ENV PORT 8080`, `ENV INIT_ASSETS 1`
  - `WORKDIR /app`
  - `COPY --from=build-stage --chown=${UID}:${GID} /app /app`
  - `COPY --from=build-stage --chown=${UID}:${GID} /app/static /app/static-default`
  - `HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:${PORT}/ || exit 1`
  - `EXPOSE ${PORT}`, `VOLUME /app/static/`
  - `ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]`

## Entrypoint (entrypoint.sh)
- `PERMISSION_ERROR` message text for non-writable assets dir.
- If `INIT_ASSETS == 1` and `/app/static/config.json` missing:
  - requires `/app/static/` writable (else exit 1)
  - copies `/app/static-default/*` into `/app/static/` (`cp -Ri`, answers `n` to overwrite prompts)
  - copies `/app/static-default/config.json.default` to `/app/static/config.json` (`cp -i`)
- Then `echo "Starting webserver"` and `npm run start`.

## Runtime deps
- Node LTS (alpine). Built app in `/app`. No database.

## Env vars
| Var | Default | Use |
| --- | --- | --- |
| PORT | 8080 | Dockerfile env; app port is hard-coded in nuxt.config.js per plan |
| UID | 1000 | file ownership for COPY |
| GID | 1000 | file ownership for COPY |
| INIT_ASSETS | 1 | `1` = seed static defaults when config.json missing |

## Ports
- `EXPOSE ${PORT}` = 8080.

## Volumes/paths
- `VOLUME /app/static/` (config.json, images/). Defaults shipped in `/app/static-default`.

## User/UID
- Not set in Dockerfile (root). UID/GID env values are used only for COPY --chown.

## Healthcheck
- `wget --spider http://127.0.0.1:${PORT}/` every 30s, timeout 5s, 3 retries.

## Version/asset naming
- Git tag `1.0.3` (no GitHub release; see plan).

## Run (README)
- `docker run -d --name bender -p 8080:8080 -v </your/local/assets/>:/app/static --restart=always jez500/bender:latest`
- docker-compose example `docker-compose.yml` in repo root.
- Running without docker: NodeJS 14+, `npm run start`, http://localhost:8080.
- Import from Homer: `/import` route.

## Gotchas
- Releases API for tag 1.0.3 returned 404; `releases/latest` also 404 (repo has tags only).
- Dockerfile's `npm install --frozen-lockfile` does not match npm semantics (plan uses `npm ci`).
- Upstream unmaintained since 2022-09.
