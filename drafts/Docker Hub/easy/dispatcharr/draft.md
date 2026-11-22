# dispatcharr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: dispatcharr
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Website**: https://alpinelinux.org
- **Documentation**: https://dispatcharr.github.io/Dispatcharr-Docs

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: dispatcharr
- **Role**: sidecar (alpineImage)

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/library/alpine:3.24`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/alpinelinux/docker-alpine/blob/v3.24/x86_64/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://alpinelinux.org)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/x86_64/alpine-minirootfs-3.24.4-x86_64.tar.gz) · [arm64](https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/aarch64/alpine-minirootfs-3.24.4-aarch64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Plain Alpine userland used as a helper/init image. Equivalent is trivially served by containerforge-ubuntu (or the ContainerForge scratch/ubuntu sibling); only busybox tooling is needed. Rootless and read-only are unproblematic.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [library/alpine:3.24](https://hub.docker.com/_/alpine)
- **copy-from arm64**: [library/alpine:3.24](https://hub.docker.com/_/alpine)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, CNPG PostgreSQL, sidecars).

- **Dependency containers**: -
