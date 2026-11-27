# linuxserver/docker-couchpotato Dockerfile
Source URL: https://raw.githubusercontent.com/linuxserver/docker-couchpotato/273f98c4d935e5c5629b3978685c4066402c8490/Dockerfile (fetched 2026-11-27)

## Build (single stage)
- `FROM ghcr.io/linuxserver/baseimage-alpine:3.13`
- ARG BUILD_DATE, VERSION, COUCHPOTATO_RELEASE; LABEL maintainer aptalca
- ENV `PYTHONIOENCODING="UTF-8"`
- RUN: `apk add --no-cache curl python2 unrar unzip`
- RUN: mkdir `/app/couchpotato`; if COUCHPOTATO_RELEASE unset, resolve latest master commit sha via api.github.com/repos/CouchPotato/CouchPotatoServer/commits/master (awk parse)
- RUN: curl `https://github.com/CouchPotato/CouchPotatoServer/archive/${COUCHPOTATO_RELEASE}.tar.gz` to /tmp, extract to /app/couchpotato with --strip-components=1; rm /tmp/*
- COPY root/ /
- EXPOSE 5050
- WORKDIR /app/couchpotato
- VOLUME /config
- No ENTRYPOINT, CMD or HEALTHCHECK (from base image)

## Gotchas
- Python 2 (python2 apk package) on Alpine 3.13 base; EOL base image.
- Without build arg COUCHPOTATO_RELEASE, build resolves the moving master commit.
