# linuxserver/docker-cloud9 Dockerfile
Source URL: https://raw.githubusercontent.com/linuxserver/docker-cloud9/e8b635534987561f47ab7cc1c48e57c74f1c6d8a/Dockerfile (fetched 2026-11-27)

## Build (2 stages)
- ARG COMPOSE_VERSION="1.29.2"
- Stage `compose`: `FROM ghcr.io/linuxserver/docker-compose:amd64-version-${COMPOSE_VERSION}`
- Final: `FROM ghcr.io/linuxserver/baseimage-cloud9:latest`
- ARG BUILD_DATE, VERSION; LABEL build_version, maintainer thelamer
- COPY --from=compose /usr/local/bin/docker-compose
- RUN: fetch Docker GPG key via curl and `apt-key add`; write `/etc/apt/sources.list.d/docker-ce.list` (amd64, ubuntu bionic stable); apt-get install `docker-ce`; autoclean; rm apt lists, /var/tmp, /tmp
- No EXPOSE, VOLUME, ENV, ENTRYPOINT, CMD or HEALTHCHECK in this file (inherited from base)

## Upstream project (c9/core, package.json on master)
- name `c9`, version 3.1.5000, description "New Cloud9 Client", main `bin/c9`
- license field empty list (not specified)

## Gotchas
- Dockerfile pins docker-compose 1.29.2 and bundles docker-ce (apt repo uses bionic path on ubuntu URL).
- apt-key is deprecated on current Debian/Ubuntu bases; repo last pushed 2022.
- Image is marked unsupported by linuxserver (per Docker Hub description).
