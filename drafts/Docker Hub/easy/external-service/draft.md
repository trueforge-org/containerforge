# external-service

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: external-service
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Website**: https://alpinelinux.org/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: external-service
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `alpine:3.24.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/alpinelinux/docker-alpine/blob/0c9af76133a2dd9a31dedf3600e423087b29a879/x86_64/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://alpinelinux.org/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/x86_64/alpine-minirootfs-3.24.4-x86_64.tar.gz) · [arm64](https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/aarch64/alpine-minirootfs-3.24.4-aarch64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Placeholder image that is just an Alpine minirootfs with no application. On containerforge-ubuntu it is the base image plus a keepalive command, with nothing to install.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [alpine:3.24.4](https://hub.docker.com/_/alpine)
- **copy-from arm64**: [alpine:3.24.4](https://hub.docker.com/_/alpine)

### Dependency containers

- **Dependency containers**: none
