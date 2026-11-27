# dashdot upstream Dockerfile

Source URL: https://raw.githubusercontent.com/MauriceNino/dashdot/24cc5d61e10f5255a44f85b5b35d333a3b9bc6d8/docker/Dockerfile (commit 24cc5d6, fetched 2026-11-27)

## What it is
Multi-stage Dockerfile for the dashdot Node app (yarn workspaces monorepo). Stages: base, dev, build, prod.

## Base
- `FROM node:20-alpine AS base`, WORKDIR /app
- ENV `DASHDOT_IMAGE=base`, `DASHDOT_RUNNING_IN_DOCKER=true`
- Runtime is root (no USER directive in prod stage)

## Base apk packages (stage base)
lsblk, mdadm, dmidecode, coreutils, util-linux, lm-sensors, speedtest-cli (apk `--no-cache add`)

## Speedtest binary (stage base, per arch)
- amd64 / x86_64: `https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-linux-x86_64.tgz`, extract `speedtest` to `/usr/bin`
- arm64 / aarch64: `...-linux-aarch64.tgz`, same extract; also apk `raspberrypi`
- arm/v7: `...-linux-armhf.tgz`; also apk `raspberrypi`
- Other arch: `exit 1` ("Unsupported platform")
- Arch detected via `$TARGETPLATFORM` or `uname -m`. No checksum verification upstream.

## Dev stage
- EXPOSE 3001, EXPOSE 3000; apk git; `git config --global --add safe.directory /app`

## Build stage
- ARG BUILDHASH, ARG VERSION; ENV NODE_ENV=production
- apk: git, make, clang, build-base
- writes `/app/version.json` = `{"version":"$VERSION","buildhash":"$BUILDHASH"}`
- `COPY . ./`
- `yarn --immutable && yarn build:prod && node scripts/strip_package_json.js`

## Prod stage
- ENV NODE_ENV=production; EXPOSE 3001
- COPY from build: `version.json`, `.yarn/releases`, `.yarnrc.yml`, `apps/server/dist` -> `server/dist`, `apps/view/dist` -> `view/dist`, `apps/cli/dist` -> `cli/dist`, `dist/package.json` -> `package.json`
- `RUN yarn`
- `CMD ["node", "server/dist/index.cjs"]`

## Gotchas
- Upstream is root, no non-root user.
- Build needs `git` (version info); `BUILDHASH` is passed as build arg.
- Speedtest download is unverified (no checksum in Dockerfile).
