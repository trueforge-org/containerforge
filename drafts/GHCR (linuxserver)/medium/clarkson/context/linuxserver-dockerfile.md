# linuxserver/docker-clarkson Dockerfile
Source: https://raw.githubusercontent.com/linuxserver/docker-clarkson/a055394e1b15b406965902248118536959e54f1f/Dockerfile (fetched 2026-11-27)

## Build
- Single stage FROM ghcr.io/linuxserver/baseimage-alpine:3.12 (only pin)
- ARG BUILD_DATE, VERSION, CLARKSON_RELEASE
- ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
- LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}", maintainer="sparklyballs"

## Packages (apk add --no-cache, no pins)
- Build (virtual build-dependencies): build-base, curl, libsass-dev, nodejs-npm, tar, python2
- Runtime: nodejs, nss, openjdk8-jre, sqlite-libs

## Install (single RUN)
1. If CLARKSON_RELEASE unset: tag_name from https://api.github.com/repos/linuxserver/Clarkson/releases/latest (awk)
2. mkdir -p /app/clarkson; download https://github.com/linuxserver/Clarkson/archive/${CLARKSON_RELEASE}.tar.gz to /tmp/clarkson-src.tar.gz; tar xf into /app/clarkson --strip-components=1
3. chmod +x ./flyway/flyway
4. npm config set unsafe-perm true; npm install; /app/clarkson/node_modules/@angular/cli/bin/ng build --prod
5. npm run prune-angular2; npm prune --production; apk del --purge build-dependencies; rm -rf /root /tmp/*; mkdir -p /root

## Other
- COPY root/ /
- No EXPOSE, VOLUME, USER, ENTRYPOINT, CMD, HEALTHCHECK (base s6 init presumed)

## Gotchas
- Node/Angular build; needs python2 and libsass-dev for the upstream build
- Requires JRE for flyway (openjdk8-jre upstream)
