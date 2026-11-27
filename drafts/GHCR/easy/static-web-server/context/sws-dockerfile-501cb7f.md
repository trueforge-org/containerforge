# static-web-server upstream Dockerfile (docker/scratch, commit 501cb7f)

## Source URL(s) + date
- https://raw.githubusercontent.com/static-web-server/static-web-server/501cb7fcb6a01a4e73e6d5f541559e3334c39976/docker/scratch/Dockerfile (from blob URL in urls.txt)
- Fetched 2026-11-27

## Stages
- build: `FROM joseluisq/static-web-server:${SERVER_VERSION}-alpine AS build`
- final: `FROM scratch`
- ARG `SERVER_VERSION=0.0.0` (both stages); ENV `SERVER_VERSION=${SERVER_VERSION}`

## Steps
- COPY `--from=build /usr/local/bin/static-web-server /`
- COPY `./docker/public /public`
- No RUN, no USER, no UID/GID, no WORKDIR, no VOLUME, no HEALTHCHECK, no CMD

## Runtime
- EXPOSE `80`
- ENTRYPOINT `["/static-web-server"]`
- STOPSIGNAL `SIGQUIT`
- LABEL blocks (version, description, maintainer, OCI metadata)
