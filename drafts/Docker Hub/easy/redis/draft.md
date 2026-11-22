# redis

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: redis
- **Rows**: 1
- **Hard dependency containers**: no
- **Soft dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/redis/redis

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: redis
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/bitnamisecure/redis:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/bitnami/containers/blob/9da424411c57f30d7bdc8409eabcce6e5709c9f3/bitnami/redis/8.10/debian-12/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/redis/redis)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:redis-server`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: The bitnami secure redis build is closed, but Ubuntu's redis-server apt package covers the same role. Install it on containerforge-ubuntu, point the data directory at /config, and run one process. The valkey sibling is an alternative.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [bitnamisecure/redis:latest](https://hub.docker.com/r/bitnamisecure/redis)
- **copy-from arm64**: [bitnamisecure/redis:latest](https://hub.docker.com/r/bitnamisecure/redis)

### Dependency containers

- **Dependency containers**: none
