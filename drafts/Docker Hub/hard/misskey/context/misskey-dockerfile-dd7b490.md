# misskey-dev/misskey Dockerfile (pinned dd7b490)

**Source:** https://raw.githubusercontent.com/misskey-dev/misskey/dd7b4905d715d2587fa2f2cb6a88ecac8878ef0d/Dockerfile (fetched 2026-11-26; blob URL in urls.txt is the same file)

## Syntax / global
- `# syntax = docker/dockerfile:1.27`
- Global ARG NODE_VERSION=26.13.1-trixie

## Stages
| # | Name | Base | Platform |
|---|---|---|---|
| 1 | native-builder | node:${NODE_VERSION} | $BUILDPLATFORM |
| 2 | target-builder | node:${NODE_VERSION} | $TARGETPLATFORM |
| 3 | runner | node:${NODE_VERSION}-slim (26.13.1-trixie-slim) | $TARGETPLATFORM |

## ARG / ENV
| Type | Name | Value | Stage |
|---|---|---|---|
| ARG | NODE_ENV | production | native-builder, target-builder |
| ARG | UID / GID | 991 / 991 | runner |
| ENV | NODE_ENV | production | runner |
| ENV | PNPM_CONFIG_VERIFY_DEPS_BEFORE_RUN | false | runner |
| ENV | LD_PRELOAD | /usr/local/lib/libjemalloc.so | runner |

## apt
- native-builder, target-builder: build-essential
- runner: ffmpeg, tini, curl, libjemalloc-dev, libjemalloc2 (libjemalloc.so.2 symlinked to /usr/local/lib/libjemalloc.so)
- runner: creates group/user `misskey`; strips setuid/setgid bits; apt-get clean; removes /var/lib/apt/lists

## Build
- pnpm installed globally via `npm install -g` using `packageManager` from package.json (all stages)
- `pnpm i --frozen-lockfile --aggregate-output` (both builders; store cache mount /root/.local/share/pnpm/store)
- `pnpm build` (native-builder only); `rm -rf .git/`
- No Rust steps.
- Dep install copies root lock/workspace/package files, scripts/, patches/, and per-package package.json (backend, frontend-shared, frontend, frontend-embed, frontend-builder, i18n, icons-subsetter, sw, misskey-js, misskey-reversi, misskey-bubble-game).

## Runner
- Copies node_modules from target-builder; built output from native-builder (/misskey/built, packages, backend, i18n); then `COPY . ./` with --chown=misskey:misskey.

## Runtime
| Item | Value |
|---|---|
| WORKDIR | /misskey |
| USER | misskey (UID 991, GID 991) |
| EXPOSE | none |
| VOLUME | none |
| ENTRYPOINT | ["/usr/bin/tini", "--"] |
| CMD | ["node", "scripts/start.mjs", "--migrate"] |
| HEALTHCHECK | interval 5s, retries 20, `/bin/bash /misskey/healthcheck.sh` |

## Paths
- /misskey (root), /misskey/built, /misskey/packages/*/built, /misskey/healthcheck.sh, scripts/start.mjs
- /usr/bin/tini, /usr/local/lib/libjemalloc.so

## Gotchas
- Node 26 image tags (trixie). Runner user home is /misskey.
