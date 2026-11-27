# linuxserver/docker-dillinger Dockerfile
Source: https://raw.githubusercontent.com/linuxserver/docker-dillinger/1d1b7d5f198a81964e0e2b1428ba7d6bd4b1526e/Dockerfile (fetched 2026-11-27)

## Build
- Single stage FROM ghcr.io/linuxserver/baseimage-alpine:3.18
- ARG BUILD_DATE, VERSION, DILLINGER_VERSION (no default)
- ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true, PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
- LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}", maintainer="thelamer"

## Install (single RUN)
1. apk add -U --no-cache chromium nss freetype harfbuzz ttf-freefont npm (no pins)
2. mkdir -p /app/dillinger
3. If DILLINGER_VERSION unset: newest tag via curl https://api.github.com/repos/joemccann/dillinger/tags (jq .[0].name)
4. curl -o /tmp/dillinger.tar.gz -L https://github.com/joemccann/dillinger/archive/${DILLINGER_VERSION}.tar.gz
5. tar -xzf into /app/dillinger/ --strip-components=1
6. npm install --omit=dev --prefix /app/dillinger
7. npm cache clean --force; rm -rf $HOME/* $HOME/.npm /tmp/*

## Other
- COPY root/ /
- EXPOSE 8080
- VOLUME /config
- USER, ENTRYPOINT, CMD, HEALTHCHECK, ADD: none (base init presumed)

## Gotchas
- Installs chromium via apk; PUPPETEER env points to /usr/bin/chromium-browser
- Tag source is the GitHub tags API (not releases)
