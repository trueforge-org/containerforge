# linuxserver/docker-nano-wallet Dockerfile

Source URL (fetched 2026-11-27, pinned commit):
- https://raw.githubusercontent.com/linuxserver/docker-nano-wallet/120b82f4d1ba/Dockerfile

## Stage 1: build
- `FROM lsiobase/alpine:3.12` AS `build` (tag only, no digest).
- ARG: `WALLET_VERSION` (no default).
- RUN (single layer):
  - `apk add` `curl`, `git`, `nodejs-npm`.
  - `git clone https://github.com/linuxserver/nano-wallet.git`, `cd nano-wallet`.
  - If `WALLET_VERSION` unset: resolve latest master SHA via `curl https://api.github.com/repos/linuxserver/nano-wallet/commits/master` (awk field 4).
  - `git checkout ${WALLET_VERSION}`
  - `npm install`, `npm run build`.

## Stage 2: runtime
- `FROM lsiobase/alpine:3.12` (no digest).
- ARG: `BUILD_DATE`, `VERSION`.
- LABEL: `build_version`, `maintainer="thelamer"`.
- RUN `apk add --no-cache nginx`.
- COPY `--from=build /nano-wallet/dist` -> `/web`.
- COPY `root/` -> `/`.
- EXPOSE `80`.
- No ADD, VOLUME, ENTRYPOINT, CMD, HEALTHCHECK, USER, ENV.

## Gotchas
- Base is `lsiobase/alpine:3.12` (not `baseimage-alpine`), so the s6 layout comes from `root/`.
- Static web build served by nginx from `/web`. Needs the nginx config from `root/` (api nginx.conf listed but not fetched).
