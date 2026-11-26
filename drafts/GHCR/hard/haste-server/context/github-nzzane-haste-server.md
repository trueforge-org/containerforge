# nzzane/haste-server (the fork the draft uses; pinned commit 8c45a370a79cc5caaf446ba0088574dfcb489694)

**Source URL(s):** https://github.com/nzzane/haste-server (repo page); https://raw.githubusercontent.com/nzzane/haste-server/8c45a370a79cc5caaf446ba0088574dfcb489694/Dockerfile; .../docker-entrypoint.sh; .../docker-entrypoint.js; .../config.js; .../server.js (all at the pinned commit)
**Fetched:** 2026-11-26

## What it is
"Open source pastebin written in node.js". Fork of shykes/haste-server, itself a fork of seejohnrun's. Storage: file (default), Redis, Postgres, MongoDB, Memcached, RethinkDB, Google Datastore, Amazon S3.
- Default branch `master` (388 commits). Last commit date not shown on the page (plan.md: 2021-03-01).
- **License: MIT** (repo page, "The MIT License", copyright 2011-2012 John Crepezzi). Plan.md said "no license"; the package.json at the commit has no license field, but the repo itself is MIT.

## Install/build steps
- Repo README: download, review `config.js`, `npm install`, `npm start` (optional config path argument).
- Docker build: `docker build --tag haste-server .` (repo README).
- The app runs as plain Node: `node server.js [config-path]`. Default config path is `config.js` in the cwd.

## Runtime deps
- Node.js. Fork Dockerfile uses `node:14.8.0-stretch` (EOL). Plan uses python-node.
- npm deps (package.json): `redis 0.8.1`, `connect ^3.7.0`, `winston ^2.0.0`, `uglify-js 3.1.6`, plus connect-ratelimit and others. Extra storage drivers are only needed if that storage type is selected.

## Fork Dockerfile (summary)
- `FROM node:14.8.0-stretch`; creates `/usr/src/app` owned by `node:node`; `USER node:node`; `WORKDIR /usr/src/app`; COPY all files owned by node.
- RUN `npm install` plus pinned extras: `redis@0.8.1`, `pg@4.1.1`, `memcached@2.2.2`, `aws-sdk@2.738.0`, `rethinkdbdash@2.3.31`.
- ENV: `STORAGE_TYPE=file`, `STORAGE_HOST=127.0.0.1`, `STORAGE_PORT=11211`, `STORAGE_EXPIRE_SECONDS=2592000`, `STORAGE_DB=2`, `STORAGE_FILEPATH=/app/data`, `STORAGE_AWS_BUCKET=""`, `STORAGE_AWS_REGION=""`, `STORAGE_USENAMER=""` (typo in the fork), `STORAGE_PASSWORD=""`, `LOGGING_LEVEL=verbose`, `LOGGING_TYPE=Console`, `LOGGING_COLORIZE=true`, `HOST=0.0.0.0`, `PORT=7777`, `KEY_LENGTH=10`, `MAX_LENGTH=400000`, `STATIC_MAX_AGE=86400`, `RECOMPRESS_STATIC_ASSETS=true`, `KEYGENERATOR_TYPE=phonetic`, `KEYGENERATOR_KEYSPACE=""`, `RATELIMITS_NORMAL_TOTAL_REQUESTS=500`, `RATELIMITS_NORMAL_EVERY_MILLISECONDS=60000`, whitelist/blacklist list vars with placeholder values, `DOCUMENTS=about=./about.md`.
- `VOLUME /app/data`; `EXPOSE $PORT`; `STOPSIGNAL SIGINT`; `ENTRYPOINT ["bash","docker-entrypoint.sh"]`; `CMD ["npm","start"]`.
- HEALTHCHECK: every 30s, timeout 30s, start period 5s, 3 retries, runs curl against localhost (command is malformed: missing comma, variable does not expand in exec form).

## docker-entrypoint.sh
- `set -e`. Runs `node ./docker-entrypoint.js > ./config.js` (overwrites config.js in the cwd). Then `exec "$@"`.
- No directories created, no files copied, no chown.

## docker-entrypoint.js (env -> config.js)
Writes a single line of compact JSON to stdout. Undefined env keys are omitted by JSON.stringify.
- `HOST` -> `host`; `PORT` -> `port`; `KEY_LENGTH` -> `keyLength`; `MAX_LENGTH` -> `maxLength`; `STATIC_MAX_AGE` -> `staticMaxAge`; `RECOMPRESS_STATIC_ASSETS` -> `recompressStaticAssets`.
- Logging: `LOGGING_LEVEL` -> `level`, `LOGGING_TYPE` -> `type`, `LOGGING_COLORIZE` -> `colorize` (one-element array).
- Key generator: `KEYGENERATOR_TYPE` -> `type`; `KEY_GENERATOR_KEYSPACE` -> `keyspace` (inconsistent name, verify in the run).
- Rate limits: `RATE_LIMITS_WHITELIST`/`RATE_LIMITS_BLACKLIST` (comma lists, else `[]`); `categories.normal` from `RATE_LIMITS_NORMAL_TOTAL_REQUESTS` and `RATE_LIMITS_NORMAL_EVERY_MILLISECONDS`; whitelist/blacklist categories are objects only when their variables are set, else `null`. **Quirk:** the blacklist `totalRequests` reads `RATE_LIMITS_WHITELIST_TOTAL_REQUESTS` (copy-paste bug).
- Storage: `STORAGE_TYPE` -> `type`, `STORAGE_HOST` -> `host`, `STORAGE_PORT` -> `port`, `STORAGE_EXPIRE_SECONDS` -> `expire`, `STORAGE_AWS_BUCKET` -> `bucket`, `STORAGE_AWS_REGION` -> `region`, `STORAGE_DB` -> `db`, `STORAGE_USERNAME` -> `user`, `STORAGE_PASSWORD` -> `password`, `STORAGE_FILEPATH` -> `path`. Also always builds `connectionUrl` as `postgres://USER:PASS@HOST:PORT/DB` (unset parts become the literal text "undefined"; harmless for file storage).
- Documents: `DOCUMENTS` split on commas, whitespace removed, `key=value` pairs; unset gives `null`.

## config.js (in the repo)
- Sample JSON: host `0.0.0.0`, port 7777, keyLength 10, maxLength 400000, staticMaxAge 86400, recompressStaticAssets true, logging level verbose type Console colorize true, keyGenerator phonetic, rateLimits normal 500/60000, storage type `file`, documents `about: ./about.md`.
- Keys and values are the same as the env defaults; the file itself is parsed with `JSON.parse` even though it is named `.js`.

## server.js (loading and serving)
- Config path: `process.argv[2]` if given, else `config.js` in the cwd. **The file is read as UTF-8 and parsed with `JSON.parse`** (must be valid JSON).
- Env overrides only `PORT` and `HOST` (env, then config, then default: port 7777, host `localhost`).
- `http.createServer(app)`, logs host and port at startup.
- `recompressStaticAssets`: minifies every `./static/*.js` not already `.min.js` with uglify-js at startup (writes files alongside; needs writable `static/` or it will fail; the plan's read-only rootfs must handle this, e.g. set `recompressStaticAssets=false` or accept the write to `/tmp` copies).
- `documents` entries: read each file as UTF-8 and store with `set(..., true)` (no expiry). Empty content logs a warning.
- Routes, in order: optional rate limiting; API `GET/HEAD /raw/:id`, `POST /documents`, `GET/HEAD /documents/:id`; static from `__dirname + '/static'` (maxAge `staticMaxAge`); `GET /:id` rewritten to `/`; final static handler serves `index.html`.
- Storage module: `config.storage.type` (default `file`), loaded from `./lib/document_stores/<type>`. Redis special case: `REDISTOGO_URL` env.
- Key generator default `random` (from `./lib/key_generators/`), but config sets `phonetic`.

## Ports
7777/tcp (`PORT`).

## Volumes/paths
- Fork: `/app/data` (VOLUME and `STORAGE_FILEPATH`). The fork Dockerfile sets `WORKDIR /usr/src/app`; the paths `/app/data` do not match that WORKDIR (inconsistency in the fork).
- `config.js` is generated into the cwd (`/usr/src/app`), which the plan's read-only layout cannot allow. Write it to `/config` or `/tmp` and pass the path as `argv[2]` to `node server.js`.
- `static/` is inside the app tree, read-only at runtime (unless recompressStaticAssets writes into it).

## User
Fork: `node:node`. Plan: `apps` (568).

## Healthcheck/readiness
The fork healthcheck is malformed. Readiness: `GET /` returns the index page (plan test uses `GET /`). A `listening` log line on the port.

## Version/release info
No tags or releases. Pin by commit. Latest commit 8c45a370a79cc5caaf446ba0088574dfcb489694 (2021-03-01, per plan.md; the repo page did not show the date).

## Arch support
Node JS; arch-neutral. No native modules are listed in the core package.json (per plan).

## Gotchas
- Node 14 EOL base in the fork; plan moves to python-node (Node version there is not verified against the fork's dependencies; run it).
- Config is JSON in a `.js` file; generated from env at start.
- `recompressStaticAssets` writes into `static/`.
- Rate-limit quirk above.
- No upstream checksums; pin the commit SHA in the archive URL.
